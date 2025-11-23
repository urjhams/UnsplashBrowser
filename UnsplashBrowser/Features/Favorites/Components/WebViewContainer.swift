// WebViewContainer.swift
// UIViewRepresentable wrapper for WKWebView

import SwiftUI
import WebKit

/// UIViewRepresentable wrapper for WKWebView with navigation state management
struct WebViewContainer: UIViewRepresentable {
  let url: URL
  @Bindable var state: WebViewStateModel
  let onWebViewCreated: (WKWebView) -> Void
  let onWebViewTitleLoaded: (String?) -> Void

  func makeUIView(context: Context) -> WKWebView {
    let config = WKWebViewConfiguration()
    let webView = WKWebView(frame: .zero, configuration: config)
    webView.navigationDelegate = context.coordinator
    
    // Setup KVO observers for URL and loading changes
    context.coordinator.setupObservers(for: webView)
    
    webView.load(URLRequest(url: url))

    // Pass webView reference back to parent
    Task { @MainActor in
      onWebViewCreated(webView)
    }

    return webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(state: state, onObservedTitleChange: onWebViewTitleLoaded)
  }

  final class Coordinator: NSObject, WKNavigationDelegate {
    @Bindable var state: WebViewStateModel
    private var urlObservation: NSKeyValueObservation?
    private var loadingObservation: NSKeyValueObservation?
    let onObservedTitleChange: (String?) -> Void

    init(state: WebViewStateModel, onObservedTitleChange: @escaping (String?) -> Void = { _ in }) {
      self.state = state
      self.onObservedTitleChange = onObservedTitleChange
    }
    
    deinit {
      urlObservation?.invalidate()
      loadingObservation?.invalidate()
    }
    
    func setupObservers(for webView: WKWebView) {
      // Observe URL changes (catches JavaScript navigation)
      urlObservation = webView.observe(\.url, options: [.new]) { [weak self] webView, _ in
        self?.updateNavigationState(for: webView)
        self?.onObservedTitleChange(webView.title)
      }
      
      // Observe loading state
      loadingObservation = webView.observe(\.isLoading, options: [.new]) { [weak self] webView, change in
        guard let self = self else { return }
        self.state.isLoading = change.newValue ?? false
        if !(change.newValue ?? false) {
          self.updateNavigationState(for: webView)
        }
      }
    }
    
    private func updateNavigationState(for webView: WKWebView) {
      // Only update if values actually changed
      let newCanGoBack = webView.canGoBack
      let newCanGoForward = webView.canGoForward
      
      if state.canGoBack != newCanGoBack || state.canGoForward != newCanGoForward {
        state.canGoBack = newCanGoBack
        state.canGoForward = newCanGoForward
      }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      state.isLoading = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      state.isLoading = false
      updateNavigationState(for: webView)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
      state.isLoading = false
    }
  }
}
