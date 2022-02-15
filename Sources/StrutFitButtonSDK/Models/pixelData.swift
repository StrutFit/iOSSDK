//
//  File.swift
//  
//
//  Created by StrutFit Admin on 11/02/22.
//

import Foundation

public struct PixelData: Codable {
    
    public init(organizationUnitId: Int, sfEnabled: Bool,
                orderRef: String, orderValue: Float, mCode: String,
                items: String, currencyCode: String, domain: String) {
        self.organizationUnitId = organizationUnitId
        self.sfEnabled = sfEnabled
        self.orderRef = orderRef
        self.orderValue = orderValue
        self.mCode = mCode
        self.items = items
        self.currencyCode = currencyCode
        self.domain = domain
    }
    
    public let organizationUnitId: Int

    public let sfEnabled: Bool;

    public let orderRef: String ;

    public let orderValue: Float ;

    public let mCode: String ;

    public let items: String ;

    public let currencyCode: String ;

    public let domain: String ;
    
}
