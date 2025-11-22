// DIContainer.swift

import Swinject

struct AppDIContainer {
  static func build() -> Resolver {
    let container = Container()

    container
      .register(UnsplashAPIClient.self) { _ in
        UnsplashAPIClientImpl()
      }
      .inObjectScope(.container)

    container
      .register(ImageLoader.self) { _ in
        ImageLoaderImpl()
      }
      .inObjectScope(.container)

    container
      .register(FavoriteAuthorsStore.self) { _ in
        FavoriteAuthorsStore()
      }
      .inObjectScope(.container)

    return container
  }
}
