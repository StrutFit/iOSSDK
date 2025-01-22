//
//  StrutFitButtonViewModel.swift
//  StrutFitButtonSDK
//
//  Created by Jake Thomas on 27/11/2024.
//

import Foundation

public class StrutFitButtonViewModel {
    enum State {
        case hidden
        case initialize(url: URL)
        case visible(title: String)
    }

    private let productCode: String
    private let organizationUnitId: Int
    private let sizeUnit: SizeUnit?
    private let apparelSizeUnit: String?
    private var productName: String
    private var productImageURL: String
    private let webViewURL: URL
    
    private var _isKids: Bool = false
    private var _productType: ProductType = ProductType.Footwear

    private var _useStrutFitProductNameAsFallback: Bool = false
    private var _onlineScanInstructionsType: OnlineScanInstructionsType = OnlineScanInstructionsType.OneFootOnPaper
    private var _brandName: String? = nil
    private var _hideScanning: Bool = false
    private var _hideSizeGuide: Bool = false
    private var _hideUsualSize: Bool = true
    private var _usualSizeMethods: [Int]? = nil
    
    private var preLoginButtonTextAdultsTranslations: [CustomTextValue] = []
    private var preLoginButtonTextKidsTranslations: [CustomTextValue] = []
    private var buttonResultTextTranslations: [CustomTextValue] = []
    private var unavailableSizeText = NSLocalizedString("UnavailableInYourSize", tableName: nil, bundle: .module, value: "", comment: "")
    
    private var themeData: JSON?
    private var useCustomTheme: Bool = false
    
    private var _buttonText = ""
    
    
    private var _client: StrutFitClient
    
    var onStateChange: ((State) -> Void)?
    
    var sendMessageToJavascript: ((String) -> Void)?
    
    var closeWebView: (() -> Void)?
    
    var updateTheme: ((JSON) -> Void)?

    /// Initializes the view model with required parameters.
    /// - Parameters:
    ///   - productCode: A unique string representing the product.
    ///   - organizationUnitId: An integer representing the organization unit.
    ///   - sizeUnit: An optional parameter for the footwear size unit to use when sizing (useful when you sell the same product in different regions).
    ///   - apparelSizeUnit: An optional parameter for the apparel size unit to use when sizing (useful when you sell the same product in different regions).
    init(productCode: String, organizationUnitId: Int, sizeUnit: String?, apparelSizeUnit: String?, productName: String, productImageURL: String) {
        self.productCode = productCode
        self.organizationUnitId = organizationUnitId
        self.sizeUnit = CommonHelper.getSizeUnitEnumFromString(sizeUnit: sizeUnit);
        self.apparelSizeUnit = apparelSizeUnit;
        self.productName = productName;
        self.productImageURL = productImageURL;
        self.webViewURL = URL(string: Constants.baseWebViewUrl)!
        self._client = StrutFitClient()
    }
    
