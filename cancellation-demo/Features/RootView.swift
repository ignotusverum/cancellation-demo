import SwiftUI

struct RootView: View {
  var viewModel: PopularListViewModel = .init(state: .initial)
  
  var body: some View {
    NavigationView {
      NavigationLink {
        PopularListView(viewModel: viewModel)
      } label: {
        Text("Start")
      }
    }
  }
}
