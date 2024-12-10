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
    
    /// Initializes the button with required parameters.
        /// - Parameters:
        ///   - productCode: A unique string representing the product.
        ///   - organizationUnitId: An integer representing the organization unit.
        ///   - sizeUnit: An optional parameter for the size unit to use when sizing (useful when you sell the same product in different regions).
    public init(productCode: String, organizationUnitId: Int, sizeUnit: String? = nil) {
        self.productCode = productCode
        self.organizationUnitId = organizationUnitId
        self.sizeUnit = sizeUnit
    }
    
    public func makeUIView(context: Context) -> StrutFitButton {
        let button = StrutFitButton(productCode: productCode, organizationUnitId: organizationUnitId, sizeUnit: sizeUnit)
        return button
    }
    
    public func updateUIView(_ uiView: StrutFitButton, context: Context) {
        // Handle updates to the view if needed
    }
}
