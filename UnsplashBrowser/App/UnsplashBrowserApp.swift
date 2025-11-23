//
//  UnsplashBrowserApp.swift
//  UnsplashBrowser
//
//  Created by Quân Đinh on 22.11.25.
//

import SwiftUI
import Swinject

@main
struct UnsplashBrowserApp: App {

  let resolver = AppDIContainer.build()
  @State private var favoriteAuthorsStore: FavoriteAuthorsStore?
  @State private var imageLoader: ImageLoader?

  var body: some Scene {
    WindowGroup {
      TabView {
        SearchPhotosView()
          .tabItem {
            Label("Search", systemImage: "magnifyingglass.circle")
              .font(.title)
          }
          .tag(0)
        
        FavoritesRootView()
          .tabItem {
            Label("Favorites", systemImage: "heart.circle")
              .font(.title)
          }
          .tag(1)
      }
      .tint(.secondary)
      .environment(\.resolver, resolver)
      .environment(\.isRunningOniPad, UIDevice.current.userInterfaceIdiom == .pad)
      .environment(\.favoriteAuthorsStore, favoriteAuthorsStore)
      .environment(\.imageLoader, imageLoader)
      .task {
        if favoriteAuthorsStore == nil {
          favoriteAuthorsStore = resolver.resolve(FavoriteAuthorsStore.self)
        }
        if imageLoader == nil {
          imageLoader = resolver.resolve(ImageLoader.self)
        }
      }
    }
  }
}
