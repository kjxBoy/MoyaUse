//
//  MultiMoyaProvider解析.swift
//  MoyaUseShow
//
//  Created by 康佳兴 on 2018/5/28.
//  Copyright © 2018年 Kang. All rights reserved.
//

import Foundation
import Moya
import Result

/*
 * 可以用于不同URL请求，但是返回相同模型的情况
 * 可以用于想要将模型封装到model层的情况
 * 单元测试
 
 参考
 * 文档： https://github.com/Moya/Moya/blob/master/docs/Examples/MultiTarget.md
 * mutiMoyaProvider https://github.com/Moya/Moya/issues/1150
 */
/*
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let provider = MultiMoyaProvider()
    provider.requestDecoded(UserApi.carInfo(carId: 1, cityId: 1)) { result in
        switch result {
        case .success(let user):
            /// 这里直接输出模型数据
            print(user)
            
        case .failure(let error):
            print(error)
        }
    }
    
    let provider = MultiMoyaProvider()
    provider.requestDecoded(SessionApi(carId: 1, cityId: 1)) { (result) in
        switch result {
        case .success(let user):
            /// 这里直接输出模型数据
            print(user)
            
        case .failure(let error):
            print(error)
        }
    }

}
*/

// 解析过程(可以根据解析的需求自己扩展解析)
protocol TestResultType {
    static func parse(_ object: Any) -> Self?
}

// 默认解析的模型类型
protocol DecodableTargetType: Moya.TargetType {
    associatedtype ResultType: TestResultType
}


// MARK: - 基础扩展
extension DecodableTargetType {
    // 用于单元测试
    var sampleData: Data {
        return "Half measures are as bad as nothing at all.".utf8Encoded
    }
    
    var baseURL: URL {
        return URL(string: "https://m-api.xcar.com.cn")!
    }
}

struct SessionApi: DecodableTargetType {
    
    var carId: Int = 0
    var cityId: Int = 0
   
    var path: String {
        return "/newcar/Car/carinfo"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
         return .requestParameters(parameters: ["carId": carId, "cityId": cityId], encoding: URLEncoding.queryString)
    }
    
    var headers: [String : String]? {
        let _parameters = ["carId": carId, "cityId": cityId]
        let token = Token(signKey: "x*&c%a&r^*2$0*1&^6*&k$e*%y*", parameter: _parameters).tokenString
        return ["token": token]
    }
    
    typealias ResultType = Dog
}

enum UserApi<ResultType: TestResultType>: DecodableTargetType {
    
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
            let token = Token(signKey: "x*&c%a&r^*2$0*1&^6*&k$e*%y*", parameter: _parameters).tokenString
            return ["token": token]
        }
    }
}

final class MultiMoyaProvider: MoyaProvider<MultiTarget> {
    
    typealias Target = MultiTarget
    
    /* 如果需要进行部分创建修改可以在这里添加
    override init(endpointClosure: @escaping EndpointClosure = MoyaProvider.defaultEndpointMapping,
                  requestClosure: @escaping RequestClosure = MoyaProvider<MultiTarget>.defaultRequestMapping,
                  stubClosure: @escaping StubClosure = MoyaProvider.neverStub,
                  callbackQueue: DispatchQueue? = nil,
                  manager: Manager = MoyaProvider<Target>.defaultAlamofireManager(),
                  plugins: [PluginType] = [],
                  trackInflights: Bool = false) {
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, callbackQueue: callbackQueue, manager: manager, plugins: plugins, trackInflights: trackInflights)
    }
    */
    
    @discardableResult
    func requestDecoded<T: DecodableTargetType>(_ target: T, completion: @escaping (_ result: Result<T.ResultType, MoyaError>) -> ()) -> Cancellable {
        return request(MultiTarget(target)) { result in
            switch result {
            case .success(let response):
                if let parsed = T.ResultType.parse(try! response.mapJSON()) {
                    // Result.success(parsed)
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


struct Student: TestResultType {
    typealias T = Student
    
    ///  模型自己讲从Any -> 实例的方式告诉出去
    static func parse(_ object: Any) -> T? {
        
        var stu = T()
        stu.name = "kang.jiaxing"
        stu.age = "may be 18 years old"
        stu.Features = " handsome "
        return stu
    }
    
    var name: String = ""
    var age: String = ""
    var Features: String = ""
    
}

struct Dog: TestResultType {
    static func parse(_ object: Any) -> Dog? {
        var dog = Dog()
        dog.name = "xiao hei"
        dog.age = "10"
        return dog
    }
    
    
    var name: String = ""
    var age: String = ""
}



