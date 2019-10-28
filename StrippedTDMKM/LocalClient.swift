//
//  LocalClient.swift
//  Cosmos Client
//
//  Created by kytzu on 23/03/2019.
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

public class LocalClient {
    
    var coinType: HDCoin = .cosmos
    
    func test() {
        let mnemonic = "century possible car impact mutual grace place bomb drip expand search cube border elite ensure draft immune warrior route steak cram confirm kit sudden"
        
 
        //let seed = Mnemonic_kk.createSeed(mnemonic: mnemonic, withPassphrase: "")
        //print(seed.base64EncodedString())
        
        let seed = SeedFactory().createSeed(mnemonic: mnemonic)

        let wallet = Wallet(seed: seed, coin: coinType)
        let account = wallet.generateAccount()
        
        switch coinType {
        case .cosmos:
            print("cosmos14kxxegskp8lfuhpwj27hrv9uj8ufjvhzu5ucv5")
            print(account.address)
            print("cosmospub1addwnpepqvcu4mlcjpacdk28xh9e3ex0t5yrw877ylp82gpg8j7y32qf3zdjys07yww")
            print(account.publicAddress)
            print("cosmosvaloper14kxxegskp8lfuhpwj27hrv9uj8ufjvhzeqgdq8")
            print(account.validator)
            print("cosmosvaloperpub1addwnpepqvcu4mlcjpacdk28xh9e3ex0t5yrw877ylp82gpg8j7y32qf3zdjyevmfpa")
            print(account.publicValidator)

        default:
            print(account.address)
            print(account.publicAddress)
            print(account.validator)
            print(account.publicValidator)
        }
    }
    
    public func generateMnemonic() -> String {
        return Mnemonic.create()
    }
    
    func recoverKey(from mnemonic: String, name: String, password: String) {
        
        let seed = Mnemonic.createSeed(mnemonic: mnemonic)
        let wallet = Wallet(seed: seed, coin: coinType)
        let account = wallet.generateAccount()
        
        print(account.address)
        print(account.publicAddress)
        print(account.validator)
        print(account.publicValidator)
    }
    
    public func createKey(with name: String, password: String) {
        let mnemonic = Mnemonic.create()
        recoverKey(from: mnemonic, name: name, password: password)
    }
    
    public func sign(
        transferData: TransactionTx?,
        hdAccount: Account,
        accNumber: String,
        accSequence: String,
        chainId: String,
        completion:((RestResult<[TransactionTx]>) -> Void)?) {
        
        var signable = TxSignable()
        signable.accountNumber = accNumber
        signable.chainId = chainId
        signable.fee = transferData?.value?.fee
        signable.memo = transferData?.value?.memo
        signable.msgs = transferData?.value?.msg
        signable.sequence = accSequence
        
        var jsonData = Data()
        var jsString = ""
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        encoder.dataEncodingStrategy = .base64
        do {
            jsonData = try encoder.encode(signable)
            jsString = String(data: jsonData, encoding: String.Encoding.macOSRoman) ?? ""
        } catch {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Could not encode data"])
            completion?(.failure(error))
        }
        jsString = jsString.replacingOccurrences(of: "\\", with: "")

        let goodBuffer = jsString.data(using: .ascii)?.sha256() ?? Data()

        let type = "tendermint/PubKeySecp256k1"
        let value = hdAccount.privateKey.publicKey.getBase64()
        var hash = ""

        do {
            try hash = hdAccount.privateKey.sign(hash: goodBuffer).base64EncodedString()
        } catch {
            print("failed")
        }
        hash = String(hash.dropLast().dropLast())
        hash += "=="
        
        let sig = TxValueSignature(
            sig: hash,
            type: type,
            value: value,
            accNum: accNumber,
            seq: accSequence)
        var signed = transferData
        signed?.value?.signatures = [sig]

        if let final = signed {
            completion?(.success([final]))
        }
    }
}


public struct TypePrefix {
    static let MsgSend = "2A2C87FA"
    static let NewOrderMsg = "CE6DC043"
    static let CancelOrderMsg = "166E681B"
    static let StdTx = "F0625DEE"
    static let PubKeySecp256k1 = "EB5AE987"
    static let SignatureSecp256k1 = "7FC4A495"
}

public struct TransactionTx: Codable {
    
    public let type: String?
    public var value: TxValue?
    
    enum CodingKeys : String, CodingKey {
        case type
        case value
    }
}

public struct TxValue: Codable {
    
    public let msg: [TxValueMsg]?
    public let fee: TxValueFee?
    public var signatures: [TxValueSignature]?
    public let memo: String?
    
    enum CodingKeys : String, CodingKey {
        case msg
        case fee
        case signatures
        case memo
    }
}

public struct TxSignable: Codable {
    
    public var accountNumber: String?
    public var chainId: String?
    public var fee: TxValueFee?
    public var memo: String?
    public var msgs: [TxValueMsg]?
    public var sequence: String?

    public init() {}
    
    enum CodingKeys : String, CodingKey {
        case accountNumber = "account_number"
        case chainId = "chain_id"
        case fee
        case memo
        case msgs
        case sequence
    }
}

public struct TxValueSignature: Codable {
    
    public let signature: String?
    public let pubKey: TxValSigPubKey?
    public let accountNumber: String?
    public let sequence: String?
    
