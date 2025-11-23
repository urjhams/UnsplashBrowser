// WebProfileView.swift
// SwiftUI view with WebView for author profiles

import SwiftUI
import WebKit

/// View displaying an author's Unsplash profile in a web view.
/// Provides navigation controls and share functionality.
struct WebProfileView: View {
  // MARK: - Properties

  let author: FavoriteAuthor

  @State private var state = WebViewStateModel()
  @State private var webView: WKWebView?
  @State private var title = ""

  // MARK: - Body

  var body: some View {
    ZStack {
      if let url = author.url, let profileURL = URL(string: url) {
        WebViewContainer(
          url: profileURL,
          state: state,
          onWebViewCreated: handleWebViewCreated,
          onWebViewTitleLoaded: handleTitleLoaded
        )
        .ignoresSafeArea(edges: .bottom)

        if state.isLoading {
          ProgressView()
        }
      } else {
        errorView
      }
    }
    .navigationTitle(title)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItemGroup(placement: .bottomBar) {
        toolbarContent
      }
    }
    .task {
      title = author.name
    }
  }
  
  /// Handles the webView instance when it's created
  private func handleWebViewCreated(_ webViewRef: WKWebView) {
    Task { @MainActor in
      webView = webViewRef
    }
  }
  
  /// Handles title changes from the webView
  private func handleTitleLoaded(_ loadedTitle: String?) {
    let newTitle = loadedTitle ?? author.name
    Task { @MainActor in
      title = newTitle
    }
  }
  
  // MARK: - View Components

  /// Error state when URL is invalid
  private var errorView: some View {
    ContentUnavailableView(
      "Profile Unavailable",
      systemImage: "exclamationmark.triangle",
      description: Text("Unable to load profile for \(author.name)")
    )
  }

  /// Toolbar buttons for web navigation
  @ViewBuilder
  private var toolbarContent: some View {
    Button {
      webView?.goBack()
    } label: {
      Image(systemName: "chevron.left")
    }
    .disabled(!state.canGoBack)

    Button {
      webView?.goForward()
    } label: {
      Image(systemName: "chevron.right")
    }
    .disabled(!state.canGoForward)

    Spacer()

    Button {
      webView?.reload()
    } label: {
      Image(systemName: "arrow.clockwise")
    }

    Spacer()

    if let url = webView?.url {
      ShareLink(item: url) {
        Image(systemName: "square.and.arrow.up")
      }
    }
  }
}
