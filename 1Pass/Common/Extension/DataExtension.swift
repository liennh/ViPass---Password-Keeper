//
//  File.swift
//  api-ViPass
//
//  Created by Ngo Lien on 5/15/18.
//

import Foundation
import CoreImage
import UIKit

extension Data {
    func toString() -> String {
        if let str = String(data: self, encoding: .utf8) {
            return str
        } else {
            return ""
        }
    }
    
    var bytes : [UInt8]{
        return [UInt8](self)
    }
    
    // https://www.appcoda.com/qr-code-generator-tutorial/
    func qrCode(outputSize:CGSize) -> UIImage? {
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(self, forKey: "inputMessage")
            //filter.setValue("Q", forKey: "inputCorrectionLevel") // Default M. values: L M Q H
            
            /*let transform = CGAffineTransform(scaleX: 3, y: 3) // 100, 100 or 1, 1
             if let output = filter.outputImage?.transformed(by: transform) {
             return UIImage(ciImage: output)
             }*/
            guard let qrcodeImage: CIImage = filter.outputImage else {
                return nil
            }
            // Display QrCode Image
            let scaleX = outputSize.width / qrcodeImage.extent.size.width
            let scaleY = outputSize.height / qrcodeImage.extent.size.height
            
            let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            return UIImage(ciImage: transformedImage)
        }
        return nil
    }
}

extension Array where Element == UInt8 {
    var data : Data{
        return Data(bytes:(self))
    }
}
