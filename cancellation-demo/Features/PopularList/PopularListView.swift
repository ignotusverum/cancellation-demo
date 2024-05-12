import SwiftUI
import Foundation

struct PopularListView: View {
  @ObservedObject var viewModel: PopularListViewModel
  
  var body: some View {
    List {
      switch viewModel.state {
      case .initial:
        EmptyView()
      case .loading:
        ProgressView()
          .listRowSeparator(.hidden)
      case .error:
        ErrorCard(
          onTryAgain: {
            viewModel.apply(.reload)
          }
        )
        .listRowSeparator(.hidden)
      case let .viewData(movieList):
        MovieListView(
          movies: movieList,
          onMovieAppear: { movie in
            viewModel.apply(.loadDetails(movieID: movie.id))
          },
          onMovieDissapear: { movie in
            viewModel.apply(.stopLoading(movieID: movie.id))
          })
        .listRowSeparator(.hidden)
      }
    }
    .refreshable {
      viewModel.apply(.reload)
    }
    .listStyle(.plain)
    .onAppear {
      viewModel.apply(.viewAppeared)
    }
    .onDisappear {
      viewModel.apply(.viewDissapeared)
    }
  }
}

extension PopularListView {
  struct MovieCard: View {
    let movie: Movie
    
    var body: some View {
      VStack {
        Text(movie.title)
          .font(.headline)
        Text("\(movie.voteAverageCopy) / 10")
          .font(.subheadline)
        Text(movie.releaseDateCopy)
          .font(.footnote)
        
        switch movie.loadingState {
        case .idle:
          Text("⏺")
        case .loaded:
          Text("✅")
        case .failed:
          Text("❌")
        case .cancelled:
          Text("⚠️")
        case .loading:
          ProgressView()
        }
      }
      .padding()
      .frame(maxWidth: .infinity)
      .background(movie.backgroundColor)
      .cornerRadius(10)
      .shadow(radius: 3)
      .padding([.horizontal, .bottom])
      .animation(.spring, value: movie.loadingState)
    }
  }
}

extension PopularListView {
  struct MovieListView: View {
    let movies: [Movie]
    let onMovieAppear: (Movie) -> ()
    let onMovieDissapear: (Movie) -> ()
    
    var body: some View {
      ForEach(movies) { movie in
        MovieCard(movie: movie)
          .onAppear {
            onMovieAppear(movie)
          }
          .onDisappear {
            onMovieDissapear(movie)
          }
      }
    }
  }
}

extension PopularListView {
  struct ErrorCard: View {
    let onTryAgain: () -> ()
    
    var body: some View {
      Button(action: onTryAgain) {
        VStack(spacing: 16) {
          Image(systemName: "exclamationmark.triangle")
          Text("Somethign went wrong, please try again.")
        }
      }
      .padding()
      .frame(maxWidth: .infinity)
    }
  }
}
