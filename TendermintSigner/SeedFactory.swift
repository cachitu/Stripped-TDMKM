//
//  SeedFactory.swift
//  TendermintSigner
//
//  Created by Calin Chitu on 16/11/2019.
//  Copyright © 2019 Calin Chitu. All rights reserved.
//

import Foundation
import CryptoKit
import CommonCrypto

public class SeedFactory {
    
    var derivedKeyData: Data?
    
    
    func createSeed(mnemonic: String) -> Data {
        guard let salt = ("mnemonic").decomposedStringWithCompatibilityMapping.data(using: .utf8) else {
            fatalError("Nomalizing salt failed in \(self)")
        }
        return pbkdf2SHA512(password: mnemonic, salt: salt, keyByteCount: 64, rounds: 2048)!
    }

    func pbkdf2SHA512(password: String, salt: Data, keyByteCount: Int, rounds: Int) -> Data? {
        return pbkdf2(hash:CCPBKDFAlgorithm(kCCPRFHmacAlgSHA512), password:password, salt: salt, keyByteCount:keyByteCount, rounds:rounds)
    }
    
    func pbkdf2(hash :CCPBKDFAlgorithm, password: String, salt: Data, keyByteCount: Int, rounds: Int) -> Data? {
        
        derivedKeyData = Data(repeating:0, count:keyByteCount)

        guard let data = derivedKeyData else { return nil }
        
        let passwordData = password.data(using:String.Encoding.utf8)!
        
        let _ = derivedKeyData!.withUnsafeMutableBytes { (derivedKeyBytes: UnsafeMutableRawBufferPointer) -> Int in
            
            let unsafeDBufferPointer = derivedKeyBytes.bindMemory(to: UInt8.self)
            let unsafeDPointer = unsafeDBufferPointer.baseAddress!

            salt.withUnsafeBytes { (saltBytes: UnsafeRawBufferPointer) in
                
                let unsafeBufferPointer = saltBytes.bindMemory(to: UInt8.self)
                let unsafePointer = unsafeBufferPointer.baseAddress!
                
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    password, passwordData.count,
                    unsafePointer, salt.count,
                    hash,
                    UInt32(rounds),
                    unsafeDPointer, data.count)
            }
            
            return 0
        }

        return derivedKeyData
    }
}

