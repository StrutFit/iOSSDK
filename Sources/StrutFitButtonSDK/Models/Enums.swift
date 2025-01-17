//
//  File.swift
//  
//
//  Created by StrutFit Admin on 17/02/22.
//

import Foundation

public enum StrutFitLogoColor {
    case Black
    case White
}

public enum PostMessageType: Int {
    case UserAuthData = 0
    case UserFootMeasurementCodeData = 1
    case UserBodyMeasurementCodeData = 2
    case CloseIFrame = 3
    case ShowIFrame = 4
    case ProductInfo = 5
    case IframeReady = 6
    case ABTestInfo = 7
    case ReplicaButtonProductLoad = 8
    case SizeGuideOpened = 9
    case DeviceMotion = 10
    case DeviceOrientation = 11
    case UserAcceptedCookies = 12
    case UpdateProduct = 13
    case UpdateTheme = 14
    case ScanSucceeded = 15
    case RequestDeviceMotionAndOrientation = 16
    case ReprocessSize = 17
    case ReplicaButtonData = 18
    case InitialAppInfo = 19
    case LanguageChange = 20
}

public enum StrutfitError: Error {
    case urlNotSet
    case unexpectedResponse
}

public enum ProductType: Int {
    case Footwear = 0
    case Apparel = 1
}

public enum Language: Int {
    case English = 0
    case German = 1
    case Italian = 2
    case Dutch = 3
    case French = 4
    case Spanish = 5
    case Swedish = 6
    case Japanese = 7
    case Norwegian = 8
    case Portuguese = 9
    case Croatian = 10
    case Czech = 11
    case Danish = 12
    case Estonian = 13
    case Finnish = 14
    case Hungarian = 15
    case Latvian = 16
    case Lithuanian = 17
    case Polish = 18
    case Slovak = 19
    case Slovenian = 20
}

public enum SizeUnit: Int {
    case US = 0
    case UK = 1
    case EU = 2
    case AU = 3
    case FR = 4
    case DE = 5
    case NZ = 6
    case JP = 7
    case CN = 8
    case MX = 9
    case BR = 10
    case KR = 11
    case IN = 12
    case RU = 13
    case SA = 14
    case Mondopoint = 15
}

public enum OnlineScanInstructionsType: Int {
    case OneFootOnPaper = 0
    case OneFootOffPaper = 1
    case TwoFootPaper = 2
    case PlasticCard = 3
}
