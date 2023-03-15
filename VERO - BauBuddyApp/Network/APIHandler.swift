//
//  APIHandler.swift
//  VERO - BauBuddyApp
//
//  Created by Fatih on 15.03.2023.
//

import Foundation
import Foundation
protocol TaskListServiceProtocol {
    func fetchTasks(with userOauth: Oauth, completion: @escaping ([Task]) -> Void)
    func getFromAPI(completion: @escaping (Result<Oauth,NSError>) -> Void)
}


class APIHandler:TaskListServiceProtocol {
    static let shared = APIHandler()
    
    func getFromAPI(completion: @escaping (Result<Oauth,NSError>) -> Void) {
        let headers = [
            "Authorization": "Basic QVBJX0V4cGxvcmVyOjEyMzQ1NmlzQUxhbWVQYXNz",
            "Content-Type": "application/json"
        ]
        let parameters = [
            "username": "365",
            "password": "1"
        ] as [String : Any]
        
        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.baubuddy.de/index.php/login")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 20.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse as Any)
                do{
                    let dictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:Any]
                    guard let oauth = dictionary["oauth"] as? Dictionary<String, Any> else {return}
                    let accessToken = oauth["access_token"] as! String
                    let refreshToken = oauth["refresh_token"] as! String
                    let userOauth = Oauth(access_token: accessToken , refresh_token: refreshToken)
                    completion(.success(userOauth))
                } catch {
                    completion(.failure(error as NSError))
                }
            }
            
        })
        
        dataTask.resume()
        
    }
    
    func fetchTasks(with userOauth: Oauth, completion: @escaping ([Task]) -> Void) {
        let userAccessTokenString : String = "\(userOauth.access_token ?? "")"
        let userRefreshTokenString : String = "\(userOauth.refresh_token ?? "")"
        let baubuddyURL = "https://api.baubuddy.de/dev/index.php/v1/tasks/select?access_token=\(userAccessTokenString)&expires_in=1200&token_type=Bearer&scope=&refresh_token=\(userRefreshTokenString)&"
        let request = URLRequest(url: URL(string: baubuddyURL)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return
            }
            do {
                let tasks = try JSONDecoder().decode([Task].self, from: data!)
                completion(tasks)
            } catch {
                print(error)
            }
        }
        task.resume()

    }
}
