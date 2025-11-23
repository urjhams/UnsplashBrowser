// FavoriteAuthorsView.swift
// SwiftUI view listing favorite authors

import SwiftUI
import Swinject

/// List view displaying all favorite authors.
/// Supports selection for NavigationSplitView and swipe-to-delete.
struct FavoriteAuthorsView: View {
  // MARK: - Properties
  
  let store: FavoriteAuthorsStore
  let imageLoader: ImageLoader?
  
  @Binding var selectedAuthor: FavoriteAuthor?
  
  // MARK: - Body
  
  var body: some View {
    List(selection: $selectedAuthor) {
      ForEach(store.favorites) { author in
        AuthorRowView(author: author, imageLoader: imageLoader)
          .tag(author)
      }
      .onDelete(perform: deleteFavorites)
    }
    .listStyle(.plain)
    .overlay {
      if store.favorites.isEmpty {
        emptyStateView
      }
    }
  }
  
  // MARK: - View Components
  
  /// Empty state when no favorites are saved
  private var emptyStateView: some View {
    ContentUnavailableView(
      "No Favorite Authors",
      systemImage: "heart.slash",
      description: Text("Authors you favorite will appear here")
    )
  }
  
  // MARK: - Private Methods
  
  /// Handles swipe-to-delete action
  /// - Parameter offsets: Index set of items to delete
  private func deleteFavorites(at offsets: IndexSet) {
    for index in offsets {
      let author = store.favorites[index]
      store.toggleFavorite(author)
      
      // Clear selection if the removed author was selected
      if selectedAuthor?.id == author.id {
        selectedAuthor = nil
      }
    }
  }
}

// MARK: - Helper Views

/// Row view for displaying a single author in the list
private struct AuthorRowView: View {
  let author: FavoriteAuthor
  let imageLoader: ImageLoader?
  
  private enum Layout {
    static let imageSize: CGFloat = 44
    static let cornerRadius: CGFloat = 22
    static let spacing: CGFloat = 12
  }
  
  var body: some View {
    HStack(spacing: Layout.spacing) {
      authorImage
      
      authorInfo
      
      Spacer()
      
      Image(systemName: "chevron.right")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .contentShape(Rectangle())
  }
  
  /// Author profile image with fallback
  @ViewBuilder
  private var authorImage: some View {
    if let imageLoader, let imageURL = author.userImage, let url = URL(string: imageURL) {
      RemoteImageView(url: url, imageLoader: imageLoader)
        .frame(width: Layout.imageSize, height: Layout.imageSize)
        .clipShape(Circle())
    } else {
      Circle()
        .fill(Color.gray.opacity(0.3))
        .frame(width: Layout.imageSize, height: Layout.imageSize)
        .overlay {
          Image(systemName: "person.fill")
            .foregroundStyle(.secondary)
        }
    }
  }
  
  /// Author name and username
  private var authorInfo: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(author.name)
        .font(.headline)
      Text("@\(author.username)")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
  }
}
