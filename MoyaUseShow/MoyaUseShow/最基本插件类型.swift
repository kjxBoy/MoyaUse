//
//  最基本插件类型.swift
//  MoyaUseShow
//
//  Created by 康佳兴 on 2018/5/28.
//  Copyright © 2018年 Kang. All rights reserved.
//

import Foundation
import Moya
import Result
/*
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let provider = MoyaProvider<MyService>( plugins: [RequestAlertPlugin(viewController: self)])
    
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

final class RequestAlertPlugin: PluginType {
    
    private let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        if case let .requestParameters(parameters, _) = target.task {
            let token = Token(signKey: "x*&c%a&r^*2$0*1&^6*&k$e*%y*", parameter: parameters)
            var request = request
            request.addValue(token.tokenString, forHTTPHeaderField: "token")
            return request
        }
        return request
    }
    
    func willSend(_ request: RequestType, target: TargetType) {
        //make sure we have a URL string to display
        guard let requestURLString = request.request?.url?.absoluteString else { return }
        
        //create alert view controller with a single action
        let alertViewController = UIAlertController(title: "Sending Request", message: requestURLString, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        //and present using the view controller we created at initialization
        viewController.present(alertViewController, animated: true)
    }
    
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        //only continue if result is a failure
        guard case Result.failure(let error) = result else { return }
        //create alert view controller with a single action and messing displaying status code
        let alertViewController = UIAlertController(title: "Error", message: "Request failed with status code: \(error.response?.statusCode ?? 0)", preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        //and present using the view controller we created at initialization
        viewController.present(alertViewController, animated: true)
    }
}
