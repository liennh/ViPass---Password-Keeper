import UIKit
// Usage:
// let originalImage = UIImage(named: "cat")
// let tintedImage = originalImage.tint(UIColor(red: 0.9, green: 0.7, blue: 0.4, alpha: 1.0))
// reference: https://gist.github.com/iamjason/a0a92845094f5b210cf8
// modified to include retina
// Updated and tested for Swift 3.1
// refactored for memory purpose according to https://gist.github.com/lynfogeek/4b6ce0117fb0acdabe229f6d8759a139

import UIKit


extension UIImage {
    
    func tint(_ tintColor: UIColor?) -> UIImage {
        guard let tintColor = tintColor else { return self }
        return modifiedImage { context, rect in
            context.setBlendMode(.multiply)
            context.clip(to: rect, mask: self.cgImage!)
            tintColor.setFill()
            context.fill(rect)
        }.withRenderingMode(.alwaysOriginal)
    }
    
    private func modifiedImage( draw: (CGContext, CGRect) -> ()) -> UIImage {
        
        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        // correctly rotate image
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        return newImage
    }
    
}

