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
    var _callBackFunction: ((String, Int) -> ())?;
    
    public init(SizeButton: UIButton, OrganizationId: Int, ProductIdentifier: String, BackgroundColor: UIColor, SizeChangeCallBack: ((String, Int) -> ())? = nil, KidsInitButtonText: String = Constants.whatIsMyChildsSize, KidsSizeButtonText:String = Constants.yourChildsSize, AdultsSizeButtonText: String = Constants.yourAdultsSize, AdultsInitButtonText:String = Constants.whatIsMyAdultsSize, LogoColor: StrutFitLogoColor = StrutFitLogoColor.Black )
    {
        // Poition SF logo inside button
        var imageName = "strutfit-logo-black.png";
        if(LogoColor == StrutFitLogoColor.White) {
            imageName = "strutfit-logo-white.png"
        }
        
        if let image = UIImage(named: imageName) {
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
        
        _callBackFunction = SizeChangeCallBack;
        
        // Make the initial API request
        getSizeAndVisibility(measurementCode: CommonHelper.getCodeFromLocal(), isInitializing: true)
    }
    
    public func buttonTapped(view: UIView, controller: WKScriptMessageHandler) throws
    {
        // open the webview for the first time
        if(!_webviewLoaded)
        {
//            // Create webview
//            // Configuration needs to be initialized cannot be changed after (iOS Bug)
//            let configuration = WKWebViewConfiguration()
//            configuration.allowsInlineMediaPlayback = true
//            
//            if #available(iOS 14.0, *) {
//                configuration.defaultWebpagePreferences.allowsContentJavaScript = true
//            } else {
//                // Fallback on earlier versions
//                configuration.preferences.javaScriptEnabled = true
//            }
//            
//            configuration.allowsPictureInPictureMediaPlayback = true;
//            self._webView = WKWebView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), configuration: configuration)
//            self._webView!.isHidden = false;
//            
//            // Add it
//            view.addSubview(self._webView!)
//            
//            // Adding post message handler function
//            self._webView!.configuration.userContentController.add(controller, name: Constants.postMessageHandlerName)
//            
//            // Load the URL
//            guard let url = URL(string: self._webviewUrl) else {
//                throw StrutfitError.urlNotSet
//            }
//            self._webView!.load(URLRequest(url: url))
//            
//            self._webviewLoaded = true
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
        _client.get(Constants.baseAPIUrl + "SFButton", parameters: ["organizationUnitId": String(_organizationId), "code" : _shoeId, "mcode" : measurementCode]) {
            responseObject, error in
            
            guard let responseObject = responseObject, error == nil else {
                throw StrutfitError.unexpectedResponse
            }
            
            let json = JSON(responseObject)
            var _buttonText = "Unavaliable in your roccomended size";
            // self._show = json["visibilityData"]["show"].rawValue as! Bool
            
            if let show = json["VisibilityData"]["Show"].rawValue as? Bool {
                self._show = show
            }
            
            if(self._show)
            {
                if let isKids = json["VisibilityData"]["IsKids"].rawValue as? Bool {
                    self._isKids = isKids
                }
                
                if(json["SizeData"].rawValue as Optional<Any> != nil) {
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
                        let sizeReccomendationText : String = _size + " " + ButtonHelper.mapSizeUnitEnumtoString(sizeUnit: _sizeUnit) + " " + _width;
                        _buttonText = self._isKids ? self._kidsSizeButtonText + sizeReccomendationText : self._adultsSizeButtonText + sizeReccomendationText;
                    }
                    
                    if(self._callBackFunction != nil)
                    {
                        self._callBackFunction!(_size, _sizeUnit)
                    }
                }
                
                // If the button has alrady been initialized we dont need to change the weburl
                if(isInitializing)
                {
                    // Create webview
//                    // Configuration needs to be initialized cannot be changed after (iOS Bug)
//                    let configuration = WKWebViewConfiguration()
//                    configuration.allowsInlineMediaPlayback = true
//                    
//                    if #available(iOS 14.0, *) {
//                        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
//                    } else {
//                        // Fallback on earlier versions
//                        configuration.preferences.javaScriptEnabled = true
//                    }
//                    
//                    configuration.allowsPictureInPictureMediaPlayback = true;
//                    self._webView = WKWebView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), configuration: configuration)
//                    self._webView!.isHidden = false;
//                    
//                    // Add it
//                    view.addSubview(self._webView!)
//                    
//                    // Adding post message handler function
//                    self._webView!.configuration.userContentController.add(controller, name: Constants.postMessageHandlerName)
//                    
//                    // Load the URL
//                    guard let url = URL(string: self._webviewUrl) else {
//                        throw StrutfitError.urlNotSet
//                    }
//                    self._webView!.load(URLRequest(url: url))
//                    
//                    self._webviewLoaded = true
                    
                }

                // Appy text to button
                // In the main thread
                DispatchQueue.main.async {
                    // Set is hidden
                    self._button?.isHidden = self._show ? false : true;
                    
                    // Set button text
                    if(json["SizeData"].rawValue as Optional<Any> != nil) {
                        self._button?.setTitle(_buttonText, for: .normal)
                    } else {
                        self._button?.setTitle(self._isKids ? self._kidsInitButtonText : self._adultsInitButtonText, for: .normal)
                    }
                }
            }
        }
    }
    
    // Evaluating post messages from webview
    public func evaluatePostMessage (messageString: String)
    {
             
        let json = JSON.init(parseJSON: messageString)
        
        guard let messageType = json["messageType"].int else { return }
        
        if let postMessageType = PostMessageType(rawValue: messageType) {
            switch postMessageType
            {
                case PostMessageType.UserFootMeasurementCodeData:
                    // Update Mcode
                    let newCode = json["mcode"].string ?? ""
                    CommonHelper.storeCodeLocally(code: newCode)
                    self.getSizeAndVisibility(measurementCode: newCode, isInitializing: false)
                case PostMessageType.CloseIFrame:
                    // Close modal
                    closeModal()
//            case PostMessageType.IframeReady:
                    //IFrame ready
//                    PostMessageInitialAppInfoDto input = new PostMessageInitialAppInfoDto();
//                    input.strutfitMessageType = PostMessageType.InitialAppInfo.getValue();
//                    input.productId = _shoeId;
//                    input.organizationUnitId = _organizationId;
//                    input.hideSizeGuide = true;
//                    input.inApp = true;
                default:
                    return
            }
        }
        

        


    }
    
    // Generate webview url
    func generateWebViewUrl (isKids: Bool, organizationId: Int, shoeId: String) -> String
    {
        // Random number gen
        let randomInt = Int.random(in: 1..<9999)
            
        // Set initial webview url
        let url = Constants.baseWebViewUrl + "?random=" + String(randomInt) + "&organisationId=" + String(organizationId) + "&shoeId=" + shoeId + "&isKids=" + String(isKids) + "&inApp=true"
        
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
}
