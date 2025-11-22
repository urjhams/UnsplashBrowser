//
//  UnsplashBrowserApp.swift
//  UnsplashBrowser
//
//  Created by Quân Đinh on 22.11.25.
//

import SwiftUI

@main
struct UnsplashBrowserApp: App {

  let resolver = AppDIContainer.build()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.resolver, resolver)
    }
  }
}
