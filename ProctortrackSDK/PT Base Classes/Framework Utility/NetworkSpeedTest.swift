//
//  NetworkSpeedTest.swift
//  Proctorscreen
//
//  Created by Diwakar Garg on 08/07/17.
//  Copyright © 2017 Diwakar Garg. All rights reserved.
//

import UIKit

class NetworkSpeedTest: NSObject {
    
    func checkDownloadSpeed(completionHandler : @escaping (Bool) -> Void) {
        let urlString = "https://verificientstatic.s3-us-west-2.amazonaws.com/Apps/temp.png"
        guard let url = URL(string: urlString) else {return}
        let request = URLRequest(url: url)
        let startTime = Date()
        let dataTask = URLSession.shared.dataTask(with: request) { (data, resp, error) in
            if let err = error {
                if(kibanaLogEnable == true)
                {
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: "checkDownloadSpeed error: \(err.localizedDescription)", level: kibanaLevelName)
                }
                completionHandler(false)
            }
            else if let response = resp {
                let length = CGFloat((response.expectedContentLength))
                let elapsed = CGFloat(Date().timeIntervalSince(startTime))
                UserDefaults.standard.set(abs(length/elapsed), forKey:downloadSpeedValue)
                if(kibanaLogEnable == true)
                {
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: "checkDownloadSpeed success: \(abs(length/elapsed))", level: kibanaLevelName)
                }
                completionHandler(true)
            }
            else {
                if(kibanaLogEnable == true)
                {
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: "checkDownloadSpeed error: response is nil", level: kibanaLevelName)
                }
                completionHandler(false)
            }
        }
        dataTask.resume()
    }
    
    func checkUploadSpeed(completionHandler : @escaping (Bool) -> Void) {
        guard let requestUrl = URL(string: "https://verificientstatic.s3-us-west-2.amazonaws.com/Apps/") else {return}
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var retreivedImage: UIImage? = nil
        
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "upload", ofType: imageExtension)
        //Convert file path to url
        let url: URL = URL(fileURLWithPath: path!)
        //Get image
        do {
            let readData = try Data(contentsOf: url)
            retreivedImage = UIImage(data: readData)
        }
        catch {
            print("Error while opening image")
            return
        }
        let imageData = retreivedImage!.jpegData(compressionQuality: 1)
        if (imageData == nil) {
            print("UIImageJPEGRepresentation return nil")
            return
        }
        let body = NSMutableData()
        body.append(NSString(format: "\r\n--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format: "\r\n--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format:"Content-Disposition: form-data; name=\"upload\"; filename=\"upload.jpg\"\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").data(using: String.Encoding.utf8.rawValue)!)
        body.append(imageData!)
        body.append(NSString(format: "\r\n--%@\r\n", boundary).data(using: String.Encoding.utf8.rawValue)!)
        request.httpBody = body as Data
        //Start Time to Upload the data
        let startTime = Date()
        
        let testImage = NSData (contentsOf: url as URL)
        let imageSize: CGFloat = returnFloatValue(data: testImage!)
        
        let task =  URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            if let data = data {
                let length = CGFloat(imageSize / 1000000.0)
                let elapsed = CGFloat(Date().timeIntervalSince(startTime))
                UserDefaults.standard.set(abs(length/elapsed), forKey: uploadSpeedValue)
                
                if(kibanaLogEnable == true)
                {
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: "checkUploadSpeed success: data \(data)", level: kibanaLevelName)
                }
                completionHandler(true)
            }
            else if let error = error {
                if(kibanaLogEnable == true)
                {
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: "checkUploadSpeed error: \(error.localizedDescription)", level: kibanaLevelName)
                }
                completionHandler (false)
            }
            else {
                if(kibanaLogEnable == true)
                {
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: "checkUploadSpeed error: response is nil", level: kibanaLevelName)
                }
                completionHandler (false)
            }
        })
        task.resume()
    }
    
    func returnFloatValue(data: NSData) -> CGFloat {
        let bytes = [UInt8](data as Data)
        var f: CGFloat = 0
        
        memcpy(&f, bytes, 4)
        return f
    }
}
