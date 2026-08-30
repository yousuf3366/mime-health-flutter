import Flutter
import IntelliProveSDK
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var webviewChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Must match the channel name used from Dart.
    let channel = FlutterMethodChannel(
      name: "com.intelliprove/webview",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    webviewChannel = channel

    channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "openWebview":
        guard
          let args = call.arguments as? [String: Any],
          let urlString = args["url"] as? String
        else {
          result(
            FlutterError(
              code: "INVALID_ARGS",
              message: "Expected { url: String }",
              details: nil
            )
          )
          return
        }
        self?.openWebView(urlString: urlString)
        result(nil)

      case "closeWebview":
        self?.closeWebView()
        result(nil)

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  /// Creates an IntelliProve web view from [urlString] and presents it full screen.
  private func openWebView(urlString: String) {
    let webViewController = IntelliWebViewFactory.newWebView(
      urlString: urlString,
      delegate: self
    )
    webViewController.modalPresentationStyle = .fullScreen

    DispatchQueue.main.async { [weak self] in
      guard let presenter = self?.topViewController() else { return }
      presenter.present(webViewController, animated: true)
    }
  }

  /// Dismisses the presented IntelliProve web view (e.g. on `recordingStopped`).
  private func closeWebView() {
    DispatchQueue.main.async { [weak self] in
      guard let top = self?.topViewController(), top.presentingViewController != nil else {
        return
      }
      top.dismiss(animated: true)
    }
  }

  private func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let window =
      scenes.flatMap(\.windows).first(where: \.isKeyWindow)
      ?? scenes.first?.windows.first
      ?? self.window

    var top = window?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }
}

/// Forwards IntelliProve PostMessage API events to Flutter.
extension AppDelegate: IntelliWebViewDelegate {
  func didReceive(postMessage: String) {
    webviewChannel?.invokeMethod("didReceivePostMessage", arguments: postMessage)
  }
}
