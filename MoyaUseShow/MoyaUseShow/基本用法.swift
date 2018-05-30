//
//  基本用法.swift
//  MoyaUseShow
//
//  Created by 康佳兴 on 2018/5/25.
//  Copyright © 2018年 Kang. All rights reserved.
//

import Foundation
import Moya

/*
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    let provider = MoyaProvider<MyService>()
    
    provider.request(.carInfo(carId: 1, cityId: 1)) { (result) in
        switch result {
        case let .success(response):
            do {
                let showJson = try response.mapJSON()
                print(showJson, "7777")
            } catch {
                print(error)
            }
            
        case let .failure(error):
            print(error,"8888888")
        }
    }
}
*/

enum MyService {
    case carInfo(carId:Int, cityId:Int)
}

// MARK: - TargetType Protocol Implementation
extension MyService: TargetType {
    var baseURL: URL {
        switch self {
        case .carInfo:
            return URL(string: "https://m-api.xcar.com.cn")!
        }
    }
    
    var path: String {
        switch self {
        case .carInfo:
            return "/newcar/Car/carinfo"
        }
    }
    var method: Moya.Method {
        switch self {
        case .carInfo:
            return .get
        }
    }
    var task: Task {
        switch self {
        case let .carInfo(carId, cityId):
            return .requestParameters(parameters: ["carId": carId, "cityId": cityId], encoding: URLEncoding.queryString)
        }
    }
    var headers: [String: String]? {
        return nil // 在使用插件的情况下，可以直接传回nil类型 
        switch self {
        case let .carInfo(carId, cityId):
            let _parameters = ["carId": carId, "cityId": cityId]
            let token = Token(signKey: "x*&c%a&r^*2$0*1&^6*&k$e*%y*", parameter: _parameters).tokenString
            return ["token": token]
        }
    }
    // 用于单元测试
    var sampleData: Data {
        switch self {
        case .carInfo:
            return "Half measures are as bad as nothing at all.".utf8Encoded
        }
    }
}
