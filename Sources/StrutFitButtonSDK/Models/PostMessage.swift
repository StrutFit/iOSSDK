//
//  PostMessage.swift
//  StrutFitButtonSDK
//
//  Created by Jake Thomas on 29/11/2024.
//

public class PostMessageInitialAppInfoDto: Encodable {

    // Initializer
    public init(productCode: String, organizationUnitId: Int, isKids: Bool, productType: ProductType, defaultSizeUnit: SizeUnit?, defaultApparelSizeUnit: String?, onlineScanInstructionsType: OnlineScanInstructionsType) {
        self.productId = productCode;
        self.organizationUnitId = organizationUnitId;
        self.productType = productType.rawValue;
        self.isKids = isKids;
        self.defaultSizeUnit = defaultSizeUnit?.rawValue;
        self.defaultApparelSizeUnit = defaultApparelSizeUnit;
        self.onlineScanInstructionsType = onlineScanInstructionsType.rawValue;
        self.hideSizeGuide = true;
        self.hideUsualSize = true;
        self.inApp = true;
        self.strutfitMessageType = PostMessageType.InitialAppInfo.rawValue
    }
    
    var strutfitMessageType: Int
    var productType: Int
    var isKids: Bool
    var organizationUnitId: Int
    var onlineScanInstructionsType: Int
    var productId: String
    var defaultSizeUnit: Int?
    var defaultApparelSizeUnit: String?
    var hideSizeGuide: Bool
    var hideUsualSize: Bool
    var inApp: Bool
}

public class PostMessageUpdateThemeDto: Encodable {
    // Initializer
    public init(themeData: JSON) {
        self.strutfitMessageType = PostMessageType.UpdateTheme.rawValue
        self.theme = themeData
    }
    
    var strutfitMessageType: Int
    var theme: JSON
}
