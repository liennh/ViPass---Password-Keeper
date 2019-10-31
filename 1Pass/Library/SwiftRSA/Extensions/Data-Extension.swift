//
//  Data+Ex.swift
//  Journey
//
//  Created by Giacomo Leopizzi on 01/06/2017.
//  Copyright © 2017 Heart. All rights reserved.
//

import Foundation

extension Data {
    
    /// Join an array of Data in a contiguos Data object (but keep internally the structure of the separated Data).
    ///
    /// - Parameter data: Array of Data object to join.
    /// - Returns: Joined Data object.
    static func join(data: [Data]) -> Data {
        // Soon here there will be the result.
        var joinedData = Data()
        
        for data in data {
            // Lenght of the data to join in big endian format (just for avoid processor architecture issues).
            var dataLenght = UInt32(data.count).bigEndian
            // Calculate the size of the UInt32 (of course it will be the same every time...).
            let size = MemoryLayout<UInt32>.size
            // Get the pointer to the first (of the size bytes) of the dataLenght.
            let bytePointer = withUnsafePointer(to: &dataLenght) {
                $0.withMemoryRebound(to: UInt8.self, capacity: size) {
                    UnsafeBufferPointer(start: $0, count: size)
                }
            }
            // Move the bytes inside an array.
            let lenghtBytes = Array(bytePointer)
            
            // Append the lenght bytes and the data itself to the joinedData object.
            joinedData.append(contentsOf: lenghtBytes)
            joinedData.append(contentsOf: data)
        }
        
        return joinedData
    }
    
    static func disjoin(data: Data) -> [Data]? {
        // Calculate the size of the UInt32 (of course it will be the same every time...).
        let size = MemoryLayout<UInt32>.size
        
        // Check that the data is big enought to start the process.
        guard data.count >= size else {
            return nil
        }
        
        // Keep track of the last analized byte of the input data.
        var delta = 0
        // Create a container for the output data.
        var outputData: [Data] = []
        
        repeat {
            // Calculate the range of the data lenght (UInt32 big endian).
            let rangeDataLenghtRange = Range(uncheckedBounds: (delta, delta + size))
            // Get the data lenght bytes
            let dataLenght = data.subdata(in: rangeDataLenghtRange)
            // Get the lenght in high level Swift.Int from the dataLenght (Data) object.
            let lenght = Int(UInt32(bigEndian: dataLenght
                .withUnsafeBytes({ (bytes: UnsafePointer<UInt8>) in bytes })
                .withMemoryRebound(to: UInt32.self, capacity: 1) { $0.pointee }
            ))
            
            // Calculate the range of the data to extract.
            let currentDataRange = Range(uncheckedBounds: (
                rangeDataLenghtRange.upperBound,
                rangeDataLenghtRange.upperBound + lenght
            ))
            // Get the data to extract.
            let currentData = data.subdata(in: currentDataRange)
            
            // Move the delta.
            delta += lenght + size
            
            // Append the extracted data to the output array.
            outputData.append(currentData)
            
        } while data.count - delta >= size
        
        return outputData
        
    }
    
}
