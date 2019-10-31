//
//  UIView+Extension.swift
//  ViPass
//
//  Created by Ngo Lien on 4/29/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func toImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    /*
     let myCustomView: CustomView = UIView.fromNib()
     or
     let myCustomView: CustomView = .fromNib()
     Refer to https://stackoverflow.com/questions/24857986/load-a-uiview-from-nib-in-swift
    */
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    func doTransform(value:CGFloat) {
        self.transform = CGAffineTransform(scaleX: value, y: value)
    }
    
    func moveUp(distance:CGFloat) {
        var frame = self.frame
        frame.origin.y -= distance
        self.frame = frame
    }
    
    func moveDown(distance:CGFloat) {
        var frame = self.frame
        frame.origin.y += distance
        self.frame = frame
    }
    
    func moveLeft(distance:CGFloat) {
        var frame = self.frame
        frame.origin.x -= distance
        self.frame = frame
    }
    
    func moveRight(distance:CGFloat) {
        var frame = self.frame
        frame.origin.x += distance
        self.frame = frame
    }
    
    func increaseHeight(value:CGFloat) {
        var frame = self.frame
        frame.size.height += value
        self.frame = frame
    }
    
    func decreaseHeight(value:CGFloat) {
        var frame = self.frame
        frame.size.height -= value
        self.frame = frame
    }
    
    func increaseWidth(value:CGFloat) {
        var frame = self.frame
        frame.size.width += value
        self.frame = frame
    }
    
    func decreaseWidth(value:CGFloat) {
        var frame = self.frame
        frame.size.width -= value
        self.frame = frame
    }
}
