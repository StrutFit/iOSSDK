//
//  WebViewController.swift
//  StrutFitButtonSDK
//
//  Created by Jake Thomas on 27/11/2024.
//

import UIKit
import WebKit

public class WebViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    private let webView: WKWebView
    private let url: URL
    private let messageHandler: (String) -> Void

    public init(url: URL, messageHandler: @escaping (String) -> Void) {
        // Create webview
        // Configuration needs to be initialized cannot be changed after (iOS Bug)
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true

        if #available(iOS 14.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            // Fallback on earlier versions
            configuration.preferences.javaScriptEnabled = true
        }
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        self.url = url
        self.messageHandler = messageHandler
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
        self.isModalInPresentation = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        webView.frame = view.bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.configuration.userContentController.add(self, name: "webviewmessagehandler")
        view.addSubview(webView)

        webView.load(URLRequest(url: url))
    }
    
    public func sendMessageToJavascript(message: String) {
        webView.evaluateJavaScript(message) { result, error in
            if let error = error {
                print("Error executing JavaScript: \(error)")
            } else {
                print("JavaScript executed successfully: \(result ?? "No result")")
            }
        }
    }

    // MARK: - WKScriptMessageHandler
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "webviewmessagehandler", let body = message.body as? String {
            messageHandler(body)
        }
    }
    
    // MARK: - WKNavigationDelegate
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("WebView finished loading.")
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WebView failed to load with error: \(error.localizedDescription)")
    }
}
