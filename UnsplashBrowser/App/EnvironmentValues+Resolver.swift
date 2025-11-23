// EnvironmentValues+Resolver.swift
// Defines EnvironmentKey for DI resolver

import SwiftUI
import Swinject

private struct ResolverKey: EnvironmentKey {
  static let defaultValue: Resolver = AppDIContainer.build()
}

private struct FavoriteAuthorsStoreKey: EnvironmentKey {
  static let defaultValue: FavoriteAuthorsStore? = nil
}

private struct ImageLoaderKey: EnvironmentKey {
  static let defaultValue: ImageLoader? = nil
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
  
  var favoriteAuthorsStore: FavoriteAuthorsStore? {
    get {
      self[FavoriteAuthorsStoreKey.self]
    }
    set {
      self[FavoriteAuthorsStoreKey.self] = newValue
    }
  }
  
  var imageLoader: ImageLoader? {
    get {
      self[ImageLoaderKey.self]
    }
    set {
      self[ImageLoaderKey.self] = newValue
    }
  }
}
