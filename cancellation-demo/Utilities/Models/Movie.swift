import Foundation
import SwiftUI

struct Movie: Decodable, Identifiable {
  enum LoadingState {
    case idle
    case loaded
    case failed
    case loading
    case cancelled
  }
  
  let id: Int
  let title: String
  let posterPath: String
  let releaseDate: Date
  let voteAverage: Double
  
  var loadingState: LoadingState = .idle
  
  var voteAverageCopy: String {
    String(format: "%.2f", voteAverage)
  }
  
  var releaseDateCopy: String {
    DateFormatter.yearMonthDay.string(from: releaseDate)
  }
  
  var backgroundColor: Color {
    switch loadingState {
    case .idle, .loading:
      return .white
    case .loaded:
      return .green.opacity(0.25)
    case .failed:
      return .red.opacity(0.25)
    case .cancelled:
      return .yellow.opacity(0.25)
    }
  }
  
  enum CodingKeys: CodingKey {
    case id
    case title
    case posterPath
    case releaseDate
    case voteAverage
  }
  
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(Int.self, forKey: .id)
    self.title = try container.decode(String.self, forKey: .title)
    self.posterPath = try container.decode(String.self, forKey: .posterPath)
    self.releaseDate = try container.decode(Date.self, forKey: .releaseDate)
    self.voteAverage = try container.decode(Double.self, forKey: .voteAverage)
  }
}