    public init(sig: String, type: String, value: String, accNum: String, seq: String) {
        signature = sig
        pubKey = TxValSigPubKey(type: type, value: value)
        accountNumber = accNum
        sequence = seq
    }
    
    enum CodingKeys : String, CodingKey {
        case signature
        case pubKey = "pub_key"
        case accountNumber = "account_number"
        case sequence
    }
}

public struct TxValSigPubKey: Codable {
    
    public let type: String?
    public let value: String?
    
    public init(type: String, value: String) {
        self.type = type
        self.value = value
    }
    
    enum CodingKeys : String, CodingKey {
        case type
        case value
    }
}

public struct TxValueFee: Codable {
    
    public let amount: [TxFeeAmount]?
    public let gas: String?
    
    enum CodingKeys : String, CodingKey {
        case amount
        case gas
    }
}

public struct TxFeeAmount: Codable {
    
    public let amount: String?
    public let denom: String?
    
    enum CodingKeys : String, CodingKey {
        case amount
        case denom
    }
}

public struct TxValueMsg: Codable {
    
    public let type: String?
    public let value: TxMsgVal?
    
    enum CodingKeys : String, CodingKey {
        case type
        case value
    }
}

public struct TxMsgVal: Codable, PropertyLoopable {
    
    public let delegatorAddr: String?
    public let validatorAddr: String?
    public let validatorSrcAddr: String?
    public let validatorDstAddr: String?
    public let sharesAmount: String?
    public let fromAddr: String?
    public let toAddr: String?
    public let proposalId: String?
    public let depositor: String?
    public let title: String?
    public let description: String?
    public let proposalType: String?
    public let proposer: String?
    public let voter: String?
    public let option: String?
    public let initialDeposit: [TxFeeAmount]?
    public let delegation: TxFeeAmount?
    public let amount: DynamicAmount?
    public let value: TxFeeAmount?
    
    //terra swap
    public let trader: String?
    public let offerCoin: TxFeeAmount?
    public let askDenom: String?
    
    public enum DynamicAmount: Codable {
        case amount(TxFeeAmount)
        case amounts([TxFeeAmount])
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode(TxFeeAmount.self) {
                self = .amount(x)
                return
            }
            if let x = try? container.decode([TxFeeAmount].self) {
                self = .amounts(x)
                return
            }
            throw DecodingError.typeMismatch(DynamicAmount.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for MyValue"))
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .amount(let x):
                try container.encode(x)
            case .amounts(let x):
                try container.encode(x)
            }
        }
    }
    
    enum CodingKeys : String, CodingKey {
        case delegatorAddr = "delegator_address"
        case validatorAddr = "validator_address"
        case validatorSrcAddr = "validator_src_address"
        case validatorDstAddr = "validator_dst_address"
        case sharesAmount = "shares_amount"
        case fromAddr = "from_address"
        case toAddr = "to_address"
        case proposalId = "proposal_id"
        case depositor
        case title
        case description
        case proposalType = "proposal_type"
        case proposer
        case voter
        case option
        case initialDeposit = "initial_deposit"
        case delegation
        case amount
        case value
        
        //terra swap
        case trader
        case offerCoin = "offer_coin"
        case askDenom = "ask_denom"
    }
}

public enum RestResult<Value> {
    case success(Value)
    case failure(NSError)
}

public protocol PropertyLoopable {
    func allProperties() throws -> [String: Any?]
}

extension PropertyLoopable {
    public func allProperties() throws -> [String: Any?] {
        
        var result: [String: Any?] = [:]
        
        let mirror = Mirror(reflecting: self)
        
        guard let _ = mirror.displayStyle else {
            throw NSError(domain: "ip.sx", code: 0, userInfo: nil)
        }
        
        for (labelMaybe, valueMaybe) in mirror.children {
            guard let label = labelMaybe else {
                continue
            }
            
            result[label] = valueMaybe
        }
        
        return result
    }
}

enum HmacAlgorithm {
    case sha1, md5, sha256, sha384, sha512, sha224
    var algorithm: CCHmacAlgorithm {
        var alg = 0
        switch self {
        case .sha1:
            alg = kCCHmacAlgSHA1
        case .md5:
            alg = kCCHmacAlgMD5
        case .sha256:
            alg = kCCHmacAlgSHA256
        case .sha384:
            alg = kCCHmacAlgSHA384
        case .sha512:
            alg = kCCHmacAlgSHA512
        case .sha224:
            alg = kCCHmacAlgSHA224
        }
        return CCHmacAlgorithm(alg)
    }
    var digestLength: Int {
        var len: Int32 = 0
        switch self {
        case .sha1:
            len = CC_SHA1_DIGEST_LENGTH
        case .md5:
            len = CC_MD5_DIGEST_LENGTH
        case .sha256:
            len = CC_SHA256_DIGEST_LENGTH
        case .sha384:
            len = CC_SHA384_DIGEST_LENGTH
        case .sha512:
            len = CC_SHA512_DIGEST_LENGTH
        case .sha224:
            len = CC_SHA224_DIGEST_LENGTH
        }
        return Int(len)
    }
}

extension String {
    func hmac(algorithm: HmacAlgorithm, key: String) -> String {
        var digest = [UInt8](repeating: 0, count: algorithm.digestLength)
        CCHmac(algorithm.algorithm, key, key.count, self, self.count, &digest)
        let data = Data(digest)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }
}
