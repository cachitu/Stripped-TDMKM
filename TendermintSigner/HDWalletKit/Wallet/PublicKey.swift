//
//  PublicKey.swift
//  HDWalletKit
//
//  Created by Pavlo Boiko on 10/4/18.
//  Copyright © 2018 Essentia. All rights reserved.
//

import Foundation

public struct PublicKey {
    public let rawPrivateKey: Data
    public let coin: TendermintCoin
    
    public init(privateKey: Data, coin: TendermintCoin) {
        self.rawPrivateKey = privateKey
        self.coin = coin
    }
    
    // NOTE: https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki
    public var address: String {
        switch coin {
        case .cosmos:
            return generateTdmAddress(prefix: "cosmos")
        case .terra:
            return generateTdmAddress(prefix: "terra")
        case .iris:
            return generateTdmAddress(prefix: "iaa")
        case .kava:
            return generateTdmAddress(prefix: "kava")
        }
    }
    
    public var publicAddress: String {
        switch coin {
        case .cosmos:
            return generateTdmPublicAddress(prefix: "cosmos")
        case .terra:
            return generateTdmPublicAddress(prefix: "terra")
        case .iris:
            return generateTdmPublicAddress(prefix: "iaa")
        case .kava:
            return generateTdmPublicAddress(prefix: "kava")
        }
    }
    
    public var validator: String {
        switch coin {
        case .cosmos:
            return generateTdmValidator(prefix: "cosmos")
        case .terra:
            return generateTdmValidator(prefix: "terra")
        case .iris:
            return generateTdmValidator(prefix: "iaa")
        case .kava:
            return generateTdmValidator(prefix: "kava")
        }
    }
    
    public var publicValidator: String {
        switch coin {
        case .cosmos:
            return generateTdmPublicValidator(prefix: "cosmos")
        case .terra:
            return generateTdmPublicValidator(prefix: "terra")
        case .iris:
            return generateTdmPublicValidator(prefix: "iaa")
        case .kava:
            return generateTdmPublicValidator(prefix: "kava")
        }
    }

    func generateTdmAddress(prefix: String) -> String {
        
        let publicKey = getPublicKey(compressed: true)
        let payload = RIPEMD160.hash(publicKey.sha256()).toHexString()
        let address = Bech32.encode1(Data(hex: payload), prefix: prefix)
        
        return address
    }

    func generateTdmPublicAddress(prefix: String) -> String {
        
        let publicKey = getPublicKey(compressed: true)
        let phex = "EB5AE98721" + publicKey.toHexString()
        let pubAddress = Bech32.encode1(Data(hex: phex), prefix: prefix + "pub")
        
        return pubAddress
    }

    func generateTdmValidator(prefix: String) -> String {
        
        let publicKey = getPublicKey(compressed: true)
        let payload = RIPEMD160.hash(publicKey.sha256()).toHexString()
        let address = Bech32.encode1(Data(hex: payload), prefix: prefix + "valoper")
        
        return address
    }
    
    func generateTdmPublicValidator(prefix: String) -> String {
        
        let publicKey = getPublicKey(compressed: true)
        let phex = "EB5AE98721" + publicKey.toHexString()
        let pubAddress = Bech32.encode1(Data(hex: phex), prefix: prefix + "valoperpub")
        
        return pubAddress
    }

    public func get() -> String {
        let publicKey = getPublicKey(compressed: true)
        return publicKey.toHexString()
    }
    
    public func getBase64() -> String {
        let publicKey = getPublicKey(compressed: true)
        return publicKey.base64EncodedString()
    }

    public var data: Data {
        return Data(hex: get())
    }
    
    public func getPublicKey(compressed: Bool) -> Data {
        return Crypto.generatePublicKey(data: rawPrivateKey, compressed: compressed)
    }
}
