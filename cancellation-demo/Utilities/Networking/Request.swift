import Foundation

public enum HTTPMethod {
  case get
  case post(Data?)
  case put(Data?)
  case delete
  
  var methodName: String {
    switch self {
    case .get: return "GET"
    case .put: return "PUT"
    case .post: return "POST"
    case .delete: return "DELETE"
    }
  }
}

public typealias HTTPHeaders = [String: String]

public struct RequestConfig {
  public var method: HTTPMethod
  public var path: String?
  public var queryItems: [URLQueryItem]?
  
  public init(method: HTTPMethod,
              path: String? = nil,
              queryItems: [URLQueryItem]? = nil) {
    self.method = method
    self.path = path
    self.queryItems = queryItems
  }
}

