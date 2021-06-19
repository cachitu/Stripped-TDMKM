//
//  Coin.swift
//  HDWalletKit
//
//  Created by Pavlo Boiko on 10/3/18.
//  Copyright © 2018 Essentia. All rights reserved.
//

import Foundation

public enum TendermintCoin {
    case stargate
    case terra
    case terra_118
    case iris
    case iris_fuxi
    case kava
    case kava_118
    case bitsong
    case emoney
    case regen
    case certik
    case microtick
    case agoric
    case osmosis

    //https://github.com/satoshilabs/slips/blob/master/slip-0132.md
    public var privateKeyVersion: UInt32 {
        return 0x0488ADE4
    }
    
    public var publicKeyVersion: UInt32 {
        return 0x0488B21E
    }
    
    public var publicKeyHash: UInt8 {
        return 0x00
    }
    
    //https://www.reddit.com/r/litecoin/comments/6vc8tc/how_do_i_convert_a_raw_private_key_to_wif_for/
    public var wifPrefix: UInt8 {
        return 0x80
    }
    
    public var scripthash: UInt8 {
        return 0x80
    }
    
    public var addressPrefix: String {
        switch self {
        case .stargate: return "cosmos"
        case .terra, .terra_118: return "terra"
        case .iris: return "iaa"
        case .iris_fuxi: return "faa"
        case .kava, .kava_118: return "kava"
        case .bitsong: return "bitsong"
        case .emoney: return "emoney"
        case .regen: return "regen"
        case .certik: return "certik"
        case .microtick: return "micro"
        case .agoric: return "agoric"
        case .osmosis: return "osmo"
        }
    }
    
    public var validatorPrefix: String {
        switch self {
        case .stargate: return "cosmos"
        case .terra, .terra_118: return "terra"
        case .iris: return "iva"
        case .iris_fuxi: return "fva"
        case .kava, .kava_118: return "kava"
        case .bitsong: return "bitsong"
        case .emoney: return "emoney"
        case .regen: return "regen"
        case .certik: return "certik"
        case .microtick: return "micro"
        case .agoric: return "agoric"
        case .osmosis: return "osmo"
        }
    }

    public var coinType: UInt32 {
        switch self {
        case .terra: return 330
        case .kava: return 459
        case .bitsong: return 639
        case .agoric: return 564
        default: return 118
        }
    }
}
