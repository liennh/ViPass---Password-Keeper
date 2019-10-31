//
//  UIColor+BRWAdditions.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-10-21.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit

extension UIColor {

    // MARK: Buttons
    static var primaryButton: UIColor {
        return UIColor(red: 76.0/255.0, green: 152.0/255.0, blue: 252.0/255.0, alpha: 1.0)
    }

    static var primaryText: UIColor {
        return .white
    }

    static var secondaryButton: UIColor {
        return UIColor(red: 245.0/255.0, green: 247.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    }

    static var secondaryBorder: UIColor {
        return UIColor(red: 213.0/255.0, green: 218.0/255.0, blue: 224.0/255.0, alpha: 1.0)
    }

    static var darkText: UIColor {
        return UIColor(red: 35.0/255.0, green: 37.0/255.0, blue: 38.0/255.0, alpha: 1.0)
    }

    static var darkLine: UIColor {
        return UIColor(red: 36.0/255.0, green: 35.0/255.0, blue: 38.0/255.0, alpha: 1.0)
    }

    static var secondaryShadow: UIColor {
        return UIColor(red: 213.0/255.0, green: 218.0/255.0, blue: 224.0/255.0, alpha: 1.0)
    }

    // MARK: Gradient
    static var gradientStart: UIColor {
        return UIColor(red: 247.0/255.0, green: 164.0/255.0, blue: 69.0/255.0, alpha: 1.0)
    }

    static var gradientEnd: UIColor {
        return UIColor(red: 252.0/255.0, green: 83.0/255.0, blue: 148.0/255.0, alpha: 1.0)
    }

    static var offWhite: UIColor {
        return UIColor(white: 247.0/255.0, alpha: 1.0)
    }

    static var borderGray: UIColor {
        return UIColor(white: 221.0/255.0, alpha: 1.0)
    }

    static var separatorGray: UIColor {
        return UIColor(white: 221.0/255.0, alpha: 1.0)
    }

    static var grayText: UIColor {
        return UIColor(white: 136.0/255.0, alpha: 1.0)
    }

    static var grayTextTint: UIColor {
        return UIColor(red: 163.0/255.0, green: 168.0/255.0, blue: 173.0/255.0, alpha: 1.0)
    }

    static var secondaryGrayText: UIColor {
        return UIColor(red: 101.0/255.0, green: 105.0/255.0, blue: 110.0/255.0, alpha: 1.0)
    }

    static var grayBackgroundTint: UIColor {
        return UIColor(red: 250.0/255.0, green: 251.0/255.0, blue: 252.0/255.0, alpha: 1.0)
    }

    static var cameraGuidePositive: UIColor {
        return UIColor(red: 72.0/255.0, green: 240.0/255.0, blue: 184.0/255.0, alpha: 1.0)
    }

    static var cameraGuideNegative: UIColor {
        return UIColor(red: 240.0/255.0, green: 74.0/255.0, blue: 93.0/255.0, alpha: 1.0)
    }

    static var purple: UIColor {
        return UIColor(red: 209.0/255.0, green: 125.0/255.0, blue: 245.0/255.0, alpha: 1.0)
    }

    static var darkPurple: UIColor {
        return UIColor(red: 127.0/255.0, green: 83.0/255.0, blue: 230.0/255.0, alpha: 1.0)
    }

    static var pink: UIColor {
        return UIColor(red: 252.0/255.0, green: 83.0/255.0, blue: 148.0/255.0, alpha: 1.0)
    }

    static var blue: UIColor {
        return UIColor(red: 76.0/255.0, green: 152.0/255.0, blue: 252.0/255.0, alpha: 1.0)
    }

    static var whiteTint: UIColor {
        return UIColor(red: 245.0/255.0, green: 247.0/255.0, blue: 250.0/255.0, alpha: 1.0)
    }

    static var transparentWhite: UIColor {
        return UIColor(white: 1.0, alpha: 0.3)
    }
    
    static var transparentWhiteText: UIColor {
        return UIColor(white: 1.0, alpha: 0.7)
    }
    
    static var disabledWhiteText: UIColor {
        return UIColor(white: 1.0, alpha: 0.5)
    }

    static var transparentBlack: UIColor {
        return UIColor(white: 0.0, alpha: 0.3)
    }

    static var blueGradientStart: UIColor {
        return UIColor(red: 99.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }

    static var blueGradientEnd: UIColor {
        return UIColor(red: 56.0/255.0, green: 141.0/255.0, blue: 252.0/255.0, alpha: 1.0)
    }

    static var txListGreen: UIColor {
        return UIColor(red: 0.0, green: 169.0/255.0, blue: 157.0/255.0, alpha: 1.0)
    }
    
    static var blueButtonText: UIColor {
        return UIColor(red: 127.0/255.0, green: 181.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
    
    static var darkGray: UIColor {
        return UIColor(red: 84.0/255.0, green: 104.0/255.0, blue: 117.0/255.0, alpha: 1.0)
    }
    
    static var lightGray: UIColor {
        return UIColor(red: 179.0/255.0, green: 192.0/255.0, blue: 200.0/255.0, alpha: 1.0)
    }
    
    static var mediumGray: UIColor {
        return UIColor(red: 120.0/255.0, green: 143.0/255.0, blue: 158.0/255.0, alpha: 1.0)
    }
    
    static var receivedGreen: UIColor {
        return UIColor(red: 155.0/255.0, green: 213.0/255.0, blue: 85.0/255.0, alpha: 1.0)
    }
    
    static var failedRed: UIColor {
        return UIColor(red: 244.0/255.0, green: 107.0/255.0, blue: 65.0/255.0, alpha: 1.0)
    }
    
    static var statusIndicatorActive: UIColor {
        return UIColor(red: 75.0/255.0, green: 119.0/255.0, blue: 243.0/255.0, alpha: 1.0)
    }
    
    static var grayBackground: UIColor {
        return UIColor(red: 224.0/255.0, green: 229.0/255.0, blue: 232.0/255.0, alpha: 1.0)
    }
    
    static var whiteBackground: UIColor {
        return UIColor(red: 249.0/255.0, green: 251.0/255.0, blue: 254.0/255.0, alpha: 1.0)
    }
    
    static var separator: UIColor {
        return UIColor(red: 236.0/255.0, green: 236.0/255.0, blue: 236.0/255.0, alpha: 1.0)
    }
}

extension UIColor {
    static func fromHex(_ hex: String) -> UIColor {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if sanitized.hasPrefix("#") {
            sanitized.remove(at: sanitized.startIndex)
        }
        guard sanitized.count == 6 else { return .lightGray }
        var rgbValue: UInt32 = 0
        Scanner(string: sanitized).scanHexInt32(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0))
    }
    
    var toHex: String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
