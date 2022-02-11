//
//  File.swift
//  
//
//  Created by StrutFit Admin on 11/02/22.
//

import Foundation


public class StrutFittracker {
    
    var _organizationunitId: Int;
    var _client :StrutFitClient
    
    public init (organizationUnitId: Int) {
        _organizationunitId = organizationUnitId;
        _client = StrutFitClient();
    }
    
    public func registerOrder(orderReference: String, orderValue: Float, currencyCode: String, items: [ConversionItem]) {

        let itemsObjectJson  = CommonHelper.convertObjectToJSONString(from: items);
        
        let pixelData = PixelData(organizationId: _organizationunitId, sfEnabled: CommonHelper.getIsStrutfitInUse(), orderRef: orderReference, orderValue: orderValue, mCode: CommonHelper.getCodeFromLocal(), items: itemsObjectJson ?? "", currencyCode: currencyCode, domain: Constants.conversionDomain);
        
        
        let pixelDataJson  = CommonHelper.convertObjectToJSONString(from: pixelData);
        
        _client.get(Constants.conversionUrl, parameters: ["token" : pixelDataJson ?? ""]){ responseObject, error in
          // No action needed
        }
    }
}
