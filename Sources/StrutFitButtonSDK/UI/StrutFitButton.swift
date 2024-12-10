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
        ///   - sizeUnit: An optional parameter for the size unit to use when sizing (useful when you sell the same product in different regions).
    public init(productCode: String, organizationUnitId: Int, sizeUnit: String? = nil) {
        self.viewModel = StrutFitButtonViewModel(productCode: productCode, organizationUnitId: organizationUnitId, sizeUnit: sizeUnit)
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
