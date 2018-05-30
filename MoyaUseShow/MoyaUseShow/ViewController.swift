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

class ViewController: UIViewController {
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

        /*
        let provider = MultiMoyaProvider()
        provider.requestDecoded(UserApi<Dog>.carInfo(carId: 1, cityId: 1)) { result in
            switch result {
            case .success(let user):
                /// 这里直接输出模型数据
                print(user)
                
            case .failure(let error):
                print(error)
            }
        }
        */
    }
}


