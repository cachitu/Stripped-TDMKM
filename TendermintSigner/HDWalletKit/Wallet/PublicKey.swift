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
        case .terra, .terra_118:
            return generateTdmAddress(prefix: "terra")
        case .iris:
            return generateTdmAddress(prefix: "iaa")
        case .iris_fuxi:
            return generateTdmAddress(prefix: "faa")
        case .kava:
            return generateTdmAddress(prefix: "kava")
        case .bitsong:
            return generateTdmAddress(prefix: "bitsong")
        }
    }
    
    public var publicAddress: String {
        switch coin {
        case .cosmos:
            return generateTdmPublicAddress(prefix: "cosmos")
        case .terra, .terra_118:
            return generateTdmPublicAddress(prefix: "terra")
        case .iris:
            return generateTdmPublicAddress(prefix: "iaa")
        case .iris_fuxi:
            return generateTdmPublicAddress(prefix: "faa")
        case .kava:
            return generateTdmPublicAddress(prefix: "kava")
        case .bitsong:
            return generateTdmPublicAddress(prefix: "bitsong")
        }
    }
    
    public var validator: String {
        switch coin {
        case .cosmos:
            return generateTdmValidator(prefix: "cosmos")
        case .terra, .terra_118:
            return generateTdmValidator(prefix: "terra")
        case .iris:
            return generateTdmValidator(prefix: "", customPrefix: "iva")
        case .iris_fuxi:
            return generateTdmValidator(prefix: "", customPrefix: "fva")
        case .kava:
            return generateTdmValidator(prefix: "kava")
        case .bitsong:
            return generateTdmValidator(prefix: "bitsong")
        }
    }
    
    public var publicValidator: String {
        switch coin {
        case .cosmos:
            return generateTdmPublicValidator(prefix: "cosmos")
        case .terra, .terra_118:
            return generateTdmPublicValidator(prefix: "terra")
        case .iris:
            return generateTdmPublicValidator(prefix: "iaa")
        case .iris_fuxi:
            return generateTdmPublicValidator(prefix: "faa")
        case .kava:
            return generateTdmPublicValidator(prefix: "kava")
        case .bitsong:
            return generateTdmPublicValidator(prefix: "bitsong")
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

    func generateTdmValidator(prefix: String, customPrefix: String? = nil) -> String {
        
        let publicKey = getPublicKey(compressed: true)
        let payload = RIPEMD160.hash(publicKey.sha256()).toHexString()
        var address = Bech32.encode1(Data(hex: payload), prefix: prefix + "valoper")
        if let custom = customPrefix {
            address = Bech32.encode1(Data(hex: payload), prefix: custom)
        }
        
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
