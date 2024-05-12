import Foundation

class MovieService: APIService {
  static var config = ServiceConfiguration(serviceBase: "3/movie")
  
  static func popular(page: Int = 1) async throws -> [Movie] {
    try await request(
      requestConfig: RequestConfig(
        method: .get,
        path: "popular",
        queryItems: [
          URLQueryItem(name: "page", value: "\(page)")
        ]
      )
    )
    .map(to: MovieList.self)
    .results
  }
  
  static func details(id: Int) async throws -> Movie {
    try await request(
      requestConfig: RequestConfig(
        method: .get,
        path: "\(id)"
      )
    )
    .map(to: Movie.self)
  }
}
