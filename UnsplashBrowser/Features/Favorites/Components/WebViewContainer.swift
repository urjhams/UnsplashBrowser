// WebViewContainer.swift
// UIViewRepresentable wrapper for WKWebView

import SwiftUI
import WebKit

/// UIViewRepresentable wrapper for WKWebView with navigation state management
struct WebViewContainer: UIViewRepresentable {
  let url: URL
  @Bindable var state: WebViewStateModel
  let onWebViewCreated: (WKWebView) -> Void

  func makeUIView(context: Context) -> WKWebView {
    let config = WKWebViewConfiguration()
    let webView = WKWebView(frame: .zero, configuration: config)
    webView.navigationDelegate = context.coordinator
    webView.load(URLRequest(url: url))

    // Pass webView reference back to parent
    Task { @MainActor in
      onWebViewCreated(webView)
    }

    return webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(state: state)
  }

  final class Coordinator: NSObject, WKNavigationDelegate {
    @Bindable var state: WebViewStateModel

    init(state: WebViewStateModel) {
      self.state = state
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      state.isLoading = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      state.isLoading = false
      state.canGoBack = webView.canGoBack
      state.canGoForward = webView.canGoForward
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
      state.isLoading = false
    }
  }
}
