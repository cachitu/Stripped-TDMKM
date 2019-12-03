//
//  LocalClient.swift
//  Cosmos Client
//
//  Created by kytzu on 23/03/2019.
//  Copyright © 2019 Calin Chitu. All rights reserved.
//

import Foundation

public class TendermintClient {
    
    public let coinType: TendermintCoin
    
    public init(coin: TendermintCoin) {
        self.coinType = coin
    }
    
    public func generateMnemonic() -> String {
        return Mnemonic.create()
    }
    
    public func recoverKey(from mnemonic: String) -> Account {
        
        let seed = SeedFactory().createSeed(mnemonic: mnemonic)
        let wallet = Wallet(seed: seed, coin: coinType)
        let account = wallet.generateAccount()
        
        return account
    }
    
    public func signHash(transferData: Data, hdAccount: Account) -> String {
        var hash = ""
        var data = Data()
        
        do {
            try data = hdAccount.privateKey.sign(hash: transferData)
            hash = data.base64EncodedString()
        } catch {
            print("failed")
        }
        hash = String(hash.dropLast().dropLast())
        hash += "=="
        
        return hash
    }
    
    public func signHashTest(transferData: Data, hdAccount: Account) -> String {
        var hash = ""
        var data = Data()
        
        do {
            try data = hdAccount.privateKey.sign(hash: transferData)
            print(data.bytes)
            hash = data.base64EncodedString()
        } catch {
            print("failed")
        }
        hash = String(hash.dropLast().dropLast())
        hash += "=="
        
        return hash
    }

}
