//  MockURLProtocol.swift
//  UnsplashBrowserTests

import Foundation

/// Base protocol for creating mock URL protocol classes
/// Each test suite should create its own subclass to avoid shared state
class MockURLProtocolBase: URLProtocol {
  /// Storage for request handlers, keyed by class name to avoid conflicts
  private static var handlers: [String: (URLRequest) throws -> (HTTPURLResponse, Data?)] = [:]
  private static let handlersLock = NSLock()
  
  /// Set the request handler for a specific protocol class
  class func setHandler(_ handler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?) {
    handlersLock.lock()
    defer { handlersLock.unlock() }
    
    let key = String(describing: self)
    if let handler = handler {
      handlers[key] = handler
    } else {
      handlers.removeValue(forKey: key)
    }
  }
  
  /// Get the request handler for a specific protocol class
  class func getHandler() -> ((URLRequest) throws -> (HTTPURLResponse, Data?))? {
    handlersLock.lock()
    defer { handlersLock.unlock() }
    
    let key = String(describing: self)
    return handlers[key]
  }

  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }

  override func startLoading() {
    guard let handler = type(of: self).getHandler() else {
      fatalError("Request handler is not set for \(type(of: self))")
    }

    do {
      let (response, data) = try handler(request)
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

      if let data = data {
        client?.urlProtocol(self, didLoad: data)
      }

      client?.urlProtocolDidFinishLoading(self)
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }

  override func stopLoading() { }
}

// MARK: - Test Suite Specific Protocols

/// Mock protocol for ImageLoaderTests
final class ImageLoaderMockURLProtocol: MockURLProtocolBase {}

/// Mock protocol for UnsplashAPIClientTests  
final class APIClientMockURLProtocol: MockURLProtocolBase {}

/// Legacy MockURLProtocol for backwards compatibility
typealias MockURLProtocol = ImageLoaderMockURLProtocol
