import Foundation
import UIKit
import WebKit

public class StrutFitButton {
    
    // UI components
    public let _button: UIButton?
    var _webView: WKWebView = WKWebView()
    
    // Button Parameters
    let _organizationId: Int
    let _shoeId: String
    let _isDevelopment: Bool
    
    // Base strings
    let _baseAPIUrl: String;
    var _baseWebViewUrl: String = ""
    
    // State Parameters
    var _webviewUrl: String = ""
    var _isKids: Bool = false
    var _show: Bool = false
    var _webviewLoaded = false
    
    public init(SizeButton: UIButton, OrganizationId: Int, ShoeId: String, IsDevelopment: Bool)
    {
        _organizationId = OrganizationId
        _shoeId = ShoeId
        _isDevelopment = IsDevelopment
        
        _button = SizeButton;
        _button?.backgroundColor = UIColor.gray
        _button?.isHidden = true;
        

        
        // Set up API URL's
        _baseAPIUrl = IsDevelopment ? "https://api-dev.strut.fit/api/" : "https://api-prod.strut.fit/api/";
        _baseWebViewUrl = IsDevelopment ? "https://consumer-portal-dev.strut.fit/" : "https://scan.strut.fit/";
        
        // Make the initial API request
        getSizeAndVisibility(measurementCode: getCodeFromLocal(), isInitializing: true)
    }
    
