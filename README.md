# StrutFit Button iOS SDK

If you have any issues or suggested changes/improvements please email nish@strut.fit.   
If we have implemented the the library doesnt quite work for your organisation please let us know we are happy to discuss.

This code should be executed when a user visits the product display page.

Ensure the following is in your info.plist file.   
NSCameraUsageDescription.   
NSPhotoLibraryUsageDescription.   
NSMicrophoneUsageDescription.   

1. use https://github.com/StrutFit/iOSSDK to import the library into your xcode project. Plseae use the latest version (you can see this in releases)
2. StruFit library should be created as follows each time a user visits a product display page.  

4. Below an example of how the StrutFit library should be implemented inside a view controller.
   
```ruby  
import UIKit
import WebKit
import StrutFitButtonSDK
import AVFoundation

class ViewController: UIViewController, WKScriptMessageHandler {
    
    var _strutfitButton: StrutFitButton? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Creating the button
        let button = UIButton(frame: CGRect(x: 0, y: 300, width: 300, height: 50))
        button.isHidden = true;

        // Pass the button to the SF contructor which will initialize the button
        let StrutFitButton = StrutFitButton(SizeButton: button, OrganizationId: 5, ProductIdentifier: "TestProduct")
        _strutfitButton = StrutFitButton

        // Attach click event handler
        _strutfitButton?._button!.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        // Add the button to your view
        view.addSubview((_strutfitButton?._button!)!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // When the user taps on the button
    @objc func buttonAction(sender: UIButton!) {
        // We preemtively ask for user permisions for camera before the button
        // initializes the webview. Otherwise the webview will not have access once
        // the class is created.
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
            if (granted) {
                DispatchQueue.main.async
                {
                    // Set is hidden
                    self._strutfitButton!.buttonTapped(view: self.view, controller: self)
                }
            }
        }
    }

    // This lets us communicate information between the webview & button
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == StrutFitHelper.postMessageHandlerName {
            _strutfitButton!.evaluatePostMessage(messageString: message.body as! String)
        }
    }
}
```

4. Initializing StrutFit button  
	OrganizationID - an integer given to you by your StrutFit account manager.  
	ProductIdentifer  - string value of the unique identifer of the shoe that is being viewed.  

	When testing you can use the following. 
  	Before release please defer to putting the actual product identifier and oranizationId provided by your StrutFit account manager.   
	**OrganizationID:** 5.   
	**ProductIdentifer:** "TestProduct".  

	For a quick test instead of going to the scanning process you may login using the following test account.   
	**Email:** test@test.com.   
	**Password:** thisisatest.    

	we encourage you to modify the button UI to suite your application while conforming to the StrutFit brand guidelines.
 
	
