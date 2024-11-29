//
//  PostMessages.swift
//  StrutFitButtonSDK
//
//  Created by Jake Thomas on 29/11/2024.
//

public class PostMessageInitialAppInfoDto: Encodable {

    // Initializer
    public init(productCode: String, organizationUnitId: Int) {
        self.productId = productCode;
        self.organizationUnitId = organizationUnitId;
        self.hideSizeGuide = true;
        self.inApp = true;
        self.strutfitMessageType = PostMessageType.InitialAppInfo.rawValue
    }
    
    var strutfitMessageType: Int
    var productType: Int = 0
    var isKids: Bool = false
    var organizationUnitId: Int
    var onlineScanInstructionsType: Int = 0
    var productId: String
    var language: Int = 0
    var defaultUnit: Int = 0
    var hideSizeGuide: Bool
    var inApp: Bool
}
