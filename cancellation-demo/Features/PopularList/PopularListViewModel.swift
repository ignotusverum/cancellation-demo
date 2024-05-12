import Foundation
import Combine

class PopularListViewModel: ObservableObject {
  enum State {
    case initial
    case loading
    case error(Error)
    case viewData([Movie])
  }
  
  enum ViewAction {
    case reload
    case viewAppeared
    case viewDissapeared
    case scrolledToPage(Int)
    case loadDetails(movieID: Int)
    case stopLoading(movieID: Int)
  }
  
  enum ModelAction {
    case error(Error)
    case loaded([Movie])
    case loadedDetails(id: Int, state: Movie.LoadingState)
  }
  
  enum Action {
    case view(ViewAction)
    case model(ModelAction)
  }
  
  @Published private(set) var state: State
  private var fetchMovieDetailsTask: [Int: Task<Void, Never>] = [:]
  
  init(state: State) {
    self.state = state
  }
  
  static func reduce(
    state: State,
    action: Action
  ) -> State {
    switch action {
    case
        .view(.reload),
        .view(.viewAppeared):
      return .loading
      
    case let .model(.error(error)):
      return .error(error)
      
    case let .model(.loaded(movieList)):
      return .viewData(movieList)
      
    case let .model(.loadedDetails(movieID, movieState)):
      guard
        case var .viewData(movieList) = state,
        let updateIndex = movieList.firstIndex(where: { $0.id == movieID })
      else { return state }
      
      var updatedMovie = movieList[updateIndex]
      if updatedMovie.loadingState == .loading {
        updatedMovie.loadingState = movieState
      }
      movieList[updateIndex] = updatedMovie
      
      return .viewData(movieList)
      
    case let .view(.loadDetails(movieID)):
      guard
        case var .viewData(movieList) = state,
        let updateIndex = movieList.firstIndex(where: { $0.id == movieID }),
        movieList[updateIndex].loadingState != .loaded && movieList[updateIndex].loadingState != .cancelled
      else { return state }
      
      var movie = movieList[updateIndex]
      movie.loadingState = .loading
      movieList[updateIndex] = movie
      
      return .viewData(movieList)
            
    default: return state
    }
  }
  
  func apply(_ viewAction: ViewAction) {
    let action = Action.view(viewAction)
    DispatchQueue.main.async {
      self.state = Self.reduce(
        state: self.state,
        action: action
      )
    }
    
    handleSideEffects(viewAction)
  }
  
  private func handleSideEffects(_ viewAction: ViewAction) {
    switch viewAction {
    case
        .viewAppeared,
        .reload:
      loadPopularMovies()
      
    case let .loadDetails(movieID):
      guard
        case let .viewData(movieList) = state,
        let updateIndex = movieList.firstIndex(where: { $0.id == movieID }),
        movieList[updateIndex].loadingState != .loaded && movieList[updateIndex].loadingState != .cancelled
      else { return }
      
      loadMovieDetails(movieID: movieID)
      
    case let .stopLoading(movieID):
      stopLoadingDetails(movieID: movieID)
      
    case .viewDissapeared:
      fetchMovieDetailsTask.forEach { _, task in
        task.cancel()
      }
      
    default:
      break
    }
  }
}

extension PopularListViewModel {
  private func delayRandomly() async {
    let delayInSeconds = Int.random(in: 2...4)
    try? await Task.sleep(nanoseconds: UInt64(delayInSeconds) * 1_000_000_000)
  }
  
  private func loadMovieDetails(movieID: Int) {
    cancelAndRemoveTask(movieID: movieID)
    let task = Task {
      await delayRandomly()
      await loadMovieDetails(movieID: movieID)
    }
    fetchMovieDetailsTask[movieID] = task
  }
  
  private func stopLoadingDetails(movieID: Int) {
    cancelAndRemoveTask(movieID: movieID)
    DispatchQueue.main.async {
      self.state = Self.reduce(state: self.state, action: .model(.loadedDetails(id: movieID, state: .cancelled)))
    }
  }
  
  private func cancelAndRemoveTask(movieID: Int) {
    fetchMovieDetailsTask[movieID]?.cancel()
    fetchMovieDetailsTask.removeValue(forKey: movieID)
  }
  
  private func loadPopularMovies() {
    Task {
      do {
        let movieList = try await MovieService.popular()
        DispatchQueue.main.async {
          self.state = Self.reduce(state: self.state, action: .model(.loaded(movieList)))
        }
      } catch {
        DispatchQueue.main.async {
          self.state = Self.reduce(state: self.state, action: .model(.error(error)))
        }
      }
    }
  }
  
  private func loadMovieDetails(movieID: Int) async {
    do {
      _ = try await MovieService.details(id: movieID)
      DispatchQueue.main.async {
        self.state = Self.reduce(state: self.state, action: .model(.loadedDetails(id: movieID, state: .loaded)))
      }
    } catch {
      let newState: Movie.LoadingState = error is CancellationError ? .cancelled : .failed
      DispatchQueue.main.async {
        self.state = Self.reduce(state: self.state, action: .model(.loadedDetails(id: movieID, state: newState)))
      }
    }
  }
}
