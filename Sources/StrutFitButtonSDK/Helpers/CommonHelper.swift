//
//  File.swift
//  
//
//  Created by StrutFit Admin on 11/02/22.
//

import Foundation

public class CommonHelper {
    
    static func storeCodeLocally (code: String)
    {
        let defaults = UserDefaults.standard
        defaults.set(code, forKey: Constants.localMocde)
    }
    
    static func getCodeFromLocal () -> String
    {
        let defaults = UserDefaults.standard
        let code  = defaults.string(forKey: Constants.localMocde) ?? ""
        return code
    }
    
    static func getIsStrutfitInUse () -> Bool
    {
        let code = getCodeFromLocal();
        
        return !code.isEmpty;
    }
}
