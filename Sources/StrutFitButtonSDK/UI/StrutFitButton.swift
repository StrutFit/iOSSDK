//
//  StrutFitButton.swift
//  StrutFitButtonSDK
//
//  Created by Jake Thomas on 27/11/2024.
//

import UIKit
import AVFoundation

public class StrutFitButton: UIButton {
    private let viewModel: StrutFitButtonViewModel
    private var coordinator: WebViewCoordinator?
    
    /// Initializes the button with required parameters.
        /// - Parameters:
        ///   - productCode: A unique string representing the product.
        ///   - organizationUnitId: An integer representing the organization unit.
        ///   - sizeUnit: An optional parameter for the footwear size unit to use when sizing (useful when you sell the same product in different regions).
        ///   - apparelSizeUnit: An optional parameter for the apparel size unit to use when sizing (useful when you sell the same product in different regions).
    public init(productCode: String, organizationUnitId: Int, sizeUnit: String? = nil, apparelSizeUnit: String? = nil, productName: String = "", productImageURL: String = "") {
        self.viewModel = StrutFitButtonViewModel(productCode: productCode, organizationUnitId: organizationUnitId, sizeUnit: sizeUnit, apparelSizeUnit: apparelSizeUnit, productName: productName, productImageURL: productImageURL)
        super.init(frame: .zero)
        setupButton()
        bindViewModel()
        viewModel.getSizeAndVisibility(footMeasurementCode: CommonHelper.getLocalFootMCode(), bodyMeasurementCode: CommonHelper.getLocalBodyMCode(), isInitializing: true)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var intrinsicContentSize: CGSize {
        guard let titleLabel = titleLabel, let imageView = imageView else {
            return super.intrinsicContentSize
        }
        
        let imageWidth = imageView.frame.size.width
        let labelWidth = bounds.width - contentEdgeInsets.left - contentEdgeInsets.right - imageWidth - imageEdgeInsets.left - imageEdgeInsets.right
        let labelSize = titleLabel.sizeThatFits(CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude))
        
        let height = max(imageView.frame.height, labelSize.height) + contentEdgeInsets.top + contentEdgeInsets.bottom
        let width = bounds.width
        return CGSize(width: width, height: height)
    }

    private func setupButton() {
        self.setTitleColor(.black, for: .normal) // Set text color
        self.backgroundColor = UIColor(hex: "#F2F2F2")
        
        self.clipsToBounds = true
        
        // Set padding (contentInsets)
        self.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        // Title setup
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.lineBreakMode = .byWordWrapping
        self.titleLabel?.textAlignment = .left
        
        // Ensure the button resizes based on content
        self.titleLabel?.adjustsFontForContentSizeCategory = true

        // Add image to the button (logo on the left)
        if let image = UIImage(named: "SFButtonLogo", in: Bundle.module, with: nil) {
            let fixedHeight: CGFloat = 24
            let aspectRatio = image.size.width / image.size.height
            
            // Calculate the new width based on the fixed height
            let newWidth = fixedHeight * aspectRatio
            
            let resizedImage = resizeImage(image: image, to: CGSize(width: newWidth, height: fixedHeight))
            
            self.setImage(resizedImage, for: .normal)
            self.imageView?.contentMode = .scaleAspectFit
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16) // Space image from text
        }
    
        self.isHidden = true
        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    private func resizeImage(image: UIImage, to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            switch state {
            case .hidden:
                self?.isHidden = true
            case .initialize(let url):
                self?.isHidden = true
                self?.preloadWebView(url: url)
            case .visible(let title):
                DispatchQueue.main.async {
                    self?.setTitle(title, for: .normal)
                    self?.sizeToFit() // Force immediate layout update
                    self?.isHidden = false
                }
            }
        }
        
        viewModel.sendMessageToJavascript = sendMessageToJavascript;
        viewModel.closeWebView = closeWebView;
        viewModel.updateTheme = updateTheme;
    }
    
    func sendMessageToJavascript(message: String) {
        coordinator?.sendMessageToJavascript(message: message)
    }
    
    func closeWebView() {
        coordinator?.closeWebView()
    }
    
    func updateTheme(theme: JSON) {
        let sfButtonThemes = theme["SFButton"].arrayValue
        
        var buttonTheme: JSON?

        // Check if there is a buttonTheme with IsDefault set to true
        if let defaultButtonTheme = sfButtonThemes.first(where: { $0["IsDefault"].boolValue }) {
            // Use the defaultButtonTheme
            buttonTheme = defaultButtonTheme
        } else if let firstButtonTheme = sfButtonThemes.first {
            // Fallback to the first buttonTheme
            buttonTheme = firstButtonTheme
        } else {
            return;
        }
        
        if let theme = buttonTheme {
            // Set the button's text color if SFButtonText is available
            if let buttonTextColor = theme["Colors"]["SFButtonText"].string, !buttonTextColor.isEmpty {
                self.setTitleColor(UIColor(hex: buttonTextColor), for: .normal)
            }

            // Set the button's background color if SFButtonBackground is available
            if let buttonBackgroundColor = theme["Colors"]["SFButtonBackground"].string, !buttonBackgroundColor.isEmpty {
                self.backgroundColor = UIColor(hex: buttonBackgroundColor)
            }
            
            // Hide the button logo (image view) if HideStrutFitButtonLogo is true
            if theme["HideStrutFitButtonLogo"].boolValue {
                self.setImage(nil, for: .normal)
            }
            
            // Set the font size if PrimaryFontSize is available
            if let primaryFontSize = theme["Fonts"]["PrimaryFontSize"].string, !primaryFontSize.isEmpty {
                if let fontSize = extractFontSize(from: primaryFontSize) {
                    if let titleLabel = titleLabel {
                        titleLabel.font = titleLabel.font.withSize(fontSize)
                    }
                }
            }
        }
    }
    
    private func extractFontSize(from fontSizeString: String) -> CGFloat? {
        let fontSize = fontSizeString.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if let size = Double(fontSize) {
            return CGFloat(size)
        }
        return nil
    }
    
    private func preloadWebView(url: URL) {
        coordinator = WebViewCoordinator(url: url, messageHandler: viewModel.handleMessage)
        coordinator?.preloadWebView()
    }

    @objc private func buttonTapped() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
            DispatchQueue.main.async {
                var strutFitMessageType = PostMessageType.ShowIFrame.rawValue
                let javaScriptCode = "window.callStrutFitFromNativeApp('{\"strutfitMessageType\": \(strutFitMessageType)}')"
                self.coordinator?.sendMessageToJavascript(message: javaScriptCode)
                self.coordinator?.presentWebView(from: self.window?.rootViewController)
            }
        }

    }
}
