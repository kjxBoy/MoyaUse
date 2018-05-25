//
//  ViewController.swift
//  MoyaUseShow
//
//  Created by 康佳兴 on 2018/5/25.
//  Copyright © 2018年 Kang. All rights reserved.
//

import UIKit
import Moya
import Result


enum UserApi: DecodableTargetType {
    
    typealias ResultType = Student
    
    case carInfo(carId:Int, cityId:Int)
    
    
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
        switch self {
        case let .carInfo(carId, cityId):
            let _parameters = ["carId": carId, "cityId": cityId]
            let token = Token(signKey: "x*&c%a&r^*2$0*1&^6*&k$e*%y*", parameter: _parameters).token
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



class ViewController: UIViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let provider = MultiMoyaProvider()
        provider.requestDecoded(UserApi.carInfo(carId: 1, cityId: 1)) { result in
            switch result {
            case .success(let user):
                print(user.carYear)
                // type of `user` is implicitly `UserModel`. Using any other type results
                // in compile error
                
            case .failure(let error):
                print(error)
            }
        }
    }
}

struct Student: TestResultType {
    static func parse(_ object: Any) -> Student? {
        var stu = Student()
        stu.carYear = "kang.jiaxing"
        return stu
    }
    typealias T = String
    
    var carYear: String = ""
}



protocol TestResultType {
    associatedtype T
    static func parse(_ object: Any) -> Self?
}

protocol DecodableTargetType: Moya.TargetType {
    associatedtype ResultType: TestResultType
}

final class MultiMoyaProvider: MoyaProvider<MultiTarget> {
    
    typealias Target = MultiTarget
    
    override init(endpointClosure: @escaping EndpointClosure = MoyaProvider.defaultEndpointMapping,
                  requestClosure: @escaping RequestClosure = MoyaProvider<MultiTarget>.defaultRequestMapping,
                  stubClosure: @escaping StubClosure = MoyaProvider.neverStub,
                  callbackQueue: DispatchQueue? = nil,
                  manager: Manager = MoyaProvider<Target>.defaultAlamofireManager(),
                  plugins: [PluginType] = [],
                  trackInflights: Bool = false) {
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, callbackQueue: callbackQueue, manager: manager, plugins: plugins, trackInflights: trackInflights)
    }
    
    @discardableResult
    func requestDecoded<T: DecodableTargetType>(_ target: T, completion: @escaping (_ result: Result<T.ResultType, MoyaError>) -> ()) -> Cancellable {
        return request(MultiTarget(target)) { result in
            switch result {
            case .success(let response):
                if let parsed = T.ResultType.parse(try! response.mapJSON()) {
                    completion(.success(parsed))
                } else {
                    completion(.failure(.jsonMapping(response)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

