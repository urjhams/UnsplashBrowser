// UnsplashAPIError.swift
// Error types for Unsplash API

import Foundation

enum UnsplashAPIError: Error, LocalizedError, Equatable {
  case badRequest
  case unauthorized
  case forbidden
  case notFound
  case rateLimitExceeded
  case serverError
  case serverError2
  case unknown(statusCode: Int)

  init(statusCode: Int) {
    self = switch statusCode {
    case 400:
      .badRequest
    case 401:
      .unauthorized
    case 403:
      .forbidden
    case 404:
      .notFound
    case 429:
      .rateLimitExceeded
    case 500:
      .serverError
    case 503:
      .serverError2
    default:
      .unknown(statusCode: statusCode)
    }
  }
  
  var statusCode: any BinaryInteger {
    return switch self {
    case .badRequest:
      400
    case .unauthorized:
      401
    case .forbidden:
      403
    case .notFound:
      404
    case .rateLimitExceeded:
      429
    case .serverError:
      500
    case .serverError2:
      503
    case .unknown(let code):
      code
    }
  }
  
  var errorDescription: String? {
    return switch self {
    case .badRequest:
      "Bad Request: The request was unacceptable, often due to missing a required parameter"
    case .unauthorized:
      "Unauthorized: Invalid Access Token"
    case .forbidden:
      "Forbidden: Missing permissions to perform request"
    case .notFound:
      "Not Found: The requested resource doesn't exist"
    case .rateLimitExceeded:
      "Rate Limit Exceeded: Too many requests"
    case .serverError, .serverError2:
      "Server Error: Something went wrong on our end"
    case .unknown(let statusCode):
      "HTTP Error: Received status code \(statusCode)"
    }
  }
}
