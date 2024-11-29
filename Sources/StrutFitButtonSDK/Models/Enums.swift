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
    case SizeGuideButtonClick = 9
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