    func getSizeAndVisibility(footMeasurementCode: String?, bodyMeasurementCode: String?, isInitializing: Bool)
    {
        var parameters = ["organizationUnitId": String(organizationUnitId), "code" : productCode, "mcode" : footMeasurementCode ?? "", "bodyMCode" : bodyMeasurementCode ?? ""];
        if(sizeUnit != nil) {
            parameters["defaultUnit"] = String(sizeUnit!.rawValue)
        }
        if(apparelSizeUnit != nil) {
            parameters["defaultApparelSizeUnit"] = apparelSizeUnit
        }
        _client.get(Constants.baseAPIUrl + "SFButton", parameters: parameters) {
            responseObject, error in
            
            guard let responseObject = responseObject, error == nil else {
                return;
            }
            
            let json = JSON(responseObject)
            var visibilityData = json["VisibilityData"]
            
            var show = json["VisibilityData"]["Show"].rawValue as? Bool ?? false;

            if let isKids = json["VisibilityData"]["IsKids"].rawValue as? Bool {
                self._isKids = isKids
                
                if(isKids) {
                    if let onlineScanInstructionsType = json["VisibilityData"]["KidsOnlineScanInstructionsType"].rawValue as? Int {
                        self._onlineScanInstructionsType = OnlineScanInstructionsType(rawValue: onlineScanInstructionsType) ?? OnlineScanInstructionsType.OneFootOnPaper
                    }
                } else {
                    if let onlineScanInstructionsType = json["VisibilityData"]["AdultsOnlineScanInstructionsType"].rawValue as? Int {
                        self._onlineScanInstructionsType = OnlineScanInstructionsType(rawValue: onlineScanInstructionsType) ?? OnlineScanInstructionsType.OneFootOnPaper
                    }
                }

            }
            
            if let productType = json["VisibilityData"]["ProductType"].rawValue as? Int {
                self._productType = ProductType(rawValue: productType) ?? ProductType.Footwear
            }
            
            if let useStrutFitProductNameAsFallback = json["VisibilityData"]["UseStrutFitProductNameAsFallback"].rawValue as? Bool {
                self._useStrutFitProductNameAsFallback = useStrutFitProductNameAsFallback
            }
            
            if let productName = json["VisibilityData"]["ProductName"].rawValue as? String, self._useStrutFitProductNameAsFallback, self.productName == "" {
                self.productName = productName
            }
            
            if let productImageURL = json["VisibilityData"]["ProductImageURL"].rawValue as? String, self.productImageURL == "" {
                self.productImageURL = productImageURL
            }
            
            if let _brandName = json["VisibilityData"]["BrandName"].rawValue as? String {
                self._brandName = _brandName
            }
            
            if let isScanningEnabled = json["VisibilityData"]["IsScanningEnabled"].rawValue as? Bool {
                self._hideScanning = !isScanningEnabled
            }
            
            if let isSizeGuideEnabled = json["VisibilityData"]["IsSizeGuideEnabled"].rawValue as? Bool {
                self._hideSizeGuide = !isSizeGuideEnabled
            }
            
            if let isUsualSizeEnabled = json["VisibilityData"]["IsUsualSizeEnabled"].rawValue as? Bool {
                self._hideUsualSize = !isUsualSizeEnabled
            }
            
            if let _usualSizeMethods = json["VisibilityData"]["UsualSizeMethods"].rawValue as? [Int] {
                self._usualSizeMethods = _usualSizeMethods
            }
            
            if let useCustomTheme = json["VisibilityData"]["UseCustomTheme"].rawValue as? Bool {
                self.useCustomTheme = useCustomTheme
            }
            
            if let themeData = json["VisibilityData"]["ThemeData"].rawValue as? String {
                self.themeData = JSON.init(parseJSON: themeData);
            }
            
            if let preLoginButtonTextAdultsTranslations = json["VisibilityData"]["PreLoginButtonTextAdultsTranslations"].rawValue as? String {
                if let jsonData = preLoginButtonTextAdultsTranslations.data(using: .utf8) {
                    do {
                        self.preLoginButtonTextAdultsTranslations = try JSONDecoder().decode([CustomTextValue].self, from: jsonData)
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            }
            
            if let preLoginButtonTextKidsTranslations = json["VisibilityData"]["PreLoginButtonTextKidsTranslations"].rawValue as? String {
                if let jsonData = preLoginButtonTextKidsTranslations.data(using: .utf8) {
                    do {
                        self.preLoginButtonTextKidsTranslations = try JSONDecoder().decode([CustomTextValue].self, from: jsonData)
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            }
            
            if let buttonResultTextTranslations = json["VisibilityData"]["ButtonResultTextTranslations"].rawValue as? String {
                if let jsonData = buttonResultTextTranslations.data(using: .utf8) {
                    do {
                        self.buttonResultTextTranslations = try JSONDecoder().decode([CustomTextValue].self, from: jsonData)
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            }
            
            self._buttonText = self._isKids ? self.getPreLoginButtonTextKids() : self.getPreLoginButtonTextAdults()
            
            if self._productType == ProductType.Footwear && !(json["SizeData"].rawValue is NSNull) {
                var _size: String = ""
                if let size = json["SizeData"]["Size"].rawValue as? String {
                    _size = size
                }
                
                var _sizeUnit: Int? = 0
                if let sizeUnit = json["SizeData"]["Unit"].rawValue as? Int {
                    _sizeUnit = sizeUnit
                }
                var hideSizeUnit = json["VisibilityData"]["HideSizeUnit"].rawValue as? Bool ?? false;
                if hideSizeUnit {
                    _sizeUnit = nil
                }
                
                var _showWidthCategory: Bool = false
                if let showWidthCategory = json["SizeData"]["ShowWidthCategory"].rawValue as? Bool {
                    _showWidthCategory = showWidthCategory
                }
                
                var _widthAbbreviation: String = ""
                if let widthAbbreviation = json["SizeData"]["WidthAbbreviation"].rawValue as? String {
                    _widthAbbreviation = widthAbbreviation
                }
                
                let _width: String = (!_showWidthCategory || _widthAbbreviation.isEmpty || _widthAbbreviation == "null") ? "" : _widthAbbreviation;

                if(!_size.isEmpty && _size != "null") {
                    self._buttonText = self.getButtonResultText(size: _size, sizeUnit: ButtonHelper.mapSizeUnitEnumtoString(sizeUnit: _sizeUnit), width: _width)
                } else {
                    self._buttonText = self.unavailableSizeText;
                }
            }
            
            if self._productType == ProductType.Apparel && !(json["ApparelSizeData"].rawValue is NSNull) {
                var _size: String = ""
                if let size = json["ApparelSizeData"]["Size"].rawValue as? String {
                    _size = size
                }

                if(!_size.isEmpty && _size != "null") {
                    self._buttonText = self.getButtonResultText(size: _size, sizeUnit: "", width: "")
                } else {
                    self._buttonText = self.unavailableSizeText;
                }
            }

            // Appy text to button
            // In the main thread
            DispatchQueue.main.async {
                // Set is hidden
                if(!show) {
                    self.onStateChange?(.hidden)
                    return
                }
                
                if(isInitializing) {
                    self.onStateChange?(.initialize(url: self.webViewURL))
                    if let themeData = self.themeData, self.useCustomTheme  {
                        self.updateTheme?(themeData)
                    }
                } else {
                    // Set visible with button text
                    self.onStateChange?(.visible(title: self._buttonText))
                }
            }
        }
    }

    func handleMessage(messageString: String) {
        let json = JSON.init(parseJSON: messageString)
        
        var strutFitMessageType = json["strutfitMessageType"]
        
        guard let messageType = json["strutfitMessageType"].int else {
            var x = "No message"
            return
        }
        
        if let postMessageType = PostMessageType(rawValue: messageType) {
            let encoder = JSONEncoder()
            
            switch postMessageType
            {
            case PostMessageType.UserAuthData:
                // Update User Id
                let userId = json["uuid"].string ?? nil
                CommonHelper.setLocalUserId(userId: userId)
                break;
            case PostMessageType.UserFootMeasurementCodeData:
                // Update Mcode
                let newCode = json["footMeasurementCode"].string ?? nil
                CommonHelper.setLocalFootMCode(code: newCode)
                let bodyMCode = CommonHelper.getLocalBodyMCode()
                self.getSizeAndVisibility(footMeasurementCode: newCode, bodyMeasurementCode: bodyMCode, isInitializing: false)
                break;
            case PostMessageType.UserBodyMeasurementCodeData:
                // Update Mcode
                let newCode = json["bodyMeasurementCode"].string ?? nil
                CommonHelper.setLocalBodyMCode(code: newCode)
                let footMCode = CommonHelper.getLocalFootMCode()
                self.getSizeAndVisibility(footMeasurementCode: footMCode, bodyMeasurementCode: newCode, isInitializing: false)
                break;
            case PostMessageType.CloseIFrame:
                // Close modal
                DispatchQueue.main.async {
                    self.closeWebView?()
                }
                break;
            case PostMessageType.IframeReady:
                //IFrame ready
                let input = PostMessageInitialAppInfoDto(productCode: productCode, organizationUnitId: organizationUnitId, isKids: _isKids, productType: _productType, productName: productName, productImageURL: productImageURL, defaultSizeUnit: sizeUnit, defaultApparelSizeUnit: apparelSizeUnit, onlineScanInstructionsType: _onlineScanInstructionsType, brandName: _brandName, hideScanning: _hideScanning, hideSizeGuide: _hideSizeGuide, hideUsualSize: _hideUsualSize, usualSizeMethods: _usualSizeMethods)
                do {
                    let jsonData = try encoder.encode(input)
                    self.postMessage(data: jsonData)

                } catch {
                    print("Error encoding input to JSON: \(error)")
                }
                if let themeData = self.themeData, self.useCustomTheme {
                    let themeInput = PostMessageUpdateThemeDto(themeData: themeData)
                    do {
                        let themeJsonData = try encoder.encode(themeInput)
                        self.postMessage(data: themeJsonData)
                    } catch {
                        print("Error encoding theme to JSON: \(error)")
                    }
                }
                
                // Set visible with button text
                DispatchQueue.main.async {
                    self.onStateChange?(.visible(title: self._buttonText))
                }
                break;
            default:
                return
            }
        } else {
            var x = "No valid message"
            return
        }
    }
    
    func postMessage(data: Data) {
        if let jsonString = String(data: data, encoding: .utf8) {
                
            // Format the JavaScript code with the JSON string
            let javaScriptCode = "window.callStrutFitFromNativeApp('\(jsonString)')"
            
            // Now you can use `javaScriptCode` in evaluateJavaScript:
            print(javaScriptCode)  // Just printing to show the result
        
            self.sendMessageToJavascript?(javaScriptCode);
        }
    }
    
    func getPreLoginButtonTextAdults() -> String {
        var languageCode =  "en"
        if let preferredLanguage = Locale.preferredLanguages.first {
            languageCode = Locale(identifier: preferredLanguage).languageCode ?? "en"
        }
        if !self.preLoginButtonTextAdultsTranslations.isEmpty {
            let translation = self.preLoginButtonTextAdultsTranslations.first {
                $0.language == CommonHelper.getLanguageByCode(code:languageCode).rawValue
            }
            if(translation != nil) {
                return translation!.text;
            }
        }

        return NSLocalizedString("WhatIsMySize", tableName: nil, bundle: .module, value: "", comment: "");
    }
    
    func getPreLoginButtonTextKids() -> String {
        var languageCode =  "en"
        if let preferredLanguage = Locale.preferredLanguages.first {
            languageCode = Locale(identifier: preferredLanguage).languageCode ?? "en"
        }
        if !self.preLoginButtonTextKidsTranslations.isEmpty {
            let translation = self.preLoginButtonTextKidsTranslations.first {
                $0.language == CommonHelper.getLanguageByCode(code:languageCode).rawValue
            }
            if(translation != nil) {
                return translation!.text;
            }
        }

        return NSLocalizedString("WhatIsMySize_Kids", tableName: nil, bundle: .module, value: "", comment: "");
    }
    
    func getButtonResultText(size: String, sizeUnit: String, width: String) -> String {
        var languageCode =  "en"
        if let preferredLanguage = Locale.preferredLanguages.first {
            languageCode = Locale(identifier: preferredLanguage).languageCode ?? "en"
        }

        if !self.buttonResultTextTranslations.isEmpty {
            let translation = self.buttonResultTextTranslations.first {
                $0.language == CommonHelper.getLanguageByCode(code:languageCode).rawValue
            }
            if(translation != nil) {
                return translation!.text
                    .replacingOccurrences(of: "@size", with: size)
                    .replacingOccurrences(of: "@unit", with: sizeUnit)
                    .replacingOccurrences(of: "@width", with: width)
                    .replacingOccurrences(of: "  ", with: " ");
            }
        }

        
        var defaultText = NSLocalizedString("YourStrutfitSize", tableName: nil, bundle: .module, value: "", comment: "") + size + " " + sizeUnit + " " + width;
        return defaultText.replacingOccurrences(of: "  ", with: " ");
    }


    func getUnavailableSizeText() -> String {
        return unavailableSizeText;
    }
    
    func getThemeData() -> JSON? {
        return themeData;
    }
}
