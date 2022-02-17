import Foundation
import UIKit
import WebKit

public class StrutFitButton {
    
    // UI components
    public let _button: UIButton?
    var _webView: WKWebView?
    
    // Button Parameters
    let _organizationId: Int
    let _shoeId: String
    
    // State Parameters
    var _webviewUrl: String = ""
    var _isKids: Bool = false
    var _show: Bool = false
    var _webviewLoaded = false
    
    // Default Strings
    var _kidsInitButtonText = ""
    var _adultsInitButtonText = ""
    var _kidsSizeButtonText = ""
    var _adultsSizeButtonText = ""
    
    var _client: StrutFitClient;
    
    public init(SizeButton: UIButton, OrganizationId: Int, ProductIdentifier: String, BackgroundColor: UIColor, KidsInitButtonText: String = Constants.whatIsMyChildsSize, KidsSizeButtonText:String = Constants.yourChildsSize, AdultsSizeButtonText: String = Constants.yourAdultsSize, AdultsInitButtonText:String = Constants.whatIsMyAdultsSize, LogoColor: StrutFitLogoColor = StrutFitLogoColor.Black )
    {
        // Poition SF logo inside button
        var imageName = "strutfit-glyph.svg";
        if(LogoColor == StrutFitLogoColor.White) {
            imageName = "strutfit-glyph-white.svg"
        }
        
        let paths = Bundle.main.paths(forResourcesOfType: "svg", inDirectory: nil)
        
        if let image = UIImage(named: imageName, in: Bundle(for: type(of:self)), compatibleWith: nil) {
            SizeButton.setImage(image, for: .normal)
        }
        
        _client = StrutFitClient();
        
        _kidsInitButtonText = KidsInitButtonText
        _adultsInitButtonText = AdultsInitButtonText
        
        _kidsSizeButtonText = KidsSizeButtonText
        _adultsSizeButtonText = AdultsSizeButtonText
        
        _organizationId = OrganizationId
        _shoeId = ProductIdentifier
        
        _button = SizeButton;
        _button?.backgroundColor = BackgroundColor;
        _button?.isHidden = true;
        
        // Make the initial API request
        getSizeAndVisibility(measurementCode: CommonHelper.getCodeFromLocal(), isInitializing: true)
    }
    
    public func buttonTapped(view: UIView, controller: WKScriptMessageHandler) throws
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
            self._webView!.isHidden = false;
            
            // Add it
            view.addSubview(self._webView!)
            
            // Adding post message handler function
            self._webView!.configuration.userContentController.add(controller, name: Constants.postMessageHandlerName)
            
            // Load the URL
            guard let url = URL(string: self._webviewUrl) else {
                throw StrutfitError.urlNotSet
            }
            self._webView!.load(URLRequest(url: url))
            
            self._webviewLoaded = true
        }
        // open the webview again
        else
        {
            _webView?.isHidden = false;
        }
    }
    
    // Fetchs buttons state varibles from SF api and manipulates button state
    func getSizeAndVisibility (measurementCode: String, isInitializing: Bool)
    {
        // User does not already exist
        if(measurementCode.isEmpty)
        {
            _client.get(Constants.baseAPIUrl + "MobileApp/DetermineButtonVisibility", parameters: ["OrganizationUnitId": String(_organizationId), "Code" : _shoeId]) { responseObject, error in
                guard let responseObject = responseObject, error == nil else {
                    throw StrutfitError.unexpectedResponse
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
                        self._button?.setTitle(self._isKids ? self._kidsInitButtonText : self._adultsInitButtonText, for: .normal)
                    }
                }
            }

        }
        // User exists and has already scanned
        else
        {
            _client.get(Constants.baseAPIUrl + "MobileApp/GetSizeandVisibility", parameters: ["OrganizationUnitId": String(_organizationId), "Code" : _shoeId, "MCode" : measurementCode]) { responseObject, error in
                
                guard let responseObject = responseObject, error == nil else {
                    throw StrutfitError.unexpectedResponse
                }
                
                if let index = responseObject.index(forKey: "result")
                {
                    let json = JSON(responseObject[index].value)
                    var _buttonText = "Unavaliable in your roccomended size";
                    // self._show = json["visibilityData"]["show"].rawValue as! Bool
                    
                    if let show = json["visibilityData"]["show"].rawValue as? Bool {
                        self._show = show
                    }
                    
                    if(self._show)
                    {
                        if let isKids = json["visibilityData"]["isKids"].rawValue as? Bool {
                            self._isKids = isKids
                        }
                        
                        var _size: String = ""
                        if let size = json["sizeData"]["size"].rawValue as? String {
                            _size = size
                        }
                        
                        var _sizeUnit: Int = 0
                        if let sizeUnit = json["sizeData"]["size"].rawValue as? Int {
                            _sizeUnit = sizeUnit
                        }
                        
                        var _showWidthCategory: Bool = false
                        if let showWidthCategory = json["sizeData"]["showWidthCategory"].rawValue as? Bool {
                            _showWidthCategory = showWidthCategory
                        }
                        
                        var _widthAbbreviation: String = ""
                        if let widthAbbreviation = json["sizeData"]["widthAbbreviation"].rawValue as? String {
                            _widthAbbreviation = widthAbbreviation
                        }
                        
                        let _width: String = (!_showWidthCategory || _widthAbbreviation.isEmpty || _widthAbbreviation == "null") ? "" : _widthAbbreviation;

                        if(!_size.isEmpty && _size != "null") {
                            let sizeReccomendationText : String = _size + " " + ButtonHelper.mapSizeUnitEnumtoString(sizeUnit: _sizeUnit) + " " + _width;
                            _buttonText = self._isKids ? self._kidsSizeButtonText + sizeReccomendationText : self._adultsSizeButtonText + sizeReccomendationText;
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
                CommonHelper.storeCodeLocally(code: newCode)
                self.getSizeAndVisibility(measurementCode: newCode, isInitializing: false)
            case 1:
                // Update Mcode
                let newCode = json["mcode"].string ?? ""
                CommonHelper.storeCodeLocally(code: newCode)
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
        let url = Constants.baseWebViewUrl + route + "?random=" + String(randomInt) + "&organisationId=" + String(organizationId) + "&shoeId=" + shoeId + "&inApp=true"
        
        return url
    }
    
    // Close webview
    func closeModal ()
    {
        // In the main thread
        DispatchQueue.main.async
        {
            // Set is hidden
            self._webView?.isHidden = true
        }
    }
    
    enum StrutfitError: Error {
        case urlNotSet
        case unexpectedResponse
    }
}
