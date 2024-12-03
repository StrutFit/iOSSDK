//
//  PixelData.swift
//
//
//  Created by StrutFit Admin on 11/02/22.
//

import Foundation

    
    public init(organizationUnitId: Int,
                orderRef: String, orderValue: Float, userId: String?,
                footScanMCode: String?, bodyScanMCode: String?,
                items: String, currencyCode: String, domain: String,
                isMobile: Bool, emailHash: Int32?) {
        self.organizationUnitId = organizationUnitId
        self.orderRef = orderRef
        self.orderValue = orderValue
        self.userId = userId
        self.footScanMCode = footScanMCode
        self.bodyScanMCode = bodyScanMCode
        self.items = items
        self.currencyCode = currencyCode
        self.domain = domain
        self.isMobile = isMobile
        self.emailHash = emailHash
    }
    
    public let organizationUnitId: Int

    public let orderRef: String;

    public let orderValue: Float;

    public let userId: String?;

    public let footScanMCode: String?;

    public let bodyScanMCode: String?;

    public let items: String;

    public let currencyCode: String;

    public let domain: String;
    
    public let isMobile: Bool;

    public let emailHash: Int32?;
    
}

