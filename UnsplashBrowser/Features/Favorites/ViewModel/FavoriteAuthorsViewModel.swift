// FavoriteAuthorsViewModel.swift
// @Observable class for favorites logic (optional)

import Foundation

/// ViewModel for managing favorite authors list state.
/// Currently lightweight as FavoriteAuthorsStore handles most logic.
@MainActor
@Observable
class FavoriteAuthorsViewModel {
  // MARK: - Dependencies
  
  private let store: FavoriteAuthorsStore
  
  // MARK: - Public Properties
  
  /// Currently selected author for split view detail pane
  var selectedAuthor: FavoriteAuthor?
  
  // MARK: - Computed Properties
  
  /// Array of favorite authors from the store
  var favorites: [FavoriteAuthor] {
    store.favorites
  }
  
  /// Whether the favorites list is empty
  var isEmpty: Bool {
    favorites.isEmpty
  }
  
  // MARK: - Initialization
  
  init(store: FavoriteAuthorsStore) {
    self.store = store
  }
  
  // MARK: - Public Methods
  
  /// Removes a favorite author from the list
  /// - Parameter author: The author to remove
  func removeFavorite(_ author: FavoriteAuthor) {
    store.toggleFavorite(author)
    
    // Clear selection if the removed author was selected
    if selectedAuthor?.id == author.id {
      selectedAuthor = nil
    }
  }
}
