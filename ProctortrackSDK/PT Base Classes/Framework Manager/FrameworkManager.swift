//
//  FrameworkManager.swift
//  CustomFramework

import UIKit

struct Configuration {
    var urlString: String
    var auth_key: String
    
    init(urlString:String, auth_key:String) {
        self.urlString = urlString
        self.auth_key = auth_key
    }
}

open class FrameworkManager: NSObject {
    
    static var isFrameworkInitialized: Bool = true
    static var isIdentityVerified: Bool = false
    
    private override init() {
    }
    
    public static func initFramework(url: String, clientSecretKey: String, bundleId: String, completion: @escaping (Bool, String?) -> Void) {
        FrameworkServices.validateLicense(url: url, clientSecretKey: clientSecretKey, bundleId: bundleId) { (success, message) in
            if success {
                let config = Configuration.init(urlString: url, auth_key: "auth_key")
                self.createTestSession(config: config) { (success, message) in
                    if success {
                        self.isFrameworkInitialized = true
                        completion(true, message)
                    }
                    else {
                        completion(false, message)
                    }
                }
            }
            else {
                completion(false, message)
            }
        }
    }
    
    private static func createTestSession(config: Configuration, completion: @escaping (Bool, String?) -> Void) {
        FrameworkServices.createTestSession(config: config) { (result, message) in
            completion(result, message)
        }
    }
    
    public static func startIdentityVerification(caller: UIViewController, completion: @escaping (String) -> Void) {
        if isFrameworkInitialized {
            Utility.performSegueToIdentityVerification(caller: caller)
            completion("Id verification success.")
        }
        else {
            completion("Id verification failed, please initialize SDK first.")
        }
    }
    
    public static func setupLiveMonitoring(with cameraView: UIView, completion: @escaping (String) -> Void) {
        if(isFrameworkInitialized && isIdentityVerified) {
         //   LiveMonitoring.shared.setupLiveCameraPreview(cameraView: cameraView)
            completion("Setup live monitoring success.")
        }
        else {
            completion("Setup live montoring failed, either framework initialization or identity verification has not been done.")
        }
    }
    
    public static func startRecording() {
      //  LiveMonitoring.shared.startMovieRecording()
    }
    
    public static func stopRecording() {
      //  LiveMonitoring.shared.stopMovieRecording()
    }
}

