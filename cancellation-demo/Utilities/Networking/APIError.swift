import Foundation

protocol AppError: Error {
  var description: String { get }
}

extension ApiErrorType: Equatable {
  static func == (lhs: ApiErrorType,
                  rhs: ApiErrorType) -> Bool {
    lhs.description == rhs.description
  }
}

enum ApiErrorType: AppError {
  case commonError, serverError, parseError
  case customError(String)
  
  var description: String {
    switch self {
    case .parseError: return "Parse Error"
    case .serverError: return "Server Error"
    case .commonError: return "Common API error"
    case let .customError(details): return details
    }
  }
}
