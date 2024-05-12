import Foundation

struct MovieList: Decodable {
  let page: Int
  let results: [Movie]
}
