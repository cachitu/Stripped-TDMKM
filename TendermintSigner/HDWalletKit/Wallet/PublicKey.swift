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
        return generateTdmAddress(prefix: coin.addressPrefix)
    }
    
    public var publicAddress: String {
        return generateTdmPublicAddress(prefix: coin.addressPrefix)
    }
    
    public var validator: String {
        switch coin {
        case .iris: return generateTdmValidator(prefix: "", customPrefix: coin.validatorPrefix)
        case .iris_fuxi: return generateTdmValidator(prefix: "", customPrefix: coin.validatorPrefix)
        default: return generateTdmValidator(prefix: coin.addressPrefix)
        }
    }
    
    public var publicValidator: String {
        return generateTdmPublicValidator(prefix: coin.addressPrefix)
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
