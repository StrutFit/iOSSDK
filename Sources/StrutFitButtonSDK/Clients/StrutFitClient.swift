//
//  StrutFitClient.swift
//  
//
//  Created by StrutFit Admin on 10/02/22.
//

import Foundation

public class StrutFitClient {
    
    public init() {
        
    }
    
    public func get(_ url: String, parameters: [String: String], completion: @escaping ([String: Any]?, Error?) throws -> Void) {
        var components = URLComponents(string: url)
        components?.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        let _percentEncodedQuery = components?.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        components?.percentEncodedQuery = _percentEncodedQuery
        var request = URLRequest(url: (components?.url)!)
        request.setValue("strutfit.app", forHTTPHeaderField: "Origin")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,                              // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                200 ..< 300 ~= response.statusCode,           // is statusCode 2XX
                error == nil                                  // was there no error
            else {
                do {
                    try completion(nil, error)
                } catch {}
                return
            }
            
            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            do {
                try completion(responseObject, nil)
            } catch {}

        }
        task.resume()
    }
    
}
