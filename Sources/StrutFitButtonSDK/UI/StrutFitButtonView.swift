//
//  StrutFitButtonView.swift
//  StrutFitButtonSDK
//
//  Created by Jake Thomas on 27/11/2024.
//

import UIKit

public class StrutFitButtonView: UIButton {
    private let viewModel: StrutFitButtonViewModel
    private var coordinator: WebViewCoordinator?
    
    /// Initializes the button with required parameters.
        /// - Parameters:
        ///   - productCode: A unique string representing the product.
        ///   - organizationUnitId: An integer representing the organization unit.
    public init(productCode: String, organizationUnitId: Int, frame: CGRect) {
        self.viewModel = StrutFitButtonViewModel(productCode: productCode, organizationUnitId: organizationUnitId)
        super.init(frame: frame)
        setupButton()
        bindViewModel()
        viewModel.getSizeAndVisibility(measurementCode: nil, isInitializing: true)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton() {
        self.setTitle("Loading...", for: .normal)
        self.setTitleColor(.black, for: .normal) // Set text color
        self.backgroundColor = UIColor(hex: "#F2F2F2")
        // Set internal margins (left and right)
        let leftMargin: CGFloat = 8
        let rightMargin: CGFloat = 8
               
        // Apply contentEdgeInsets to add left and right margin
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: leftMargin, bottom: 0, right: rightMargin)
        
        let imageTextGap: CGFloat = 8
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: imageTextGap)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: imageTextGap, bottom: 0, right: 0)
        
        self.titleLabel?.numberOfLines = 0  // Allow unlimited lines for wrapping
        self.titleLabel?.lineBreakMode = .byWordWrapping
        
        // Get the image from assets
        if let image = UIImage(named: "SFButtonLogo", in: Bundle.module, with: nil) {
            // Calculate the new image size based on the button height and margin
            let margin: CGFloat = 10
            let imageHeight = self.frame.height - 2 * margin  // Adjust height with margin
            let aspectRatio = image.size.width / image.size.height
            let imageWidth = imageHeight * aspectRatio  // Maintain the aspect ratio

            // Resize the image to fit the button's height (with margin) while maintaining aspect ratio
            let resizedImage = resizeImage(image: image, to: CGSize(width: imageWidth, height: imageHeight))

            // Set the resized image to the button
            self.setImage(resizedImage, for: .normal)
            
            // Adjust the contentMode for proper scaling
            self.imageView?.contentMode = .scaleAspectFit
        }
        self.isHidden = true
        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    private func resizeImage(image: UIImage, to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? image
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            switch state {
            case .hidden:
                self?.isHidden = true
            case .visible(let title, let url, let isInitializing):
                self?.setTitle(title, for: .normal)
                self?.isHidden = false
                if(isInitializing) {
                    self?.preloadWebView(url: url)
                }
            }
        }
        
        viewModel.sendMessageToJavascript = sendMessageToJavascript;
        viewModel.closeWebView = closeWebView;
    }
    
    func sendMessageToJavascript(message: String) {
        coordinator?.sendMessageToJavascript(message: message)
    }
    
    func closeWebView() {
        coordinator?.closeWebView()
    }
    
    private func preloadWebView(url: URL) {
        coordinator = WebViewCoordinator(url: url, messageHandler: viewModel.handleMessage)
        coordinator?.preloadWebView()
    }

    @objc private func buttonTapped() {
        var strutFitMessageType = PostMessageType.ShowIFrame.rawValue
        let javaScriptCode = "window.callStrutFitFromNativeApp('{\"strutfitMessageType\": \(strutFitMessageType)}')"
        coordinator?.sendMessageToJavascript(message: javaScriptCode)
        coordinator?.presentWebView(from: self.window?.rootViewController)
    }
}
