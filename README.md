# StrutFit Button iOS SDK
This code should be executed when a user visits the product display page. It will render the StrutFit button.

1. Ensure the following is in your info.plist file.   
    NSCameraUsageDescription   
    NSPhotoLibraryUsageDescription

2. Use https://github.com/StrutFit/iOSSDK to import the library into your Xcode project. Please use the latest version (you can see this in Releases)
3. The StruFit button code should be used as follows each time a user visits a product display page.  

4. Below an example of how the StrutFit library should be implemented inside a view using SwiftUI.

```ruby
import SwiftUI
import StrutFitButtonSDK

struct ContentView: View {
    let organizationUnitId = 1
    let productCode = "Test Product 1"
    let sizeUnit = "US"
    let apparelSizeUnit = "US"
    
    var body: some View {
        VStack {
            StrutFitButtonView(productCode: productCode, organizationUnitId: organizationUnitId, sizeUnit: sizeUnit, apparelSizeUnit: apparelSizeUnit)
                .frame(width: 300)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
```

Important things to note:
    Your **organizationUnitId** will be constant, and will be given to you by your StrutFit account manager.
    The **productCode** value will vary depending on the product being viewed, but it will be a unique string value for that product. 
        This value will need to match what we have in our StrutFit system, so please discuss this with your StrutFit account manager.
    The **sizeUnit** value is optional, but can be used when you sell the same product in different regions and want to display a different size unit to the user.
        When not supplied, there is internal logic to determine which size unit to display based on previous configuration in the StrutFit system.
    The **apparelSizeUnit** value is optional, and is the same as sizeUnit, but specific to apparel products.
    The StrutFit button is designed to have a fixed width (supplied by you) and then a dynamic height to fit all of the text within the button (this will change depending on the user's language and the button's state).
        By using the **.frame** and **.fixedSize** functions on the **StrutFitButtonView** component you can set the button's width and restrict the button's height from auto-filling its parent. These are required when using SwiftUI to get the correct sizing behaviour.

5. Testing
    Your organization will need to have configured some data in StrutFit (https://dashboard.strut.fit) in order for you to test the button.
    They will need to have added at least a test product to StrutFit and linked it up to a size chart. They can then tell you the product code they have used for that product.
    You will also need to provide your application's bundle identifier to your StrutFit executive so it can be whitelisted in your StrutFit workspace settings.
        The StrutFit SDK uses **Bundle.main.bundleIdentifier** to get your app's identifier and then attaches it to API requests for whitelisting purposes.


	For a quick test once you have the button appearing, instead of going through the scanning process you may log in using the following test account:   
	**Email:** test@test.com    
	**Password:** thisisatest    
 
# StrutFit (iOS) Tracking Pixel Integration
Prerequisite: Complete the button integration as shown above.

The tracking pixel is used to record your orders and whether or not StrutFit was used before purchasing. This is to allow us to track the performance of StrutFit in your app/on your website.
You can see the analytics at https://dashboard.strut.fit

1. You must have the StrutFit iOS SDK package in your project
2. Go to the area in your code where the user successfully completes an order
3. Apply the following code, i.e. create an instance of StrutFitTracking then register an order

```ruby
        //Build list of purchased items
        var items: [ConversionItem] = [];
        let item1 = ConversionItem(productIdentifier: "Test Product 1", price: 50, quantity: 1, size: "8 US");
        items.append(item1);
        let item2 = ConversionItem(productIdentifier: "Test Product 1", price: 50, quantity: 2, size: "5", sizeUnit: "US");
        items.append(item2);
        
        //Fire order tracking event
        let sfTracking = StrutFitTracking(organizationUnitId: 1)
        sfTracking.registerOrder(orderReference: "ORDER123", orderValue: 150, currencyCode: "NZD", items: items);
```
**organizationUnitId:** Same as the organizationUnitId you used in the button integration (int)  
**orderReference:** Every order must have a unique order reference that you've generated (string)  
**orderValue:** Total value of the order (double)  
**currencyCode:** e.g. "USD", "NZD", "AUD" etc.  
**items:** An array of type **ConversionItem**
**ConversionItem:** Data structure producded by StrutFit which contains the information for every item that was purchased for this particular order.  
* productIdentifier: same as the productCode you used in the button integration (string)  
* price: price of this particular item (double)  
* quantity: number of this item purchased (int) - in the above example the same product was purchased three times in the order, but since one of those times a different size was purchased, we need two ConversionItems  
* size: the size of the item purchased (leave blank if somehow not applicable)(string)	
* sizeUnit: (Optional) You can separate out the size unit here (if applicable), or just include it in the size value (string)    
* sku: (Optional) unique SKU code for the item, this is not required, but is useful if your productIdentifier is not the SKU (string)  

Talk to your StrutFit account manager when testing this code so they can make sure your orders are coming through as expected. You may use dummy data when testing, just let your StrutFit account executive know when you are ready to release so we can separate test data from real orders.

If you have any issues or suggested changes/improvements please email dev@strut.fit.   
If the way we have implemented the library doesn't quite work for your organization please let us know, we are happy to discuss.
