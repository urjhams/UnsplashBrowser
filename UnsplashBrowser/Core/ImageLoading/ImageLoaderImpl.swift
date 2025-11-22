// ImageLoaderImpl.swift
// Actor implementation of ImageLoader with caching and deduplication

import Foundation
import UIKit

actor ImageLoaderImpl: ImageLoader {
  private let session: URLSession
  nonisolated(unsafe) private let cache: NSCache<NSURL, UIImage> = {
    let cache = NSCache<NSURL, UIImage>()
    cache.countLimit = 1000  // Maximum 1000 images
    cache.totalCostLimit = 640 * 1024 * 1024  // 640 MB
    return cache
  }()
  private var ongoingTasks: [URL: Task<UIImage, Error>] = [:]

  init(session: URLSession = .shared) {
    self.session = session
  }

  func loadImage(from url: URL) async throws -> UIImage {
    // Check cache first
    if let cachedImage = cache.object(forKey: url as NSURL) {
      return cachedImage
    }

    // Check if there's an ongoing task for this URL (deduplication)
    if let existingTask = ongoingTasks[url] {
      return try await existingTask.value
    }

    // Create new task for loading image
    let task = Task<UIImage, Error> {
      let (data, response) = try await session.data(from: url)

      // Validate HTTP response
      guard let httpResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode)
      else {
        throw URLError(.badServerResponse)
      }

      // Decode image from data
      guard let image = UIImage(data: data) else {
        throw NSError(
          domain: "ImageLoader",
          code: -1,
          userInfo: [
            NSLocalizedDescriptionKey: "Failed to decode image"
          ]
        )
      }

      return image
    }

    // Store task for deduplication
    ongoingTasks[url] = task

    do {
      let image = try await task.value

      // Cache the loaded image
      cache.setObject(image, forKey: url as NSURL)

      // Remove task from ongoing tasks
      ongoingTasks.removeValue(forKey: url)

      return image
    } catch {
      // Remove task on error
      ongoingTasks.removeValue(forKey: url)
      throw error
    }
  }
}
