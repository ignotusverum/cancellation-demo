import SwiftUI

@main
struct CancellationApp: App {
  var viewModel: PopularListViewModel = .init(state: .initial)
  
  var body: some Scene {
    WindowGroup {
      PopularListView(viewModel: viewModel)
    }
  }
}
