//
//  WebViewCoordinator.swift
//  StrutFitButtonSDK
//
//  Created by Jake Thomas on 27/11/2024.
//

import UIKit
import WebKit

public class WebViewCoordinator {
    private let url: URL
    private let messageHandler: (String) -> Void
    private var webViewController: WebViewController?

    public init(url: URL, messageHandler: @escaping (String) -> Void) {
        self.url = url
        self.messageHandler = messageHandler
    }

    public func preloadWebView() {
        // Initialize and preload the WebView
        webViewController = WebViewController(url: url, messageHandler: messageHandler)
        _ = webViewController?.view // Force loading the view to ensure WebView is initialized
    }

    public func presentWebView(from viewController: UIViewController?) {
        guard let webViewController = webViewController, let viewController = viewController else {
            return
        }
        viewController.present(webViewController, animated: true)
    }
    
    public func closeWebView() {
        webViewController?.dismiss(animated: true, completion: nil)
    }
    
    public func sendMessageToJavascript(message: String) {
        webViewController?.sendMessageToJavascript(message: message)
    }
}

