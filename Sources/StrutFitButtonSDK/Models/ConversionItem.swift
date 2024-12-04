//
//  ConversionItem.swift
//
//
//  Created by StrutFit Admin on 11/02/22.
//

import Foundation

public struct ConversionItem : Codable {
    
    public init(productIdentifier: String,
                price: Float, quantity: Int, size: String,
                sizeUnit: String? = nil, sku: String? = nil) {
        self.sku = sku
        self.productIdentifier = productIdentifier
        self.price = price
        self.quantity = quantity
        self.size = size
        self.sizeUnit = sizeUnit
    }

    public let sku: String?;
    
    public let productIdentifier: String;

    public let price: Float;
    
    public let quantity: Int;

    public let size: String;
    
    public let sizeUnit: String?;
}
