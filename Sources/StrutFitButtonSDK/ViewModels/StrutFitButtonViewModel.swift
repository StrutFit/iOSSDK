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
    private let webViewURL: URL
    
    private var _isKids: Bool = false
    
    private var preLoginButtonTextAdultsTranslations: [CustomTextValue] = []
    private var preLoginButtonTextKidsTranslations: [CustomTextValue] = []
    private var buttonResultTextTranslations: [CustomTextValue] = []
    private var unavailableSizeText = "Unavailable in your recommended size"
    
    private var _buttonText = ""
    
    
    private var _client: StrutFitClient
    
    var onStateChange: ((State) -> Void)?
    
    var sendMessageToJavascript: ((String) -> Void)?
    
    var closeWebView: (() -> Void)?

    /// Initializes the view model with required parameters.
    /// - Parameters:
    ///   - productCode: A unique string representing the product.
    ///   - organizationUnitId: An integer representing the organization unit.
    init(productCode: String, organizationUnitId: Int) {
        self.productCode = productCode
        self.organizationUnitId = organizationUnitId
        self.webViewURL = URL(string: Constants.baseWebViewUrl)!
        self._client = StrutFitClient()
    }
    
    func getSizeAndVisibility(measurementCode: String?, isInitializing: Bool)
    {
        _client.get(Constants.baseAPIUrl + "SFButton", parameters: ["organizationUnitId": String(organizationUnitId), "code" : productCode, "mcode" : measurementCode ?? ""]) {
            responseObject, error in
            
            guard let responseObject = responseObject, error == nil else {
                throw StrutfitError.unexpectedResponse
            }
            
            let json = JSON(responseObject)
            var visibilityData = json["VisibilityData"]
            
            var show = json["VisibilityData"]["Show"].rawValue as? Bool ?? false;

            if let isKids = json["VisibilityData"]["IsKids"].rawValue as? Bool {
                self._isKids = isKids
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
            
            if !(json["SizeData"].rawValue is NSNull) {
                var _size: String = ""
                if let size = json["SizeData"]["Size"].rawValue as? String {
                    _size = size
                }
                
                var _sizeUnit: Int = 0
                if let sizeUnit = json["SizeData"]["Size"].rawValue as? Int {
                    _sizeUnit = sizeUnit
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
                
//                if(self._callBackFunction != nil)
//                {
//                    self._callBackFunction!(_size, _sizeUnit)
//                }
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
            case PostMessageType.UserFootMeasurementCodeData:
                // Update Mcode
                let newCode = json["footMeasurementCode"].string ?? ""
                CommonHelper.storeCodeLocally(code: newCode)
                self.getSizeAndVisibility(measurementCode: newCode, isInitializing: false)
            case PostMessageType.CloseIFrame:
                // Close modal
                DispatchQueue.main.async {
                    self.closeWebView?()
                }
            case PostMessageType.IframeReady:
                //IFrame ready
                let input = PostMessageInitialAppInfoDto(productCode: productCode, organizationUnitId: organizationUnitId)
                do {
                    let jsonData = try encoder.encode(input)
                    self.postMessage(data: jsonData)

                } catch {
                    print("Error encoding input to JSON: \(error)")
                }
                // Set visible with button text
                DispatchQueue.main.async {
                    self.onStateChange?(.visible(title: self._buttonText))
                }
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
    
    //TODO: Translations
    func getPreLoginButtonTextAdults() -> String {
        if !self.preLoginButtonTextAdultsTranslations.isEmpty {
            let translation = self.preLoginButtonTextAdultsTranslations.first { $0.isDefault }
            if(translation != nil) {
                return translation!.text;
            }
        }

        return "What is my size?";
    }
    
    func getPreLoginButtonTextKids() -> String {
        if !self.preLoginButtonTextKidsTranslations.isEmpty {
            let translation = self.preLoginButtonTextKidsTranslations.first { $0.isDefault }
            if(translation != nil) {
                return translation!.text;
            }
        }

        return "What is my child's size?";
    }
    
    func getButtonResultText(size: String, sizeUnit: String, width: String) -> String {
        if !self.buttonResultTextTranslations.isEmpty {
            let translation = self.buttonResultTextTranslations.first { $0.isDefault }
            if(translation != nil) {
                return translation!.text
                    .replacingOccurrences(of: "@size", with: size)
                    .replacingOccurrences(of: "@unit", with: sizeUnit)
                    .replacingOccurrences(of: "@width", with: width);
            }
        }

        return "Your size in this style is " + size + " " + sizeUnit + " " + width;
    }


    func getUnavailableSizeText() -> String {
        return unavailableSizeText;
    }
}
