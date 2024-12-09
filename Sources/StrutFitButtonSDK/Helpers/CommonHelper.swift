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
    
    static func getLanguageByCode(code: String) -> Language {
        switch(code) {
        case "en":
            return Language.English;
        case "de":
            return Language.German;
        case "it":
            return Language.Italian;
        case "nl":
            return Language.Dutch;
        case "fr":
            return Language.French;
        case "es":
            return Language.Spanish;
        case "sv":
            return Language.Swedish;
        case "ja":
            return Language.Japanese;
        case "no":
            return Language.Norwegian;
        case "nb":
            return Language.Norwegian;
        case "pt":
            return Language.Portuguese;
        case "hr":
            return Language.Croatian;
        case "cs":
            return Language.Czech;
        case "da":
            return Language.Danish;
        case "et":
            return Language.Estonian;
        case "fi":
            return Language.Finnish;
        case "hu":
            return Language.Hungarian;
        case "lv":
            return Language.Latvian;
        case "lt":
            return Language.Lithuanian;
        case "pl":
            return Language.Polish;
        case "sk":
            return Language.Slovak;
        case "sl":
            return Language.Slovenian;
        default:
            return Language.English
        }
    }
    
    static func getSizeUnitEnumFromString(sizeUnit: String?) -> SizeUnit?
    {
        switch sizeUnit?.uppercased() {
        case "US":
            return SizeUnit.US
        case "UK":
            return SizeUnit.UK
        case "EU":
            return SizeUnit.EU
        case "AU":
            return SizeUnit.AU
        case "FR":
            return SizeUnit.FR
        case "DE":
            return SizeUnit.DE
        case "NZ":
            return SizeUnit.NZ
        case "JP":
            return SizeUnit.JP
        case "CN":
            return SizeUnit.CN
        case "MX":
            return SizeUnit.MX
        case "BR":
            return SizeUnit.BR
        case "KR":
            return SizeUnit.KR
        case "IN":
            return SizeUnit.IN
        case "RU":
            return SizeUnit.RU
        case "SA":
            return SizeUnit.SA
        case "MONDOPOINT":
            return SizeUnit.Mondopoint
        default:
            return nil
        }
    }
}
