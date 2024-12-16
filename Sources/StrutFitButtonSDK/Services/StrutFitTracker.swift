//
//  StrutFitTracking.swift
//  
//
//  Created by StrutFit Admin on 11/02/22.
//

import Foundation


public class StrutFitTracking {
    
    var _organizationunitId: Int;
    var _client :StrutFitClient
    var _jsonEncoder :JSONEncoder;
    
    public init (organizationUnitId: Int) {
        _organizationunitId = organizationUnitId;
        _client = StrutFitClient();
        _jsonEncoder = JSONEncoder();
    }
    
    public func registerOrder(orderReference: String, orderValue: Float, currencyCode: String, items: [ConversionItem], userEmail: String? = nil) {

        do {
            let itemsObjectJson = String(data: try _jsonEncoder.encode(items), encoding: String.Encoding.utf8)
            
            let emailHash = (userEmail?.isEmpty ?? true) ? nil : hashCode(userEmail!)
            
            let pixelData = PixelData(organizationUnitId: _organizationunitId,
                                      orderRef: orderReference, orderValue: orderValue,
                                      userId: CommonHelper.getLocalUserId(),
                                      footScanMCode: CommonHelper.getLocalFootMCode(),
                                      bodyScanMCode: CommonHelper.getLocalBodyMCode(),
                                      items: itemsObjectJson ?? "",
                                      currencyCode: currencyCode,
                                      domain: Bundle.main.bundleIdentifier ?? "",
                                      isMobile: true,
                                      emailHash: emailHash);
            
            let pixelDataJson = String(data: try _jsonEncoder.encode(pixelData), encoding: String.Encoding.utf8)
            
            if(pixelDataJson != nil) {
                let base64Encoded = Data(pixelDataJson?.utf8 ?? "".utf8).base64EncodedString()
                
                _client.get(Constants.conversionUrl, parameters: ["token" : base64Encoded ]){ responseObject, error in
                  // No action needed
                }
            }
        }
        catch {
            // Pixel send failed
        }
    }

    func hashCode(_ input: String) -> Int32 {
        var hash: Int32 = 0
        for char in input.utf16 {
            hash = (hash << 5) &- hash &+ Int32(char) 
            hash &= 0x7FFFFFFF 
        }
        return hash
    }
}
