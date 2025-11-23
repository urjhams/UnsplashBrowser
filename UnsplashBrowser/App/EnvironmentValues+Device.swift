//  EnvironmentValues+Device.swift
//  UnsplashBrowser

import SwiftUI
import UIKit

private struct IsRunningOniPadKey: EnvironmentKey {
  static let defaultValue: Bool = UIDevice.current.userInterfaceIdiom == .pad
}

extension EnvironmentValues {
  var isRunningOniPad: Bool {
    get {
      self[IsRunningOniPadKey.self]
    }
    set {
      self[IsRunningOniPadKey.self] = newValue
    }
  }
}
