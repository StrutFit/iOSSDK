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
        let StrutFitButton = StrutFitButton(SizeButton: button, OrganizationId: 5, ProductIdentifier: "TestProduct", BackgroundColor: UIColor.gray, LogoColor: 							StrutFitLogoColor.Black)
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
                    do {
                        // Set is hidden
                        try self._strutfitButton!.buttonTapped(view: self.view, controller: self)
                    }
                    catch {
                        // Button tap failed
                    }
                }
            }
        }
    }

    // This lets us communicate information between the webview & button
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == Constants.postMessageHandlerName {
            _strutfitButton!.evaluatePostMessage(messageString: message.body as! String)
        }
    }
}
```

4. Initializing StrutFit button  
	OrganizationID - an integer given to you by your StrutFit account manager.  
	ProductIdentifer  - string value of the unique identifer of the shoe that is being viewed.   
	LogoColor -  Color of the SF logo that will display with the button (only options are black and white).   
	**You must aslso include the following SVG's in your asset folder of your project. Keep the names the same**. 
	Safari - (Right click link, Download linked file). 
	Chrome - (Right clicl link, Save as). 
	https://artifacts.strut.fit/strutfit-glyph-white.svg  (Right click, Download linked file)
	https://artifacts.strut.fit/strutfit-glyph.svg  

	When testing you can use the following. 
  	Before release please defer to putting the actual product identifier and oranizationId provided by your StrutFit account manager.   
	**OrganizationID:** 5.   
	**ProductIdentifer:** "TestProduct".  

	For a quick test instead of going to the scanning process you may login using the following test account.   
	**Email:** test@test.com    
	**Password:** thisisatest    

	we encourage you to modify the button UI to suite your application while conforming to the StrutFit brand guidelines.
 
# StrutFit (iOS) tracking pixel integration
Prerquisite: Complete the button integration as shown above.

The tracking pixel is used to record orders from the retailer. This is to allow us to track the preformace of StrutFit on your website.
You can see the analytics in the Retailer dashboard/

1. You must have the StrutFit iOS SDK package in your project.
2. Go to the area in your code where the end consumer successfully completes an order
3. Consider the following code: create an instance of StrutFitTracking then register an order

```ruby
	let sfTracking = StrutFitTracking(OrganizationID)
        sfTracking.registerOrder(OrderReference, OrderValue, CurrencyCode, ListOfItems);
```
**OrderReference:** Typically every order has a unique order reference (string)  
**OrderValue:** Total value of the order (double)  
**CurrencyCode:** e.g. "USD", "NZD", "AUD" etc.  
**ListOfItems:** Create an object **ArrayList<ConversionItem>** ListOfItems  
**ConversionItem:** Data structure producded by StrutFit which contains the information for every item that was purchased for this particular order.  
* sku: unique code for the item (string)  
* productIdentifier: same as the productIdentifer you used in the button integration (sometimes this could be the same as sku) (string)  
* price: price of this particular item (double)  
* quantity: number of this item purchased (int)  
* size: if there is a size to the item (string)	
