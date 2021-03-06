//
//  File.swift
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
    
    public func registerOrder(orderReference: String, orderValue: Float, currencyCode: String, items: [ConversionItem]) {

        do {
            let itemsObjectJson = String(data: try _jsonEncoder.encode(items), encoding: String.Encoding.utf8)
            
            let pixelData = PixelData(organizationUnitId: _organizationunitId, sfEnabled: CommonHelper.getIsStrutfitInUse(), orderRef: orderReference, orderValue: orderValue, mCode: CommonHelper.getCodeFromLocal(), items: itemsObjectJson ?? "", currencyCode: currencyCode, domain: Constants.conversionDomain);
            
            let pixelDataJson = String(data: try _jsonEncoder.encode(pixelData), encoding: String.Encoding.utf8)
            
            if(pixelDataJson != nil) {
                let base64Encoded = Data(pixelDataJson?.utf8 ?? "".utf8).base64EncodedString()
                
                _client.get(Constants.conversionUrl, parameters: ["token" : base64Encoded ]){ responseObject, error in
                  // No action needed
                }
            }
        }
        catch {
            // Button tap failed
        }
    }
}
