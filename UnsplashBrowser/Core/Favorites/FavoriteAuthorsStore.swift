// FavoriteAuthorsStore.swift
// @Observable class for managing favorite authors with persistence

import Foundation
import SwiftUI

struct FavoriteAuthor: Codable, Identifiable, Equatable {
  let id: String
  let username: String
  let name: String
  let userImage: String?
  let url: String?
}

@Observable
class FavoriteAuthorsStore {
  @ObservationIgnored private var favoritesKey = "favoriteAuthors"
  @ObservationIgnored private var favoritesData: Data = UserDefaults.standard.data(forKey: "favoriteAuthors") ?? Data()
  
  private func persistFavoritesData() {
    UserDefaults.standard.set(favoritesData, forKey: favoritesKey)
  }
  
  var favorites: [FavoriteAuthor] {
    get {
      guard !favoritesData.isEmpty else {
        return []
      }
      do {
        let decoder = JSONDecoder()
        return try decoder.decode([FavoriteAuthor].self, from: favoritesData)
      } catch {
        print("Failed to decode favorites: \(error)")
        return []
      }
    }
    set {
      do {
        let encoder = JSONEncoder()
        favoritesData = try encoder.encode(newValue)
        persistFavoritesData()
      } catch {
        print("Failed to encode favorites: \(error)")
      }
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
