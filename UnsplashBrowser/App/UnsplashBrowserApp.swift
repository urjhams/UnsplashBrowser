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

  var body: some Scene {
    WindowGroup {
      TabView {
        SearchPhotosView()
          .tabItem {
            Label("Search Photos", systemImage: "magnifyingglass.circle")
          }
          .tag(0)
        
        FavoritesRootView()
          .tabItem {
            Label("Favorites", systemImage: "heart.circle")
          }
          .tag(1)
      }
      .tint(.black)
      .environment(\.resolver, resolver)
      .environment(\.isRunningOniPad, UIDevice.current.userInterfaceIdiom == .pad)
      .environment(\.favoriteAuthorsStore, favoriteAuthorsStore)
      .task {
        if favoriteAuthorsStore == nil {
          favoriteAuthorsStore = resolver.resolve(FavoriteAuthorsStore.self)
        }
      }
    }
  }
}
