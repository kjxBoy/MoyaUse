# 故事起源

让我们来写一些与网络服务交互的函数。比如，获取用戶列表的数据，并将它解析为 `User` 数据 类型。我们创建一个 `loadUsers` 函数，它可以从网上异步加载用户，并且在完成后通过一个回调来传递获取到的用户列表。 
当我们用最原始的方式来实现的话，首先我们要创建 `URL`，然后我们同步地加载数据 (这里只是为了简化我们的例子，所以使用了同步方式。在你的产品中，你应当始终用异步方式加载你的数据)。接下来，我们解析 `JSON`，得到一个含有字典的数组。最后，我们将这些 `JSON` 对象变形为 `User` 结构体: 

```
  func loadUsers(callback: ([User]?) -> ()) {
		  	// 1.拼接一个请求的URL
        let usersURL = webserviceURL.appendingPathComponent("/users")
  	     	// 2.根据拼接的URL，拿到数据
        let data = try? Data(contentsOf: usersURL)
        	// 3.解析
        let json = data.flatMap {
            try? JSONSerialization.jsonObject(with: $0, options: []) }
            let users = (json as? [Any]).flatMap { jsonObject in
                jsonObject.flatMap(User.init)
        }
        callback(users)
    }
```

现在，如果我们想要写一个相同的函数来加载其他资源，我们可能需要复制这里的大部分代码。
打个比方，我们需要一个加载博客文章的函数，它看起来是这样的:
```
func loadBlogPosts(callback: ([BlogPost])? -> ()) 
```
函数的实现和前面的用户函数几乎相同。不仅代码重复，两个方法同时也都很难测试，我们需
要确保网络服务可以在测试是被访问到，或者是找到一个模拟这些请求的方法。因为函数接受
并使用回调，我们还需要保证我们的测试是异步运行的。

## 解决
### 小目标：提取共通功能

相比于复制粘贴，将函数中`User`相关的部分提取出来，将其他部分进行重用，会是更好的方式。我们可以将 `URL`路径和解析转换的函数作为参数传入。因为我们希望可以传入不同的转换函数，所以我们将 `loadResource` 声明为 `A` 的泛型: 


```
func loadResource<A>(at path: String, parse: (Any) -> A?, callback: (A?) -> ())
    {
        let resourceURL = webserviceURL.appendingPathComponent(path)
        let data = try? Data(contentsOf: resourceURL)
        let json = data.flatMap {
            try? JSONSerialization.jsonObject(with: $0, options: [])
        }
        callback(json.flatMap(parse))
    }
```

现在，我们可以将`loadUsers`函数基于`loadResource`重写: 

```
  func loadUsers(callback: ([User]?) -> ()) {
        loadResource(at: "/users", parse: jsonArray(User.init), callback: callback)
   }

```

我们使用了一个辅助函数，`jsonArray`，它首先尝试将一个 `Any` 转换为一个 `Any 的数组`，接着对每个元素用提供的解析函数进行解析，如果期间任何一步发生了错误，则返回 `nil`: 
```
 func jsonArray<A>(_ transform: @escaping (Any) -> A?) -> (Any) -> [A]? {
        return { array in
            guard let array = array as? [Any] else { return nil }
            return array.flatMap(transform)
        }
 }
```

对于加载博客文章的函数，我们只需要替换请求路径和解析函数就行了:
```
 func loadBlogPosts(callback: ([BlogPost]?) -> ()) {
        loadResource(at: "/posts", parse: jsonArray(BlogPost.init), callback: callback)
  }
    
```

### 目标： 提供请求所需参数，模型  ---> 得到模型数据 （请求过程，模型解析过程控制器不需要知道） 
 
### 利用moya达到


### 用moya做网络封装(将token的设置放到插件中，可以在插件里面设置token、返回的类型、缓存等)

```
import Foundation
import Moya
import Result

struct RequestPlugin: PluginType {
    private var urlPath: String
    private var saveCache: Bool
    init(urlPath: String = "", saveCache: Bool = true) {
        self.urlPath = urlPath
        self.saveCache = saveCache
    }
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        if case let .requestParameters(parameters, _) = target.task {
            ///增加_t参数
            var _parameters = parameters
            _parameters["_t"] = Int(Date().timeIntervalSince1970)
            let token = Token(parameter: _parameters).token
            ///增加token
            var showRequest = request
            var siginedheaders: [String: String] = XCRDevice.sharedManager.deviceHeaders
            if let headers = showRequest.allHTTPHeaderFields {
                for (key, value) in headers {
                    siginedheaders[key] = value
                }
            }
            siginedheaders["token"] = token
            showRequest.allHTTPHeaderFields = siginedheaders
            return showRequest
        }
        return request
    }
   
    
    func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if saveCache {
            if case let .requestParameters(parameters, _) = target.task {
                let cacheKey = XCRCache.cacheKey(path: urlPath, parameters: parameters)
                switch result {
                case let .success(response):
                    do {
                        let showJson = try response.mapJSON()
                        guard let data = showJson as? [String: Any] else { return }
                        XCRCache.set(json: data, key: cacheKey)
                    } catch {
                        print(error)
                    }
                case .failure(_): break
                }
            }
        }
    }
    
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        return result
    }
}

enum XCRCarSeriesSubModule {
    case information(seriesId: Int, type: CarSeriesNewsType, offset: Int, limit: Int)
}

extension XCRCarSeriesSubModule: TargetType {
    var path: String {
        switch self {
        case .information:
            return kURLSeriesNews
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .information:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case let .information(seriesId, type, offset, limit):
            return .requestParameters(parameters: ["seriesId": seriesId, "type": type, "offset": offset, "limit": limit], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}

```



