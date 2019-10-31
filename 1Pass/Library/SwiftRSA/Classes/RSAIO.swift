//
//  RSAIO.swift
//  BunqAPI
//
//  Created by Alex Tran-Qui on 27/03/2017.
//
//  Copy of Zewo/OpenSSL/IO.swift (https://github.com/Zewo/OpenSSL)
//  Zewo is distributed under the MIT license (https://github.com/Zewo/OpenSSL/blob/master/LICENSE)

// import COpenSSL
import Foundation

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

private enum SSLIOError: Error {
    case io(description: String)
    case shouldRetry(description: String)
    case unsupportedMethod(description: String)
}

internal class RSAIO {
    
    internal enum Method {
        case memory
        
        var method: UnsafeMutablePointer<BIO_METHOD> {
            switch self {
            case .memory:
                return BIO_s_mem()
            }
        }
    }
    
    internal var bio: UnsafeMutablePointer<BIO>?
    
    public init(method: Method = .memory) throws {
        OpenSSL.initialize()
        bio = BIO_new(method.method)
        
        if bio == nil {
            throw SSLIOError.io(description: OpenSSL.errorDescription)
        }
    }
    
    public convenience init(buffer: Data) throws {
        try self.init()
        let pointer = buffer.withUnsafeBytes({ (bytes: UnsafePointer<UInt8>) in bytes })
        let bufferPointer = UnsafeBufferPointer(start: pointer, count: buffer.count)
        _ = try write(bufferPointer)
    }
    
    public convenience init(buffer: String) throws {
        guard let data = buffer.data(using: .utf8) else {
            throw RSA.Custom.error(description: "Unable to convert to utf8 the key string")
        }
    
        try self.init(buffer: data)
    }
    
    // TODO: crash???
    	deinit {
    		BIO_free(bio)
    	}
    
    public var pending: Int {
        return BIO_ctrl_pending(bio)
    }
    
    public var shouldRetry: Bool {
        return (bio!.pointee.flags & BIO_FLAGS_SHOULD_RETRY) != 0
    }
    
    // Make this all or nothing
    public func write(_ buffer: UnsafeBufferPointer<UInt8>) throws -> Int {
        guard !buffer.isEmpty else {
            return 0
        }
        
        let bytesWritten = BIO_write(bio, buffer.baseAddress!, Int32(buffer.count))
        
        guard bytesWritten >= 0 else {
            if shouldRetry {
                throw SSLIOError.shouldRetry(description: OpenSSL.errorDescription)
            } else {
                throw SSLIOError.io(description: OpenSSL.errorDescription)
            }
        }
        
        return Int(bytesWritten)
    }
    
    public func read(into: UnsafeMutableBufferPointer<UInt8>) throws -> Int {
        guard !into.isEmpty else {
            return 0
        }
        
        let bytesRead = BIO_read(bio, into.baseAddress!, Int32(into.count))
        
        guard bytesRead >= 0 else {
            if shouldRetry {
                throw SSLIOError.shouldRetry(description: OpenSSL.errorDescription)
            } else {
                throw SSLIOError.io(description: OpenSSL.errorDescription)
            }
        }
        
        return Int(bytesRead)
    }
}
