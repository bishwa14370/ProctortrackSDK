//
//  RoomScanApprovalProcessingVC.swift
//  ProctorTrack
//
//  Created by QAMAC3 on 07/11/19.
//  Copyright © 2019 Diwakar Garg. All rights reserved.
//

import UIKit

class RoomScanApprovalProcessingVC: UIViewController {
    
    @IBOutlet weak var statusMessageLabel: UILabel!
    @IBOutlet weak var reTakeButton: UIButton!
    @IBOutlet weak var loaderActivityIndicatorView: UIActivityIndicatorView!
    var roomScanStatusTimer = Timer()
    var roomScanStatusMessagerequest = 30
    var navigationBarTitle : UILabel?
    
    
    var ROOMSCAN_REVIEW_STATUS_UNDER_REVIEW = 1
    var ROOMSCAN_REVIEW_STATUS_REJECTED = 2
    var ROOMSCAN_REVIEW_STATUS_ACCEPTED = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarAddMethod()
        callPatchApiRequestForLiveRoomScan()
        
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:RoomScanApproval_Start"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        statusMessageLabel.text = roomScanUnderReviewProcessMessage
        loaderActivityIndicatorView.startAnimating()
        reTakeButton.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(appForegroundStateFunction), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBackgroundStateFunction), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loaderActivityIndicatorView.stopAnimating()
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:RoomScanApproval_end"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .flagsChanged, object: nil)
    }
    
    func changeStatusOfMessage(reviewStatus:Int)
    {
        if(reviewStatus == ROOMSCAN_REVIEW_STATUS_REJECTED)
        {
            statusMessageLabel.text = roomScanApprovalFailedMessage
            filedMessageViewShow()
        }
        else if(reviewStatus == ROOMSCAN_REVIEW_STATUS_ACCEPTED)
        {
            statusMessageLabel.text = roomScanApprovedMessage
            moveToLockScreen()
        }
        else
        {
            statusMessageLabel.text = roomScanUnderReviewProcessMessage
        }
    }
    
    //Navigate to next screen
    func moveToLockScreen()
    {
//        if is_stream_auto_renaming_enabled {
//            FirestoreDB.shared.removeQuoteListener()
//        }
        loaderActivityIndicatorView.stopAnimating()
        roomScanStatusTimer.invalidate()
        loaderActivityIndicatorView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.performSegue(withIdentifier: liveLockScreenSegue, sender: self)
        })
    }
    
    //code for show button and hide activity indicator
    func filedMessageViewShow()
    {
        reTakeButton.isHidden = false
        loaderActivityIndicatorView.stopAnimating()
        roomScanStatusTimer.invalidate()
        loaderActivityIndicatorView.isHidden = true
    }
    
    @objc func appForegroundStateFunction()
    {
        if(kibanaLogEnable == true)
        {
            NetworkingClass.submitKibanaLogApiCallFromNative(message: "RoomScanApprovalProcessingVC moves to foreground", level: kibanaLevelName)
        }
    }
    
    @objc func appBackgroundStateFunction()
    {
        if(kibanaLogEnable == true)
        {
            NetworkingClass.submitKibanaLogApiCallFromNative(message: "RoomScanApprovalProcessingVC moves to background", level: kibanaLevelName)
        }
    }
  /*
    private func listenToRoomScanStatus() {
        FirestoreDB.shared.listenToRoomScanApprovalStatus {(success, docSnapshot, message) in
            if success {
                if let result = docSnapshot {
                    if let status = result["room_scan_status"] as? Int {
                        self.changeStatusOfMessage(reviewStatus: status)
                        if(kibanaLogEnable == true)
                        {
                            let finalMessage = kibanaPrefix + "event: RoomScan_approval" + seprator + "type: success: \(message) and result: \(result)"
                            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                        }
                    }
                }
            }
            else {
                if(kibanaLogEnable == true)
                {
                    let finalMessage = kibanaPrefix + "event: RoomScan_approval" + seprator + "type: failed: \(message)"
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                }
            }
        }
    }
  */
    
    func callPatchApiRequestForLiveRoomScan()
    {
        var url: String?
        let testSeeionId =  UserDefaults.standard.string(forKey: testsession_id) as AnyObject
        let patchUrl: String = "/api/v1/testsession/\(testSeeionId)/started/"
        url = "\(baseUrlForFreshHire)\(patchUrl)"
        
        NetworkingClass.roomScanReviewStatusApiCallWithPatch(patchUrl:url!, reuestForURLCompletionHandler: {(success, response) in
            if success
            {
                let status = response[statusResponse] as? String
                if (status == failedResponse)
                {
                    if(kibanaLogEnable == true)
                    {
                        let finalMessage = kibanaPrefix + "event: RoomScan_approval" + seprator + "type: failed  callPatchApiRequestForLiveRoomScan, response: \(response)"
                        NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                    }
                    self.callPatchApiRequestForLiveRoomScan()
                }
                else
                {
                    if(kibanaLogEnable == true)
                    {
                        let finalMessage = kibanaPrefix + "event: RoomScan_approval" + seprator + "type: success  callPatchApiRequestForLiveRoomScan, response: \(response)"
                        NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                    }
                    
//                    is_stream_auto_renaming_enabled = UserDefaults.standard.bool(forKey: streamAutoRenamingKey)
//                    if is_stream_auto_renaming_enabled {
//                        self.listenToRoomScanStatus()
//                    }
//                    else {
//                        self.roomScanStatusTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.roomScanStatusTimerHandling), userInfo: nil, repeats: true)
//                    }
                    
                    self.roomScanStatusTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.roomScanStatusTimerHandling), userInfo: nil, repeats: true)
                }
            }
            else
            {
                if(kibanaLogEnable == true)
                {
                    let finalMessage = kibanaPrefix + "event: RoomScan_approval" + seprator + "type: failed  callPatchApiRequestForLiveRoomScan, response: \(response)"
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                }
                self.callPatchApiRequestForLiveRoomScan()
            }
        })
    }
    
    @objc func roomScanStatusTimerHandling() {
        roomScanStatusMessagerequest -= 1
        if(roomScanStatusMessagerequest == 0)
        {
            roomScanStatusMessagerequest = 30
            callGetStatusOfApprovalRejectionRoomScan()
        }
    }
    
    func callGetStatusOfApprovalRejectionRoomScan()
    {
        var url: String?
        let testSeeionId =  UserDefaults.standard.string(forKey: testsession_id) as AnyObject
        let getUrl: String = "/api/v1/testsession/\(testSeeionId)/started/"
        url = "\(baseUrlForFreshHire)\(getUrl)"
        
        
        NetworkingClass.roomScanReviewStatusApiCall(getUrl:url!, reuestForURLCompletionHandler: {(success, response) in
            if success
            {
                let status = response[statusResponse] as? String
                if (status == failedResponse)
                {
                    if(kibanaLogEnable == true)
                    {
                        let finalMessage = kibanaPrefix + "event: RoomScan_approval" + seprator + "type: failed:  callGetStatusOfApprovalRejectionRoomScan, response: \(response)"
                        NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                    }
                }
                else
                {
                    if let roomScanStatus = response["live_room_scan_acceptance_status"] as? Int {
                        self.changeStatusOfMessage(reviewStatus: roomScanStatus)
                        if(kibanaLogEnable == true)
                        {
                            let finalMessage = kibanaPrefix + "event: RoomScan_approval" + seprator + "type: success: callGetStatusOfApprovalRejectionRoomScan, response: \(response)"
                            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                        }
                    }
                }
            }
            else
            {
                if(kibanaLogEnable == true)
                {
                    let finalMessage = kibanaPrefix + "event: RoomScan_approval" + seprator + "type: failed:  callGetStatusOfApprovalRejectionRoomScan, response: \(response)"
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                }
            }
        })
    }
    
    
    //Navigation bar handling function
    fileprivate func navigationBarAddMethod()
    {
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 3.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        self.navigationController?.navigationBar.layer.masksToBounds = false
        
        let customView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width - 100, height: (self.navigationController?.navigationBar.frame.size.height)!))
        navigationBarTitle = UILabel(frame: CGRect(x: 0, y: 0.0, width: self.view.frame.width , height: customView.frame.height))
        navigationBarTitle?.text = roomScanProcessingAlertTitle
        navigationBarTitle?.textColor = UIColor.white
        navigationBarTitle?.textAlignment = NSTextAlignment.left
        navigationBarTitle?.center.y = customView.center.y
        navigationBarTitle?.font =  UIFont(name: "Roboto-Bold", size: 18)
        customView.addSubview(navigationBarTitle!)
        let leftButton = UIBarButtonItem(customView: customView)
        self.navigationItem.leftBarButtonItem = leftButton
        
        //Add Quit Button on navigation bar
        addQuitButtonOnNavigationBar()
    }
    
    //custom button action
    @IBAction func reTakeButtonAction(_ sender: Any) {
        //print("Retake button clicked")
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:RoomScanApproval_Retake"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
            
        }
        roomScanStatusTimer.invalidate()
        _ = navigationController?.popViewController(animated: true)
    }
    
    //Notification Handler
    @objc func statusManager() {
        self.updateUserInterface()
    }
    
    //Network related method
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            //            view.backgroundColor = .red
            debugPrint("ViewController: Network became unreachable")
        case .wifi:
            if(kibanaLogEnable == true)
            {
                NetworkingClass.submitKibanaLogApiCallFromNative(message: "RoomScanApprovalProcessingVC is connected with wifi", level: kibanaLevelName)
            }
            
            //            view.backgroundColor = .green
            print("ViewController: Network reachable through WiFi")
        case .wwan:
            if(kibanaLogEnable == true)
            {
                NetworkingClass.submitKibanaLogApiCallFromNative(message: "RoomScanApprovalProcessingVC is connected with wwan", level: kibanaLevelName)
            }
            print("ViewController: Network reachable through Cellular Data")
        }
        
        if(status == .unreachable)
        {
            let alertController = UIAlertController(title: proctorTrackTitle , message: internetAccessAlertMessage, preferredStyle: .alert)
            
            self.present(alertController, animated: true, completion:nil)
        }
        else if(status == .wifi || status == .wwan)
        {
            if self.presentedViewController == nil
            {
                print("Alert not load")
            }
            else
            {
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        
    }
    
}
