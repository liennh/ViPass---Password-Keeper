//
//  DictionaryExtension.swift
//  ViPass
//
//  Created by Ngo Lien on 5/22/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation

extension Dictionary {
    var json: String {
        let invalidJson = "" //"Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options:[])// .prettyPrinted
            let str = String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
            //let trimmedString = str.replacingOccurrences(of: "\n", with: "") // not needed
            return str
        } catch {
            return invalidJson
        }
    }
}

extension Array {
    var json: String {
        let invalidJson = "" //"Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])// .prettyPrinted
            let str = String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
            //let trimmedString = str.replacingOccurrences(of: "\n", with: "") // not needed
            return str
        } catch let error as NSError {
            DDLog("Error: \(error)")
            return invalidJson
        }
    }
}
