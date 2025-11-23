// FavoriteAuthorsStore.swift
// @Observable class for managing favorite authors with persistence

import Foundation
import SwiftUI

struct FavoriteAuthor: Codable, Identifiable, Hashable {
  let id: String
  let username: String
  let name: String
  let userImage: String?
  let url: String?
}

@Observable
class FavoriteAuthorsStore {
  @ObservationIgnored private let favoritesKey = "favoriteAuthors"
  
  // task to track the debounce task
  @ObservationIgnored private var saveTask: Task<Void, Never>?
  
  var favorites: [FavoriteAuthor] {
    didSet {
      debouncedSave()
    }
  }
  
  init() {
    self.favorites = Self.loadFavorites()
  }
  
  deinit {
    saveTask?.cancel()
  }
  
  private static func loadFavorites() -> [FavoriteAuthor] {
    guard let data = UserDefaults.standard.data(forKey: "favoriteAuthors"),
          !data.isEmpty else {
      return []
    }
    do {
      let decoder = JSONDecoder()
      return try decoder.decode([FavoriteAuthor].self, from: data)
    } catch {
      print("Failed to decode favorites: \(error)")
      return []
    }
  }
  
  /// make the save process devounced to avoid using too much expensive JSONEncoder
  private func debouncedSave() {
    saveTask?.cancel()
    saveTask = Task { @MainActor in
      try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
      guard !Task.isCancelled else { return }
      saveFavorites()
    }
  }
  
  private func saveFavorites() {
    do {
      let encoder = JSONEncoder()
      let data = try encoder.encode(favorites)
      UserDefaults.standard.set(data, forKey: favoritesKey)
    } catch {
      print("Failed to encode favorites: \(error)")
    }
  }

  // MARK: - Public Methods

  func toggleFavorite(_ author: FavoriteAuthor) {
    var currentFavorites = favorites
    if let index = currentFavorites.firstIndex(where: { $0.id == author.id }) {
      currentFavorites.remove(at: index)
    } else {
      currentFavorites.append(author)
    }
    favorites = currentFavorites
  }

  func isFavorite(_ authorId: String) -> Bool {
    favorites.contains(where: { $0.id == authorId })
  }
}
