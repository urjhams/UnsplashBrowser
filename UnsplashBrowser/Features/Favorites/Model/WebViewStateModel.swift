// WebViewStateModel.swift
// Observable state model for WebView navigation and loading

import Foundation

/// Observable state model managing WebView navigation and loading state
@Observable
final class WebViewStateModel {
  var canGoBack = false
  var canGoForward = false
  var isLoading = false
}