    public func buttonTapped(view: UIView, controller: WKScriptMessageHandler)
    {
        // open the webview for the first time
        if(!_webviewLoaded)
        {
            // Create webview
            // Configuration needs to be initialized cannot be changed after (iOS Bug)
            let configuration = WKWebViewConfiguration()
            configuration.allowsInlineMediaPlayback = true
            
            if #available(iOS 14.0, *) {
                configuration.defaultWebpagePreferences.allowsContentJavaScript = true
            } else {
                // Fallback on earlier versions
                configuration.preferences.javaScriptEnabled = true
            }
            
            configuration.allowsPictureInPictureMediaPlayback = true;
            self._webView = WKWebView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), configuration: configuration)
            self._webView.isHidden = false;
            
            // Add it
            view.addSubview(self._webView)
            
            // Adding post message handler function
            self._webView.configuration.userContentController.add(controller, name: StrutFitHelper.postMessageHandlerName)
            
            // Load the URL
            guard let url = URL(string: self._webviewUrl) else {
                return
            }
            self._webView.load(URLRequest(url: url))
            
            self._webviewLoaded = true
        }
        // open the webview again
        else
        {
            _webView.isHidden = false;
        }
    }
    
    // Fetchs buttons state varibles from SF api and manipulates button state
    func getSizeAndVisibility (measurementCode: String, isInitializing: Bool)
    {
        // User does not already exist
        if(measurementCode.isEmpty)
        {
            StrutFitHelper.sendRequest(_baseAPIUrl + "MobileApp/DetermineButtonVisibility", parameters: ["OrganizationUnitId": String(_organizationId), "Code" : _shoeId]) { responseObject, error in
                guard let responseObject = responseObject, error == nil else {
                    print(error ?? "Unknown error")
                    return
                }

                if let index = responseObject.index(forKey: "result")
                {

                    let json = JSON(responseObject[index].value)
                    self._isKids = json["iskids"].boolValue
                    self._show = json["show"].boolValue
                                            
                    if(isInitializing)
                    {
                        // Set initial webview url
                        self._webviewUrl = self.generateWebViewUrl(isKids: self._isKids, organizationId: self._organizationId, shoeId: self._shoeId)
                    }
                   
                        
                    // In the main thread
                    DispatchQueue.main.async {
                        // Set is hidden
                        self._button?.isHidden = self._show ? false : true;
                        
                        // Set button text
                        self._button?.setTitle(self._isKids ? "What is my child's size?" : "What is my size?", for: .normal)
                    }
                }
            }

        }
        // User exists and has already scanned
        else
        {
            StrutFitHelper.sendRequest(_baseAPIUrl + "MobileApp/GetSizeandVisibility", parameters: ["OrganizationUnitId": String(_organizationId), "Code" : _shoeId, "MCode" : measurementCode]) { responseObject, error in
                
                guard let responseObject = responseObject, error == nil else {
                    print(error ?? "Unknown error")
                    return
                }
                
                if let index = responseObject.index(forKey: "result")
                {
                    let json = JSON(responseObject[index].value)
                    var _buttonText = "Unavaliable in your roccomended size";
                    self._show = json["visibilityData"]["show"].rawValue as! Bool
                    
                    if(self._show)
                    {
                        self._isKids = json["visibilityData"]["isKids"].rawValue as! Bool
                        
                        let _size: String = json["sizeData"]["size"].rawValue as! String
                        let _sizeUnit: Int = json["sizeData"]["unit"].rawValue as! Int
                        let _showWidthCategory: Bool = json["sizeData"]["showWidthCategory"].rawValue as! Bool
                        let _widthAbbreviation: String = json["sizeData"]["widthAbbreviation"].rawValue as! String
                        
                        let _width: String = (!_showWidthCategory || _widthAbbreviation.isEmpty || _widthAbbreviation == "null") ? "" : _widthAbbreviation;

                        if(!_size.isEmpty && _size != "null") {
                            let sizeReccomendationText : String = _size + " " + StrutFitHelper.mapSizeUnitEnumtoString(sizeUnit: _sizeUnit) + " " + _width;
                            _buttonText = self._isKids ? "Your child's size in this style is " + sizeReccomendationText : "Your size in this style is " + sizeReccomendationText;
                        }
                        
                        // If the button has alrady been initialized we dont need to change the weburl
                        if(isInitializing)
                        {
                            // Set initial webview url
                            self._webviewUrl = self.generateWebViewUrl(isKids: self._isKids, organizationId: self._organizationId, shoeId: self._shoeId)
                        }
                    }
  
                    // Appy text to button
                    // In the main thread
                    DispatchQueue.main.async {
                        // Set is hidden
                        self._button?.isHidden = self._show ? false : true;

                        // Set button text
                        self._button?.setTitle(_buttonText, for: .normal)
                    }
                }
            }
        }
    }
    
    // Evaluating post messages from webview
    public func evaluatePostMessage (messageString: String)
    {
             
        let json = JSON.init(parseJSON: messageString)
        let messageType = json["messageType"].int
        
        switch messageType
        {
            case 0:
                // Update Mcode
                let newCode = json["mcode"].string ?? ""
                self.storeCodeLocally(code: newCode)
                self.getSizeAndVisibility(measurementCode: newCode, isInitializing: false)
            case 1:
                // Update Mcode
                let newCode = json["mcode"].string ?? ""
                self.storeCodeLocally(code: newCode)
                self.getSizeAndVisibility(measurementCode: newCode, isInitializing: false)
            case 2:
                // Close modal
                closeModal()
            default:
                return
        }

    }
    
    // Generate webview url
    func generateWebViewUrl (isKids: Bool, organizationId: Int, shoeId: String) -> String
    {
        // Make route
        let route : String = isKids ? "nkids" : "nadults"
        
        // Random number gen
        let randomInt = Int.random(in: 1..<9999)
            
        // Set initial webview url
        let url = self._baseWebViewUrl + route + "?random=" + String(randomInt) + "&organisationId=" + String(organizationId) + "&shoeId=" + shoeId + "&inApp=true"
        
        return url
    }
    
    // Close webview
    func closeModal ()
    {
        // In the main thread
        DispatchQueue.main.async
        {
            // Set is hidden
            self._webView.isHidden = true
        }
    }
    
    func storeCodeLocally (code: String)
    {
        let defaults = UserDefaults.standard
        defaults.set(code, forKey: StrutFitHelper.localMocde)
    }
    
    func getCodeFromLocal () -> String
    {
        let defaults = UserDefaults.standard
        let code  = defaults.string(forKey: StrutFitHelper.localMocde) ?? ""
        return code
    }
}
