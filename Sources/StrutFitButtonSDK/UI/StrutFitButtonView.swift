//
//  StrutFitButtonView.swift
//  StrutFitButtonSDK
//
//  Created by Jake Thomas on 10/12/2024.
//

import SwiftUI

public struct StrutFitButtonView: UIViewRepresentable {
    let productCode: String
    let organizationUnitId: Int
    let sizeUnit: String?
    let apparelSizeUnit: String?
    let productName: String
    let productImageURL: String
    
    /// Initializes the button with required parameters.
        /// - Parameters:
        ///   - productCode: A unique string representing the product.
        ///   - organizationUnitId: An integer representing the organization unit.
        ///   - sizeUnit: An optional parameter for the footwear size unit to use when sizing (useful when you sell the same product in different regions).
        ///   - apparelSizeUnit: An optional parameter for the apparel size unit to use when sizing (useful when you sell the same product in different regions).
        ///   - productName: An optional parameter for the product name for you to override if you don't want to use the name in the StrutFit database
        ///   - productImageURL: An optional parameter for the product image URL for you to override if you don't want to use the image URL in the StrutFit database
    public init(productCode: String, organizationUnitId: Int, sizeUnit: String? = nil, apparelSizeUnit: String? = nil, productName: String = "", productImageURL: String = "") {
        self.productCode = productCode
        self.organizationUnitId = organizationUnitId
        self.sizeUnit = sizeUnit
        self.apparelSizeUnit = apparelSizeUnit
        self.productName = productName
        self.productImageURL = productImageURL
    }
    
    public func makeUIView(context: Context) -> StrutFitButton {
        let button = StrutFitButton(productCode: productCode, organizationUnitId: organizationUnitId, sizeUnit: sizeUnit, apparelSizeUnit: apparelSizeUnit, productName: productName, productImageURL: productImageURL)
        return button
    }
    
    public func updateUIView(_ uiView: StrutFitButton, context: Context) {
        // Handle updates to the view if needed
    }
}
