//
//  File.swift
//  
//
//  Created by StrutFit Admin on 11/02/22.
//

import Foundation

public struct ConversionItem: Codable {
    
    public init(sku: String, productIdentifier: String,
                price: Float, quantity: Int, size: String) {
        self.sku = sku
        self.productIdentifier = productIdentifier
        self.price = price
        self.quantity = quantity
        self.size = size
    }

    public let sku: String ;
    
    public let productIdentifier: String ;

    public let price: Float ;
    
    public let quantity: Int

    public let size: String ;
}
