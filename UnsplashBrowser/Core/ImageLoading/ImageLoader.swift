// ImageLoader.swift
// Protocol for image loading with caching

import Foundation
import SwiftUI
import UIKit

/// Protocol defining the image loading interface
protocol ImageLoader {
    /// Loads an image from the given URL
    /// - Parameter url: The URL of the image to load
    /// - Returns: The loaded image
    func loadImage(from url: URL) async throws -> UIImage
}
