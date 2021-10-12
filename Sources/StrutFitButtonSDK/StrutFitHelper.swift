import Foundation

public struct StrutFitHelper {
    
    public static let postMessageHandlerName = "webviewmessagehandler"
    
    public static let localMocde = "mcode"
    
    public static func sendRequest(_ url: String, parameters: [String: String], completion: @escaping ([String: Any]?, Error?) -> Void) {
        var components = URLComponents(string: url)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let request = URLRequest(url: components.url!)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,                              // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                200 ..< 300 ~= response.statusCode,           // is statusCode 2XX
                error == nil                                  // was there no error
            else {
                completion(nil, error)
                return
            }
            
            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            completion(responseObject, nil)
        }
        task.resume()
    }

    public static func mapSizeUnitEnumtoString(sizeUnit: Int) -> String
    {
        switch sizeUnit {
        case 0:
            return "US"
        case 1:
            return "UK"
        case 2:
            return "EU"
        case 3:
            return "AU"
        case 4:
            return "FR"
        case 5:
            return "DE"
        case 6:
            return "NZ"
        case 7:
            return "JP"
        case 8:
            return "CN"
        case 9:
            return "MX"
        case 10:
            return "BR"
        case 11:
            return "KR"
        case 12:
            return "IN"
        case 13:
            return "RU"
        case 14:
            return "SA"
        default:
            return ""
        }
    }
}
