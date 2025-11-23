// PhotoDetailView.swift
// SwiftUI view for photo details and author attribution

import SwiftUI
import Swinject

struct PhotoDetailView: View {
  let photo: UnsplashPhoto
  let imageLoader: ImageLoader

  @Environment(\.resolver) private var resolver
  @Environment(\.isRunningOniPad) private var isIpad
  @Environment(\.dismiss) private var dismiss
  

  @State private var favoriteStore: FavoriteAuthorsStore?

  private var isFavorite: Bool {
    favoriteStore?.isFavorite(photo.user.id) ?? false
  }

  var body: some View {
    GeometryReader { geometry in
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          // Main image
          if let url = URL(string: photo.urls.regular) {
            RemoteImageView(url: url, imageLoader: imageLoader)
              .frame(width: geometry.size.width)
              .frame(height: calculateImageHeight(for: geometry.size.width))
              .clipShape(RoundedRectangle(cornerRadius: isIpad ? 12 : 8))
          }
         
          // Metadata section
          VStack(alignment: .leading, spacing: 12) {
            // Author info
            HStack(spacing: 12) {
              if let userImageURL = URL(string: photo.user.profileImages.large) {
                RemoteImageView(url: userImageURL, imageLoader: imageLoader)
                  .frame(width: 50, height: 50)
                  .clipShape(Circle())
              }

              VStack(alignment: .leading, spacing: 4) {
                Text(photo.user.name)
                  .font(.headline)
                Text("@\(photo.user.username)")
                  .font(.subheadline)
                  .foregroundStyle(.secondary)
              }

              Spacer()

              Button {
                toggleFavorite()
              } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                  .font(.title2)
                  .foregroundStyle(isFavorite ? .red : .primary)
                  .contentTransition(.symbolEffect(.replace))
              }
            }

            Divider()

            // Photo description
            if let description = photo.description {
              Text(description)
                .font(.body)
            }

            // Photo metadata
            VStack(alignment: .leading, spacing: 8) {
              MetadataRow(label: "Dimensions", value: "\(photo.width) × \(photo.height)")
              MetadataRow(label: "Likes", value: "\(photo.likes)")
              if let createdDate = formatDate(photo.createdAt) {
                MetadataRow(label: "Created", value: createdDate)
              }
              if let color = photo.color {
                HStack {
                  Text("Color")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                  Spacer()
                  RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: color))
                    .frame(width: 30, height: 30)
                    .overlay(
                      RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                    )
                }
              }
            }
          }
          .padding(.horizontal)
          .padding(.bottom)
        }
      }
    }
    .navigationTitle("Photo Details")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      if favoriteStore == nil {
        favoriteStore = resolver.resolve(FavoriteAuthorsStore.self)
      }
    }
  }

  private func calculateImageHeight(for width: CGFloat) -> CGFloat {
    let aspectRatio = CGFloat(photo.height) / CGFloat(photo.width)
    return width * aspectRatio
  }

  private func toggleFavorite() {
    let author = photo.user.toFavoriteAuthor()
    favoriteStore?.toggleFavorite(author)
  }

  private func formatDate(_ dateString: String) -> String? {
    let isoFormatter = ISO8601DateFormatter()
    guard let date = isoFormatter.date(from: dateString) else { return nil }

    let displayFormatter = DateFormatter()
    displayFormatter.dateStyle = .medium
    displayFormatter.timeStyle = .none
    return displayFormatter.string(from: date)
  }
}

// MARK: - Helper Views

struct MetadataRow: View {
  let label: String
  let value: String

  var body: some View {
    HStack {
      Text(label)
        .font(.subheadline)
        .foregroundStyle(.secondary)
      Spacer()
      Text(value)
        .font(.subheadline)
    }
  }
}
