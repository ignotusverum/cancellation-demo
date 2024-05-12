import Foundation
import Combine

struct ServiceConfiguration {
  var base: String = "api.themoviedb.org"
  var serviceBase: String
}

protocol APIService {
  static var config: ServiceConfiguration { get }
  
  static func request(requestConfig: RequestConfig) async throws -> Data
  static func configureURLRequest(for requestConfig: RequestConfig)-> URLRequest
}

extension APIService {
  static func request(requestConfig: RequestConfig) async throws -> Data {
    let request = configureURLRequest(for: requestConfig)
    
    let (data, response) = try await URLSession.shared.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw ApiErrorType.serverError }
    return data
  }
  
  static func configureURLRequest(for requestConfig: RequestConfig)-> URLRequest {
    var components = URLComponents()
    components.scheme = "https"
    
    components.host = config.base
    
    var pathItems: [String] = []
    pathItems.append(config.serviceBase)
    if let path = requestConfig.path { pathItems.append(path) }
    
    components.queryItems = requestConfig.queryItems
    
    let cleanedPath = pathItems
      .filter { !$0.isEmpty }
      .joined(separator: "/")
    
    components.path = "/\(cleanedPath)"
    
    var request = URLRequest(url: components.url!)
    request.httpMethod = requestConfig.method.methodName
    request.timeoutInterval = 5
    
    switch requestConfig.method {
    case
      let .post(data),
      let .put(data):
      request.httpBody = data
    default: break
    }
    
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(
      "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhM2ZhNDYwZWFiYTU1YmMzMTJiYzNlYTc1NDQzYzIyMCIsInN1YiI6IjVmOTFhM2M4Y2E4MzU0MDAzNWI3MmRkNiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.qPG4sCM3LW_APCqcJJOJk6_zhzhixSwenrbTvwfaN4g",
      forHTTPHeaderField: "Authorization"
    )
    
    return request
  }
}
