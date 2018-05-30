//
//  Token.swift
//  moyaTest
//
//  Created by 康佳兴 on 2018/5/23.
//  Copyright © 2018年 Kang. All rights reserved.
//

import Foundation

class Token {
    private var signKey: String = ""
    
    private var parameter: [String: Any]
    
    init(signKey: String, parameter: [String: Any]?) {
        self.parameter = parameter ?? [:]
        self.signKey = signKey
    }
    
    ///转化为根据key值排序由value生成的字符串
    var tokenString: String {
        parameter["signedKey"] = signKey
        parameter["token"] = nil
        return parameter.toKeyOrderedValueString().md5
    }
}



extension Dictionary where Key == String, Value == Any {
    func toKeyOrderedValueString(separator: String = "") -> String {
        var stringDictionary: [String: Any] = [:]
        for (key, value) in self {
            stringDictionary[key] = value
        }
        let sortedKeys = stringDictionary.keys.sorted()
        let values = sortedKeys.map { key -> String in
            if let value = stringDictionary[key] {
                return "\(value)"
            }
            return ""
        }
        return values.joined(separator: separator)
    }
}

extension String {
    var md5: String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        if let data = data(using: .utf8) {
            data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> Void in
                CC_MD5(bytes, CC_LONG(data.count), &digest)
            }
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }
}

// MARK: - Helpers
extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}

