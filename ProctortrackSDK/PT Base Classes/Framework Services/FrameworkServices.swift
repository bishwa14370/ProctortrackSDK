//
//  FrameworkServices.swift
//  CustomFramework

import UIKit

class FrameworkServices: NSObject {
    
    private override init() {
    }
    
    static func validateLicense(url: String, clientSecretKey: String, bundleId: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: url) else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        //urlRequest.httpBody = body
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let _ = error {
                completion(false, "Initialization failed, please try again.")
            }
            else if let _ = data, error == nil {
                completion(true, nil)
            }
        }
        task.resume()
    }
    
    static func createTestSession(config: Configuration, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: config.urlString) else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        //urlRequest.httpBody = body
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let _ = error {
                completion(false, "Initialization failed, please try again.")
            }
            else if let data = data, error == nil {
                // Parse data
                // Save Session object in local
                   // auth_token
                   // session_id
                   // session_url
                completion(true, "Initialization success.")
            }
        }
        task.resume()
    }
    
    static private var body: Data? {
        get {
            var profile : [String:Any] = [:]
            profile["first_name"] = "bishwajit"
            profile["last_name"] = "Kalita"
            
            let requestData = ["user": profile]
            let jsonData = try? JSONSerialization.data(withJSONObject: requestData)
            return jsonData
        }
    }
}
