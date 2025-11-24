// FavoritesRootView.swift
// SwiftUI view with NavigationSplitView for iPad, NavigationStack for iPhone

import SwiftUI
import Swinject

/// Root view for the Favorites feature.
/// Uses NavigationSplitView on iPad and NavigationStack on iPhone.
struct FavoritesRootView: View {
  // MARK: - Properties
  
  @Environment(\.resolver) private var resolver
  @Environment(\.isRunningOniPad) private var isIpad
  @Environment(\.favoriteAuthorsStore) private var store
  @Environment(\.imageLoader) private var imageLoader
  
  @State private var selectedAuthor: FavoriteAuthor?
  @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
  
  // MARK: - Body
  
  var body: some View {
    Group {
      if let store {
        if isIpad {
          splitViewLayout(store: store)
        } else {
          stackLayout(store: store)
        }
      } else {
        ContentUnavailableView(
          "Loading...",
          systemImage: "arrow.clockwise",
          description: Text("Setting up favorites")
        )
      }
    }
  }
  
  // MARK: - View Components
  
  /// iPad layout using NavigationSplitView
  private func splitViewLayout(store: FavoriteAuthorsStore) -> some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
      FavoriteAuthorsView(
        store: store,
        selectedAuthor: $selectedAuthor
      )
      .navigationTitle("Favorite")
    } detail: {
      if let selectedAuthor {
        WebProfileView(author: selectedAuthor)
          .id(selectedAuthor.id)
      } else {
        emptyDetailView
      }
    }
    .navigationSplitViewStyle(.balanced)
  }
  
  /// iPhone layout using NavigationStack
  private func stackLayout(store: FavoriteAuthorsStore) -> some View {
    NavigationStack {
      FavoriteAuthorsView(
        store: store,
        selectedAuthor: $selectedAuthor
      )
      .navigationTitle("Favorite")
      .navigationDestination(item: $selectedAuthor) { author in
        WebProfileView(author: author)
      }
    }
  }
  
  /// Empty detail pane for iPad when no author is selected
  private var emptyDetailView: some View {
    ContentUnavailableView(
      "Select an Author",
      systemImage: "person.fill",
      description: Text("Select a favorite author to view their profile")
    )
  }
}

