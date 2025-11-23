// AuthorInfoView.swift
// Reusable component displaying author information with favorite toggle

import SwiftUI

/// View displaying author profile information with a favorite toggle button.
/// Optimized to only re-render when author data or favorite status changes.
struct AuthorInfoView: View {
  // MARK: - Properties

  let author: PhotoUser
  let isFavorite: Bool
  let onToggleFavorite: () -> Void
  
  @Environment(\.imageLoader) private var imageLoader

  // MARK: - Constants

  private enum Layout {
    static let profileImageSize: CGFloat = 50
    static let spacing: CGFloat = 12
    static let nameSpacing: CGFloat = 4
  }

  // MARK: - Body

  var body: some View {
    HStack(spacing: Layout.spacing) {
      authorProfileImage
      authorNameAndUsername
      Spacer()
      favoriteButton
    }
  }

  // MARK: - View Components

  /// Author's profile image
  private var authorProfileImage: some View {
    Group {
      if let userImageURL = URL(string: author.profileImages.large) {
        RemoteImageView(url: userImageURL)
          .frame(width: Layout.profileImageSize, height: Layout.profileImageSize)
          .clipShape(Circle())
      }
    }
  }

  /// Author's name and username display
  private var authorNameAndUsername: some View {
    VStack(alignment: .leading, spacing: Layout.nameSpacing) {
      Text(author.name)
        .font(.headline)
      Text("@\(author.username)")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
  }

  /// Favorite toggle button with animation
  private var favoriteButton: some View {
    Button(action: onToggleFavorite) {
      Image(systemName: isFavorite ? "heart.fill" : "heart")
        .font(.title)
        .foregroundStyle(isFavorite ? .red : .primary)
        .contentTransition(.symbolEffect(.replace.offUp))
    }
  }
}
