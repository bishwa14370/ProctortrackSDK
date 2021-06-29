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

open class FrameworkManager: NSObject, SDKClientDelegate {
    
    private var isFrameworkInitialized: Bool = false
    private var isIdentityVerified: Bool = false
    private var isMonitoringSetUp: Bool = false
    public weak var delegate: FrameworkManagerDelegate?
    
    public func initFramework(url: String, client_id: String, account_id: String, first_name: String, last_name: String, email: String, completion: @escaping (Bool, String?) -> Void) {
        FrameworkServices.validateLicense(url: url, clientId: client_id, accountId: account_id, firstName: first_name, lastName: last_name, email: email) { (success, message) in
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
    
    private func createTestSession(config: Configuration, completion: @escaping (Bool, String?) -> Void) {
        FrameworkServices.createTestSession(config: config) { (result, message) in
            completion(result, message)
        }
    }
    
    public func startIdentityVerification(caller: UIViewController, completion: @escaping (String?) -> Void) {
        if isFrameworkInitialized {
            Utility.performSegueToIdentityVerification(caller: caller)
            self.isIdentityVerified = true
            completion("Id verification started.")
        }
        else {
            completion("Id verification failed, please initialize SDK first.")
        }
    }
    
    public func setupRecording(completion: @escaping (String?) -> Void) {
        if(isFrameworkInitialized && isIdentityVerified) {
            LiveMonitoring.shared.monitoringDelegate = self
            LiveMonitoring.shared.setupLiveCameraPreview()
            self.isMonitoringSetUp = true
            completion(nil)
        }
        else {
            completion("Monitoring setup failed, please initialize framework and perform identity verification.")
        }
    }
    
    public func startRecording() {
        LiveMonitoring.shared.startMovieRecording()
    }
    
    func sdkMonitoringError(message: String) {
        if let delegate = self.delegate {
            delegate.monitoringError(message: message)
        }
    }
    
    func clientDidConnect(message: String) {
        if let delegate = self.delegate {
            delegate.clientDidConnect(message: message)
        }
    }
    
    func clientDidDisconnect(message: String) {
        if let delegate = self.delegate {
            delegate.clientDidDisconnect(message: message)
        }
    }
    
    func clientHasError(message: String) {
        if let delegate = self.delegate {
            delegate.clientHasError(message: message)
        }
    }
    
    func publishStarted(message: String) {
        if let delegate = self.delegate {
            delegate.publishStarted(message: message)
        }
    }
}


public protocol FrameworkManagerDelegate: NSObjectProtocol {
    func monitoringError(message: String)
    func clientDidConnect(message: String)
    func clientDidDisconnect(message: String)
    func clientHasError(message: String)
    func publishStarted(message: String)
}


protocol SDKClientDelegate: NSObjectProtocol {
    func sdkMonitoringError(message: String)
    func clientDidConnect(message: String)
    func clientDidDisconnect(message: String)
    func clientHasError(message: String)
    func publishStarted(message: String)
}
