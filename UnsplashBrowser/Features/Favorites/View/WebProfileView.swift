// WebProfileView.swift
// SwiftUI view with WebView for author profiles

import SwiftUI
import WebKit

/// View displaying an author's Unsplash profile in a web view.
/// Provides navigation controls and share functionality.
struct WebProfileView: View {

  let author: FavoriteAuthor

  @State private var webViewStore = WebViewStore()
  @State private var isLoading = false

  // MARK: - Body

  var body: some View {
    ZStack {
      if let url = author.url, let profileURL = URL(string: url) {
        WebView(
          url: profileURL,
          webViewStore: webViewStore,
          isLoading: $isLoading
        )
        .ignoresSafeArea(edges: .bottom)

        if isLoading {
          ProgressView()
        }
      } else {
        errorView
      }
    }
    .navigationTitle(author.name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItemGroup(placement: .bottomBar) {
        toolbarContent
      }
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
      webViewStore.goBack()
    } label: {
      Image(systemName: "chevron.left")
    }
    .disabled(!webViewStore.canGoBack)

    Button {
      webViewStore.goForward()
    } label: {
      Image(systemName: "chevron.right")
    }
    .disabled(!webViewStore.canGoForward)

    Spacer()

    Button {
      webViewStore.reload()
    } label: {
      Image(systemName: "arrow.clockwise")
    }

    Spacer()

    if let url = author.url, let shareURL = URL(string: url) {
      ShareLink(item: shareURL) {
        Image(systemName: "square.and.arrow.up")
      }
    }
  }
}

// MARK: - WebView

/// UIViewRepresentable wrapper for WKWebView
private struct WebView: UIViewRepresentable {
  let url: URL
  let webViewStore: WebViewStore
  @Binding var isLoading: Bool

  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    webView.navigationDelegate = context.coordinator
    webViewStore.webView = webView
    return webView
  }

  func updateUIView(_ webView: WKWebView, context: Context) {
    if webView.url == nil {
      let request = URLRequest(url: url)
      webView.load(request)
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(isLoading: $isLoading, webViewStore: webViewStore)
  }

  class Coordinator: NSObject, WKNavigationDelegate {
    @Binding var isLoading: Bool
    let webViewStore: WebViewStore

    init(isLoading: Binding<Bool>, webViewStore: WebViewStore) {
      self._isLoading = isLoading
      self.webViewStore = webViewStore
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      isLoading = true
      webViewStore.updateNavigationState()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      isLoading = false
      webViewStore.updateNavigationState()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
      isLoading = false
    }
  }
}

// MARK: - WebViewStore

/// Observable store managing WKWebView state and navigation
@Observable
class WebViewStore {
  weak var webView: WKWebView?

  var canGoBack = false
  var canGoForward = false

  func goBack() {
    webView?.goBack()
  }

  func goForward() {
    webView?.goForward()
  }

  func reload() {
    webView?.reload()
  }

  func updateNavigationState() {
    canGoBack = webView?.canGoBack ?? false
    canGoForward = webView?.canGoForward ?? false
  }
}
