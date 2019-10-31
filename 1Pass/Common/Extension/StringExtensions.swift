//
//  StringExtensions.swift
//  SwifterSwift
//
//  Created by Omar Albeik on 8/5/16.
//  Copyright © 2016 Omar Albeik. All rights reserved.
//

import Foundation


#if os(macOS)
import Cocoa
#else
import UIKit
#endif

// MARK: - Properties
public extension String {
    func toData() -> Data {
        return self.data(using: .utf8)!
    }
    
    var bytes: [UInt8] {
        return Array(utf8)
    }
    
    public var length: Int {
        return self.count
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    func matches(for regex: String) -> Bool { // e.g: regex: "[0-9]" or "(123|456|333)$"
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            let arr:[String] = results.map {
                String(self[Range($0.range, in: self)!])
            }
            return (arr.isEmpty ? false : true)
        } catch let error {
            DDLog("invalid regex: \(error.localizedDescription)")
            return false
        }
    }
    
    func hasWhiteSpace() -> Bool {
        return self.contains(" ")
    }
    
    func widthWithConstrainedHeight(_ height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat? {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    public var firstCharacter:String! {
        if self.isEmpty {
            return ""
        }
        
        let str = String(self.first!)
        return str
    }
    
    public func toDictionary() -> [String:Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                DDLog(error.localizedDescription)
            }
        }
        return nil
    }
    
    public func removeAll(sub:String) -> String {
        return replacingOccurrences(of: sub, with: "")
    }
    
    // https://www.appcoda.com/qr-code-generator-tutorial/
    func qrCode(outputSize:CGSize) -> UIImage? {
        let data = self.data(using: String.Encoding.utf8) // ascii
        return data?.qrCode(outputSize:outputSize)
    }
    
    /// SwifterSwift: String by replacing part of string with another string.
    ///
    /// - Parameters:
    ///   - substring: old substring to find and replace.
    ///   - newString: new string to insert in old string place.
    /// - Returns: string after replacing substring with newString.
    public func replacing(_ substring: String, with newString: String) -> String {
        return replacingOccurrences(of: substring, with: newString)
    }
    
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.endIndex.encodedOffset)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.endIndex.encodedOffset
        } else {
            return false
        }
    }
    
    /// SwifterSwift: Safely subscript string with index.
    ///
    /// - Parameter i: index.
    public subscript(i: Int) -> String? {
        guard i >= 0 && i < self.count else {
            return nil
        }
        return String(self[index(startIndex, offsetBy: i)])
    }
    
    /// SwifterSwift: Safely subscript string within a half-open range.
    ///
    /// - Parameter range: Half-open range.
    public subscript(range: CountableRange<Int>) -> String? {
        guard let lowerIndex = index(startIndex, offsetBy: max(0,range.lowerBound), limitedBy: endIndex) else {
            return nil
        }
        guard let upperIndex = index(lowerIndex, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) else {
            return nil
        }
        return String(self[lowerIndex..<upperIndex])
    }
    
    func isLessThan(_ str:String) -> Bool {
        if self.caseInsensitiveCompare(str) == ComparisonResult.orderedAscending {
            return true
        } else {
            return false
        }
    }
    
    func isGreaterThan(_ str:String) -> Bool {
        if self.caseInsensitiveCompare(str) == ComparisonResult.orderedDescending{
            return true
        } else {
            return false
        }
    }
    
    func isEqualWith(_ str:String) -> Bool {
        if self.caseInsensitiveCompare(str) == ComparisonResult.orderedSame {
            return true
        } else {
            return false
        }
    }
    
}
