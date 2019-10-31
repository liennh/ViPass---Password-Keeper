//
//  UIDevice.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhone4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhoneX = "iPhone X"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhoneX
        default:
            return .unknown
        }
    }
    
    // for ipad pro 12.9 device
    public var isPadPro129: Bool {
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
            && UIScreen.main.nativeBounds.size.height == 2732) {
            return true
        }
        return false
    }
    
    // for ipad pro 10.5 device
    public var isPadPro105: Bool {
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
            && UIScreen.main.nativeBounds.size.height == 2224) {
            return true
        }
        return false
    }
    
    // for ipad pro 9.7 device
    public var isiPadPro97: Bool {
        if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
            && UIScreen.main.nativeBounds.size.height == 2048) {
            return true
        }
        return false
    }

}
