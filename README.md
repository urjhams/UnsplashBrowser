# UnsplashBrowser

## Tech stack

- SwiftUI
- MVVM
- Actors for concurrency correctness
- SwiftInject for dependency injection (DI)
- NavigationStack & NavigationSplitView
- Async/await networking
- LazyVGrid + image caching
- AppStorage/UserDefaults for persistence
- WebView

## Structure

```plaintext
      UnsplashBrowser/
      │
      ├─ App/
      │   ├─ UnsplashBrowserApp.swift
      │   │     • App entry point
      │   │     • Injects DI container into environment
      │   │
      │   ├─ DIContainer.swift
      │   │     • SwiftInject container setup
      │   │     • Registers:
      │   │         - UnsplashAPIClient (protocol) → Impl (actor)
      │   │         - ImageLoader (protocol) → Impl (actor)
      │   │         - FavoriteAuthorsStore (@Observable singleton)
      │   │
      │   └─ EnvironmentValues+Resolver.swift
      │         • Defines EnvironmentKey for DI resolver
      │         • Allows @Environment(\.resolver) in views
      │
      │
      ├─ Core/
      │   │
      │   ├─ Networking/
      │   │   ├─ UnsplashAPIClient.swift
      │   │   │     • PROTOCOL
      │   │   │     • Abstracts searchPhotos()
      │   │   │
      │   │   └─ UnsplashAPIClientImpl.swift
      │   │         • ACTOR
      │   │         • Implements API calls
      │   │         • Handles rate-limiting & throttling
      │   │         • Uses URLSession + async/await
      │   │
      │   │
      │   ├─ ImageLoading/
      │   │   ├─ ImageLoader.swift
      │   │   │     • PROTOCOL
      │   │   │     • Defines loadImage(from:)
      │   │   │
      │   │   └─ ImageLoaderImpl.swift
      │   │         • ACTOR
      │   │         • Shared instance across app via DI
      │   │         • Stores NSCache
      │   │         • Dedupes network tasks using ongoingTasks dict
      │   │         • Ensures no data races in cache access
      │   │
      │   │
      │   └─ Favorites/
      │       └─ FavoriteAuthorsStore.swift
      │             • @Observable CLASS
      │             • Uses UserDefaults to persist favorite authors
      │             • Stores array of FavoriteAuthor (Codable)
      │             • Provides toggleFavorite(), isFavorite()
      │
      │
      ├─ Features/
      │   │
      │   ├─ Search/
      │   │   ├─ SearchPhotosViewModel.swift
      │   │   │     • @Observable CLASS
      │   │   │     • Uses UnsplashAPIClient + ImageLoader
      │   │   │     • Handles debounce, pagination, loading states
      │   │   │
      │   │   ├─ SearchPhotosView.swift
      │   │   │     • SwiftUI VIEW
      │   │   │     • Contains LazyVGrid
      │   │   │     • Triggers pagination via onAppear
      │   │   │
      │   │   ├─ PhotoDetailView.swift
      │   │   │     • SwiftUI VIEW
      │   │   │     • Loads full image via ImageLoader
      │   │   │     • Shows author attribution, metadata, ❤️ toggle
      │   │   │
      │   │   └─ RemoteImageView.swift
      │   │         • SwiftUI VIEW
      │   │         • Uses ImageLoader protocol
      │   │         • Placeholder → loading → image
      │   │         • Fully async/await + .task
      │   │
      │   │
      │   └─ Favorites/
      │       ├─ FavoritesRootView.swift
      │       │     • SwiftUI VIEW
      │       │     • On iPad -> NavigationSplitView
      │       │     • On iPhone -> NavigationStack
      │       │     • Controls selectedAuthor
      │       │
      │       ├─ FavoriteAuthorsViewModel.swift
      │       │     • @Observable CLASS
      │       │     • Optional: if any logic (can be skipped)
      │       │     • The store alone may be enough
      │       │
      │       ├─ FavoriteAuthorsView.swift
      │       │     • SwiftUI VIEW
      │       │     • List of FavoriteAuthor
      │       │     • Tapping selects author (for split view)
      │       │
      │       └─ WebProfileView.swift
      │             • SwiftUI VIEW
      │             • Uses SwiftUI WebView (WebPage)
      │             • Provides back/forward/refresh/share tools
      │
      │
      └─ Tests/
      ├─ MockURLProtocol.swift
      │     • Intercepts URLSession requests
      │     • Used to test API client + image loader without network
      │
      ├─ UnsplashAPIClientTests.swift
      │     • Unit tests for API success, failure, decoding
      │     • Tests rate-limit handling
      │
      ├─ ImageLoaderTests.swift
      │     • Tests cache hits/misses
      │     • Tests dedupe logic of tasks
      │     • Ensures no duplicate downloads
      │
      ├─ SearchPhotosViewModelTests.swift
      │     • Tests search debounce
      │     • Tests pagination trigger
      │     • Tests empty/error states
      │
      └─ FavoriteAuthorsStoreTests.swift
            • Tests toggle behavior
            • Tests JSON persistence
            • Tests id-based uniqueness
```

## App Flow

```plaintext
      [Launch App]
      │
      ▼
      [TabView]
      │
      ├───────────▶ Search Tab
      │                │
      │                ▼
      │        User types keyword
      │                │
      │            Debounced
      │                │
      │      UnsplashAPI.searchPhotos()
      │                ▼
      │       SwiftUI Grid appears
      │                │
      │      RemoteImageView loads thumbs
      │                │
      │        Tap → PhotoDetailView
      │                │
      │          Favorite author
      │                ▼
      └──▶ FavoriteAuthorsStore updates
                        │
                        ▼
                  Favorites Tab
                        │
                        ▼
            NavigationSplitView (iPad)
                  │                 │
      Authors List          WebProfileView
```

## Search Image pipline

```plaintext
      User searches "cat"
            ↓
      Debounced request
            ↓
      API returns n photos
            ↓
      SwiftUI LazyVGrid builds n cells
            ↓
      Each cell runs RemoteImageView(url)
            ↓
      RemoteImageView → ImageLoader.loadImage(url)
            ↓
      ImageLoader actor:
      - check cache
      - check ongoing tasks
      - spawn network task if needed
            ↓
      Parallel CDN downloads
            ↓
      UI updates with thumbnails
```

## Image loading lifecycle

```plaintext
      RemoteImageView
            │  load() triggered by .task on appear
            ▼
      ImageLoader actor
            │   ┌──────────────┐
            ├──▶│ Cache hit?   │──► return cached image
            │   └──────────────┘
            │
            │   ┌──────────────┐
            ├──▶│ Task exists? │──► await shared task
            │   └──────────────┘
            │
            ▼
      Create new Task → URLSession.data(from:)
            │
            ▼
      Decode image + cache
            │
            ▼
      RemoteImageView updates UI
```
