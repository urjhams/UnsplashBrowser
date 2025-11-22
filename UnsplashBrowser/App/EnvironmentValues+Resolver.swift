// EnvironmentValues+Resolver.swift
// Defines EnvironmentKey for DI resolver

import SwiftUI
import Swinject

private struct ResolverKey: EnvironmentKey {
  static let defaultValue: Resolver = AppDIContainer.build()
}

extension EnvironmentValues {
  var resolver: Resolver {
    get {
      self[ResolverKey.self]
    }
    set {
      self[ResolverKey.self] = newValue
    }
  }
}
