//
//  File.swift
//  
//
//  Created by StrutFit Admin on 11/02/22.
//

import Foundation

public class CommonHelper {
    
    static func setLocalFootMCode(code: String?)
    {
        let defaults = UserDefaults.standard
        defaults.set(code, forKey: Constants.activeFootMCode)
    }
    
    static func getLocalFootMCode () -> String?
    {
        let defaults = UserDefaults.standard
        let code  = defaults.string(forKey: Constants.activeFootMCode) ?? nil
        return code
    }
    
    static func setLocalBodyMCode(code: String?)
    {
        let defaults = UserDefaults.standard
        defaults.set(code, forKey: Constants.activeBodyMCode)
    }
    
    static func getLocalBodyMCode () -> String?
    {
        let defaults = UserDefaults.standard
        let code  = defaults.string(forKey: Constants.activeBodyMCode) ?? nil
        return code
    }
    
    static func setLocalUserId(userId: String?)
    {
        let defaults = UserDefaults.standard
        defaults.set(userId, forKey: Constants.uniqueUserId)
    }
    
    static func getLocalUserId () -> String?
    {
        let defaults = UserDefaults.standard
        let code  = defaults.string(forKey: Constants.uniqueUserId) ?? nil
        return code
    }
}
