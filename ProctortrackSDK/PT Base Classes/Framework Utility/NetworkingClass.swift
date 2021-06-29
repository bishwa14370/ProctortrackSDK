//
//  NetworkingClass.swift
//  ProctortrackSDK
//

import UIKit

class NetworkingClass: NSObject {
    
    class func configurationApiCall(uploadUrl:String, reuestForURLCompletionHandler : @escaping (Bool, Dictionary<String,Any>) -> Void) {
        var parameters = [String : AnyObject]()
        parameters[testsession_id] = UserDefaults.standard.string(forKey: testsession_id) as AnyObject
        parameters["fullTestConfig"] = fullTestConfig as AnyObject
        let parameterString = parameters.stringFromHttpParameters()
        let requestURL = URL(string:"\(uploadUrl)?\(parameterString)")!
        
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = getRequest
        urlRequest.setValue(UserDefaults.standard.string(forKey: access_token)!, forHTTPHeaderField: authorization)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let err = error {
                if(kibanaLogEnable == true) {
                    let finalMessage = kibanaPrefix + "event: configurationApiCall"
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage + "|" + "\(err.localizedDescription)", level: kibanaLevelName)
                }
                reuestForURLCompletionHandler(false, [:])
            }
            else if let data = data, error == nil {
                if(kibanaLogEnable == true) {
                    do {
                        if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            let finalMessage = kibanaPrefix + "event: configurationApiCall"
                            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage + "|" + "\(dict)", level: kibanaLevelName)
                            reuestForURLCompletionHandler(true, dict)
                        }
                    }
                    catch {
                        let finalMessage = kibanaPrefix + "event: configurationApiCall"
                        NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage + "|" + "\(error.localizedDescription)", level: kibanaLevelName)
                        reuestForURLCompletionHandler(false, [:])
                    }
                }
            }
            else {
                let finalMessage = kibanaPrefix + "event: configurationApiCall"
                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage + "|" + "Failed", level: kibanaLevelName)
                reuestForURLCompletionHandler(false, [:])
            }
        }
        task.resume()
    }
    
    class func roomScanReviewStatusApiCallWithPatch(patchUrl:String, reuestForURLCompletionHandler : @escaping (Bool, Dictionary<String,Any>) -> Void) {
        var parameters = [String : AnyObject]()
        parameters[patchKeyForRoomScanProcessing] = 1 as AnyObject
        
        guard let url = URL(string: patchUrl) else {return}
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        urlRequest.setValue(UserDefaults.standard.string(forKey: access_token)!, forHTTPHeaderField: authorization)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let err = error {
                if(kibanaLogEnable == true) {
                    let finalMessage = kibanaPrefix + "event: roomScanReviewStatusApiCallWithPatch"
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage + "|" + "\(err.localizedDescription)", level: kibanaLevelName)
                }
                reuestForURLCompletionHandler(false, ["error":"\(err.localizedDescription)"])
            }
            else if let data = data, error == nil {
                if(kibanaLogEnable == true) {
                    do {
                        if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            let finalMessage = kibanaPrefix + "event: roomScanReviewStatusApiCallWithPatch"
                            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage + "|" + "\(dict)", level: kibanaLevelName)
                            reuestForURLCompletionHandler(true, dict)
                        }
                    }
                    catch {
                        let finalMessage = kibanaPrefix + "event: roomScanReviewStatusApiCallWithPatch"
                        NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage + "|" + "\(error.localizedDescription)", level: kibanaLevelName)
                        reuestForURLCompletionHandler(false, ["error":"\(error.localizedDescription)"])
                    }
                }
            }
            else {
                let finalMessage = kibanaPrefix + "event: roomScanReviewStatusApiCallWithPatch"
                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage + "|" + "response result value is nil", level: kibanaLevelName)
                reuestForURLCompletionHandler(false, ["error":"response result value is nil)"])
            }
        }
        task.resume()
    }
    
    class func roomScanReviewStatusApiCall(getUrl:String, reuestForURLCompletionHandler : @escaping (Bool, Dictionary<String,Any>) -> Void) {
        guard let url = URL(string: getUrl) else {return}
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = getRequest
        urlRequest.setValue(UserDefaults.standard.string(forKey: access_token)!, forHTTPHeaderField: authorization)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let err = error {
                if(kibanaLogEnable == true) {
                    let finalMessage = kibanaPrefix + "event: roomScanReviewStatusApiCall"
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage + "|" + "\(err.localizedDescription)", level: kibanaLevelName)
                }
                reuestForURLCompletionHandler(false, ["error":"\(err.localizedDescription)"])
            }
            else if let data = data, error == nil {
                if(kibanaLogEnable == true) {
                    do {
                        if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            let finalMessage = kibanaPrefix + "event: roomScanReviewStatusApiCall"
                            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage + "|" + "\(dict)", level: kibanaLevelName)
                            reuestForURLCompletionHandler(true, dict)
                        }
                    }
                    catch {
                        let finalMessage = kibanaPrefix + "event: roomScanReviewStatusApiCall"
                        NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage + "|" + "\(error.localizedDescription)", level: kibanaLevelName)
                        reuestForURLCompletionHandler(false, ["error":"\(error.localizedDescription)"])
                    }
                }
            }
            else {
                let finalMessage = kibanaPrefix + "event: roomScanReviewStatusApiCall"
                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage + "|" + "response result value is nil", level: kibanaLevelName)
                reuestForURLCompletionHandler(false, ["error":"response result value is nil)"])
            }
        }
        task.resume()
    }
    
    class func getRoomScanStreamTokenId(streamName: String, completionHandler : @escaping (Bool) -> Void) {
        let url = baseUrlForFreshHire + "/testsessions/stream/name/?stream_name=\(streamName)"
        guard let finalUrl = URL(string: url) else {return}
        var request : URLRequest = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [authorization : UserDefaults.standard.string(forKey: access_token)!]
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let err = error {
                if(kibanaLogEnable == true)
                {
                    let finalMessage = "getRoomScanStreamTokenId:" + err.localizedDescription
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                }
                completionHandler(false)
            }
            else if let result = data {
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: result, options: []) as? [String:Any] {
                        if let token = jsonResult["stream_token"] as? String {
                            roomScanTokenID = token
                            if(kibanaLogEnable == true)
                            {
                                let finalMessage = "getRoomScanStreamTokenId success: \(jsonResult)"
                                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                            }
                            completionHandler(true)
                        }
                    }
                    else {
                        if(kibanaLogEnable == true)
                        {
                            let finalMessage = "getRoomScanStreamTokenId failed: JSONSerialization"
                            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                        }
                        completionHandler(false)
                    }
                }
                catch {
                    if(kibanaLogEnable == true)
                    {
                        let finalMessage = "getRoomScanStreamTokenId failed: \(error.localizedDescription)"
                        NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                    }
                    completionHandler(false)
                }
            }
            else {
                if(kibanaLogEnable == true)
                {
                    let finalMessage = "getRoomScanStreamTokenId failed: response data is nil"
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                }
                completionHandler(false)
            }
        }
        dataTask.resume()
    }
    
    class func getMonitoringStreamTokenId(streamName: String, completionHandler : @escaping (Bool) -> Void) {
        let url = baseUrlForFreshHire + "/testsessions/stream/name/?stream_name=\(streamName)"
        guard let finalUrl = URL(string: url) else {return}
        var request : URLRequest = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [authorization : UserDefaults.standard.string(forKey: access_token)!]
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let err = error {
                if(kibanaLogEnable == true)
                {
                    let finalMessage = "getMonitoringStreamTokenId:" + err.localizedDescription
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                }
                completionHandler(false)
            }
            else if let result = data {
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: result, options: []) as? [String:Any] {
                        if let token = jsonResult["stream_token"] as? String {
                            liveStreamingTokenID = token
                            if(kibanaLogEnable == true)
                            {
                                let finalMessage = "getMonitoringStreamTokenId success: \(jsonResult)"
                                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                            }
                            completionHandler(true)
                        }
                    }
                    else {
                        if(kibanaLogEnable == true)
                        {
                            let finalMessage = "getMonitoringStreamTokenId failed: JSONSerialization"
                            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                        }
                        completionHandler(false)
                    }
                }
                catch {
                    if(kibanaLogEnable == true)
                    {
                        let finalMessage = "getMonitoringStreamTokenId failed: \(error.localizedDescription)"
                        NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                    }
                    completionHandler(false)
                }
            }
            else {
                if(kibanaLogEnable == true)
                {
                    let finalMessage = "getMonitoringStreamTokenId failed: response data is nil"
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                }
                completionHandler(false)
            }
        }
        dataTask.resume()
    }
    
    class func getFirebaseToken(completionHandler : @escaping (Bool, String?) -> Void) {
        let url = baseUrlForFreshHire + "/614e76646a47455568375419/api/v-2/users/me/"
        guard let finalUrl = URL(string: url) else {return}
        var request : URLRequest = URLRequest(url: finalUrl)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [authorization : UserDefaults.standard.string(forKey: access_token)!]
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let err = error {
                if(kibanaLogEnable == true)
                {
                    let finalMessage = "getFirebaseToken:" + err.localizedDescription
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                }
                completionHandler(false, nil)
            }
            else if let result = data {
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: result, options: []) as? [String:Any] {
                        if let auth_token = jsonResult["firebase_token"] as? String {
                            if(kibanaLogEnable == true)
                            {
                                let finalMessage = "getFirebaseToken success: \(jsonResult)"
                                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                            }
                            completionHandler(true, auth_token)
                        }
                    }
                    else {
                        if(kibanaLogEnable == true)
                        {
                            let finalMessage = "getFirebaseToken failed: JSONSerialization"
                            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                        }
                        completionHandler(false, nil)
                    }
                }
                catch {
                    if(kibanaLogEnable == true)
                    {
                        let finalMessage = "getFirebaseToken failed: \(error.localizedDescription)"
                        NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                    }
                    completionHandler(false, nil)
                }
            }
            else {
                if(kibanaLogEnable == true)
                {
                    let finalMessage = "getFirebaseToken failed: response data is nil"
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                }
                completionHandler(false, nil)
            }
        }
        dataTask.resume()
    }
    
    class func requestChunksUploadUrlAndSendChunksToUrl(uploadUrl:String,parameters:Dictionary<String, Any> ,videoData:NSData, fileName:String, filePath:URL, reuestForURLCompletionHandler : @escaping (Bool) -> Void) {
        let parameterString = parameters.stringFromHttpParameters()
        let requestURL = URL(string:"\(uploadUrl)?\(parameterString)")!
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = getRequest
        urlRequest.timeoutInterval = 100
        urlRequest.setValue(UserDefaults.standard.string(forKey: access_token)!, forHTTPHeaderField: authorization)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let err = error {
                if(kibanaLogEnable == true) {
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: "Request For chunk upload S3 url is failed/    Response contains error: \(err.localizedDescription)", level: kibanaLevelName)
                }
                reuestForURLCompletionHandler(false)
            }
            else if let result = data {
                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: result, options: []) as? [String:Any] {
                        if let s3Url = jsonResult[urlKeyResponse] as? String {
                            if(kibanaLogEnable == true) {
                                NetworkingClass.submitKibanaLogApiCallFromNative(message: "S3 URL success response is: \(jsonResult)", level: kibanaLevelName)
                            }
                            guard let requestURL = URL(string: s3Url) else {return}
                            var urlRequest = URLRequest(url: requestURL)
                            urlRequest.httpMethod = putRequest
                            urlRequest.timeoutInterval = 100
                            
                            let body = NSMutableData()
                            do {
                                let videoData:Data = try Data(contentsOf: filePath)
                                body.append(videoData)
                            }
                            catch {
                                print(error.localizedDescription)
                            }
                            urlRequest.httpBody = body as Data
                            
                            let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                                if let err = error {
                                    if(kibanaLogEnable == true) {
                                        NetworkingClass.submitKibanaLogApiCallFromNative(message: "Chunk \(fileName) upload request failed/ Response contains error: \(err.localizedDescription)", level: kibanaLevelName)
                                    }
                                    reuestForURLCompletionHandler(false)
                                }
                                else if error == nil, let res = response as? HTTPURLResponse, res.statusCode == 200 {
                                    if FileManager.default.fileExists(atPath:(getDirectoryPath() as NSString).appendingPathComponent(fileName)) {
                                        removeFileFromDirectory(itemName:(getDirectoryPath() as NSString).appendingPathComponent(fileName))
                                        
                                        if(kibanaLogEnable == true) {
                                            NetworkingClass.submitKibanaLogApiCallFromNative(message: "Chunk \(fileName) upload request success and chunk \(fileName) deleted from directory", level: kibanaLevelName)
                                        }
                                        reuestForURLCompletionHandler(true)
                                    }
                                }
                                else {
                                    if(kibanaLogEnable == true) {
                                        NetworkingClass.submitKibanaLogApiCallFromNative(message: "Chunk \(fileName) upload request failed/ Status code is not 200", level: kibanaLevelName)
                                    }
                                    reuestForURLCompletionHandler(false)
                                }
                            }
                            task.resume()
                        }
                    }
                    else {
                        if(kibanaLogEnable == true) {
                            NetworkingClass.submitKibanaLogApiCallFromNative(message: "Request For chunk upload S3 url is failed/ Response is not in correct format", level: kibanaLevelName)
                        }
                        reuestForURLCompletionHandler(false)
                    }
                }
                catch {
                    if(kibanaLogEnable == true) {
                        let finalMessage = "Request For chunk upload S3 url is failed: \(error.localizedDescription)"
                        NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                    }
                    reuestForURLCompletionHandler(false)
                }
            }
            else {
                if(kibanaLogEnable == true) {
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: "Request For chunk upload S3 url is failed", level: kibanaLevelName)
                }
                reuestForURLCompletionHandler(false)
            }
        }
        task.resume()
    }
    
    class func submitKibanaLogApiCallFromNative(message: String, level:String) {
        let url:URL = URL(string: "https://logapi.verificient.com:7002/")!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        var parameters = [String : AnyObject]()
        parameters["App"] = "Proctortrack" as AnyObject
        parameters["Environment"] = "https://testing.verificient.com/" as AnyObject
        parameters["LevelName"] = level as AnyObject
        parameters["Message"] = message as AnyObject
        parameters["version"] = String(Bundle.main.releaseVersionNumber!) as AnyObject
        parameters["timestamp"] =  Date().description as AnyObject
        if ((UserDefaults.standard.string(forKey: testsession_id)) != nil)
        {
            parameters["SessionID"] = UserDefaults.standard.string(forKey: testsession_id) as AnyObject
        }
        else
        {
            //  let formatter = DateFormatter()
            //   formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //   let defaultSessionId = formatter.string(from: Date())
            parameters["SessionID"] = 123456 as AnyObject
        }
        
        request.addValue("Basic bUFuZURnZVJHZXJHZU50SW86ZzcyQThzUy1DV3VZOF9wYyViK1M=", forHTTPHeaderField: authorization)
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        let task = session.dataTask(with: request as URLRequest) {
            (data, response, error) in
            
            guard let data = data, let _:URLResponse = response, error == nil else {
                print("error:- ",error as Any)
                return
            }
            
            let dataString =  String(data: data, encoding: String.Encoding.utf8)
            print("Print Kibana Api Output",dataString!)
            
        }
        
        task.resume()
    }
}

extension Dictionary {
    
    func stringFromHttpParameters() -> String {
        
        var parametersString = ""
        for (key, value) in self {
            if let key = key as? String,
               let value = value as? String {
                parametersString = parametersString + key + "=" + value + "&"
            }
            else if let key = key as? String,
                    let value = value as? Int
            {
                parametersString = parametersString + key + "=" + String(value) + "&"
            }
            else if let key = key as? String,
                    let value = value as? Bool
            {
                parametersString = parametersString + key + "=" + String(value) + "&"
            }
        }
        parametersString =  String(parametersString[..<parametersString.index(before: parametersString.endIndex)])
        //        parametersString = parametersString.substring(to: parametersString.index(before: parametersString.endIndex))
        return parametersString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}
