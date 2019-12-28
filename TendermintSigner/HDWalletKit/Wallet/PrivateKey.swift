//
//  PrivateKey.swift
//  HDWalletKit
//
//  Created by Pavlo Boiko on 10/4/18.
//  Copyright © 2018 Essentia. All rights reserved.
//

import Foundation
import CryptoKit

enum PrivateKeyType {
    case hd
    case nonHd
}

public struct PrivateKey {
    
    public let raw: Data
    public let chainCode: Data
    public let index: UInt32
    public let coin: TendermintCoin
    private var keyType: PrivateKeyType
    
    public init(seed: Data, coin: TendermintCoin) {
        
        let key = SymmetricKey(data: "Bitcoin seed".data(using: .ascii)!)
        let authentication = HMAC<SHA512>.authenticationCode(for: seed, using: key)
        let output = Data(authentication)
        
        self.raw = output[0..<32]
        self.chainCode = output[32..<64]
        self.index = 0
        self.coin = coin
        self.keyType = .hd
    }
    
    private init(privateKey: Data, chainCode: Data, index: UInt32, coin: TendermintCoin) {
        self.raw = privateKey
        self.chainCode = chainCode
        self.index = index
        self.coin = coin
        self.keyType = .hd
    }
    
    public var publicKey: PublicKey {
        return PublicKey(privateKey: raw, coin: coin)
    }
    
    private func wif() -> String {
        var data = Data()
        data += coin.wifPrefix
        data += raw
        data += UInt8(0x01)
        data += data.doubleSHA256.prefix(4)
        return Base58.encode(data)
    }
    
    public func get() -> String {
        switch self.coin {
        case .cosmos, .terra, .terra_118, .iris, .iris_fuxi, .kava, .bitsong, .emoney:
            return self.raw.toHexString()
       }
    }
    
    public func derived(at node: DerivationNode) -> PrivateKey {
        guard keyType == .hd else { fatalError() }
        let edge: UInt32 = 0x80000000
        guard (edge & node.index) == 0 else { fatalError("Invalid child index") }
        
        var data = Data()
        switch node {
        case .hardened:
            data += UInt8(0)
            data += raw
        case .notHardened:
            let legacy_data = Crypto.generatePublicKey(data: raw, compressed: true)
            data += legacy_data
        }
        
        let derivingIndex = CFSwapInt32BigToHost(node.hardens ? (edge | node.index) : node.index)
        data += derivingIndex
        
        let key = SymmetricKey(data: chainCode)
        let authentication = HMAC<SHA512>.authenticationCode(for: data, using: key)
        let digest = Data(authentication)

        let factor = BInt(data: digest[0..<32])
        
        let curveOrder = BInt(hex: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")!
        let derivedPrivateKey = ((BInt(data: raw) + factor) % curveOrder).data
        let derivedChainCode = digest[32..<64]
        return PrivateKey(
            privateKey: derivedPrivateKey,
            chainCode: derivedChainCode,
            index: derivingIndex,
            coin: coin
        )
    }
    
    public func sign(hash: Data) throws -> Data {
        return try Crypto.sign(hash, privateKey: raw)
    }
}

