import Foundation

public struct ButtonHelper {
    
    public static func mapSizeUnitEnumtoString(sizeUnit: Int?) -> String
    {
        if sizeUnit == nil {
            return ""
        }
        
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
