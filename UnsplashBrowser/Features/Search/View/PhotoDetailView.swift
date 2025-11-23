// PhotoDetailView.swift
// SwiftUI view for photo details and author attribution

import SwiftUI
import Swinject

/// View displaying detailed information about a selected photo.
/// Shows the photo image, author information, description, and metadata.
/// Supports favoriting authors with persistent storage.
struct PhotoDetailView: View {
  // MARK: - Properties

  let photo: UnsplashPhoto

  @Environment(\.resolver) private var resolver
  @Environment(\.isRunningOniPad) private var isIpad
  @Environment(\.dismiss) private var dismiss
  @Environment(\.favoriteAuthorsStore) private var favoriteStore
  @Environment(\.imageLoader) private var imageLoader

  @State private var isFavorite = false

  // MARK: - Constants

  private enum Layout {
    static let profileImageSize: CGFloat = 50
    static let iPadCornerRadius: CGFloat = 4
    static let defaultCornerRadius: CGFloat = 2
    static let contentSpacing: CGFloat = 16
    static let authorSpacing: CGFloat = 12
    static let metadataSpacing: CGFloat = 8
  }

  // MARK: - Body

  var body: some View {
    GeometryReader { geometry in
      ScrollView {
        VStack(alignment: .leading, spacing: Layout.contentSpacing) {
          photoImageView(width: geometry.size.width)

          metadataSection
            .padding(.horizontal)
            .padding(.bottom)
        }
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .scrollIndicators(.never)
    .task {
      await initializeFavoriteStore()
    }
  }
}

extension PhotoDetailView {
  // MARK: - View Components

  /// Main photo image view with dynamic height based on aspect ratio
  private func photoImageView(width: CGFloat) -> some View {
    Group {
      if let url = URL(string: photo.urls.regular) {
        RemoteImageView(url: url)
          .frame(width: width)
          .frame(height: calculateImageHeight(for: width))
          .clipShape(
            RoundedRectangle(
              cornerRadius: isIpad ? Layout.iPadCornerRadius : Layout.defaultCornerRadius
            )
          )
      }
    }
  }

  /// Complete metadata section including author info, description, and stats
  private var metadataSection: some View {
    VStack(alignment: .leading, spacing: Layout.authorSpacing) {
      AuthorInfoView(
        author: photo.user,
        isFavorite: isFavorite,
        onToggleFavorite: toggleFavorite
      )
      
      Divider()
      
      photoDescriptionView
      
      photoMetadataView
    }
  }

  /// Photo description text if available
  @ViewBuilder
  private var photoDescriptionView: some View {
    if let description = photo.description {
      Text(description)
        .font(.body)
    }
  }

  /// Photo metadata (dimensions, likes, creation date)
  private var photoMetadataView: some View {
    VStack(alignment: .leading, spacing: Layout.metadataSpacing) {
      MetadataRow(
        label: "Dimensions",
        value: "\(photo.width) × \(photo.height)"
      )
      MetadataRow(
        label: "Likes",
        value: "\(photo.likes)"
      )
      if let createdDate = formatDate(photo.createdAt) {
        MetadataRow(
          label: "Created",
          value: createdDate
        )
      }
    }
  }

}

extension PhotoDetailView {
  // MARK: - Private Methods

  /// Initializes the favorite store and updates favorite status
  private func initializeFavoriteStore() async {
    updateFavoriteStatus()
  }

  /// Calculates the appropriate image height based on photo aspect ratio
  /// - Parameter width: The desired width for the image
  /// - Returns: The calculated height maintaining the original aspect ratio
  private func calculateImageHeight(for width: CGFloat) -> CGFloat {
    let aspectRatio = CGFloat(photo.height) / CGFloat(photo.width)
    return width * aspectRatio
  }

  /// Updates the favorite status from the store
  private func updateFavoriteStatus() {
    isFavorite = favoriteStore?.isFavorite(photo.user.id) ?? false
  }

  /// Toggles the favorite status for the current photo's author
  private func toggleFavorite() {
    withAnimation(.default.speed(1.5)) {
      let author = photo.user.toFavoriteAuthor()
      favoriteStore?.toggleFavorite(author)
      updateFavoriteStatus()
    }
  }

  /// Formats an ISO8601 date string to a user-friendly display format
  /// - Parameter dateString: ISO8601 formatted date string
  /// - Returns: Formatted date string or nil if parsing fails
  private func formatDate(_ dateString: String) -> String? {
    let isoFormatter = ISO8601DateFormatter()
    guard let date = isoFormatter.date(from: dateString) else {
      return nil
    }

    let displayFormatter = DateFormatter()
    displayFormatter.dateStyle = .medium
    displayFormatter.timeStyle = .none
    return displayFormatter.string(from: date)
  }
}

// MARK: - Helper Views

private struct MetadataRow: View {
  let label: String
  let value: String

  var body: some View {
    HStack {
      Text(label)
        .font(.subheadline)
        .foregroundStyle(.secondary)
      Text(value)
        .font(.subheadline)
    }
  }
}
