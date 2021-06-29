//
//  IDScanResultVC.swift
//  ProctorTrack
//
//  Created by Diwakar Garg on 28/01/2019.
//  Copyright © 2019 Diwakar Garg. All rights reserved.
//

import UIKit

class IDScanResultVC: UIViewController {
    @IBOutlet weak var reScanButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var idImageView: UIImageView!

    
    //View did load function
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewStyleMethod()
        
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:IDscan_ResultScreen_start"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationBarAddMethod()
        //ScreenrecordingHandling
        if(screenRecordingStopEnable)
        {
            if #available(iOS 11.0, *) {
                addObserverForScreenRecording()
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:IDscan_ResultScreen_end"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    //Custom View style Function
    func viewStyleMethod ()
    {
        if let availableImage = UIImage (contentsOfFile: (getDirectoryPath() as NSString).appendingPathComponent(idScanImageName + "." + imageExtension))
        {
            idImageView.image=availableImage
        }
        reScanButton.layer.cornerRadius = buttonRoundCornerValue
        submitButton.layer.cornerRadius = buttonRoundCornerValue
    }
    
    //Navigation bar handling function
    func navigationBarAddMethod()
    {
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 3.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        self.navigationController?.navigationBar.layer.masksToBounds = false

        let customView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width - 100, height: (self.navigationController?.navigationBar.frame.size.height)!))
 
        let label = UILabel(frame: CGRect(x: 0, y: 0.0, width: self.view.frame.width , height: customView.frame.height))
        label.text = idScanTitle
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.left
        label.center.y = customView.center.y
        label.font =  UIFont(name: "Roboto-Bold", size: 18)
        customView.addSubview(label)
        let leftButton = UIBarButtonItem(customView: customView)
        self.navigationItem.leftBarButtonItem = leftButton
        
        //Add Quit Button on navigation bar
        addQuitButtonOnNavigationBar()
    }

    
    //rescanButtonAction function
    @IBAction func reScanButtonAction(_ sender: Any) {
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:id_scan_rescan"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)  
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    //submitButtonAction function
    @IBAction func submitButtonAction(_ sender: Any) {
        if(kibanaLogEnable == true) {
            let finalMessage = kibanaPrefix + "event:id_scan_submit"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
        
        if(bypassScanUploadFlow == true) {
//            if requires_id_scan_verification {
//                self.navigateToIdVerificationScreen()
//            }
//            else {
//                self.navigateToScreenAccordingToConfiguration()
//            }
            self.navigateToScreenAccordingToConfiguration()
        }
        else {
            self.uploadingChunksInBackground()
        }
    }
    
//    private func navigateToIdVerificationScreen() {
//        let moveVC = self.storyboard?.instantiateViewController(withIdentifier: "IDScanVerificationViewController") as! IDScanVerificationViewController
//        self.navigationController?.pushViewController(moveVC, animated: true)
//    }
    
    func navigateToScreenAccordingToConfiguration()
    {
        if(roomScanRequired == true)
        {
            if(liveRoomScanRequired == true)
            {
                let moveVC = self.storyboard?.instantiateViewController(withIdentifier: roomScanViewController) as! RoomScanNewVC
                self.navigationController?.pushViewController(moveVC, animated: true)
            }
            else
            {
                self.performSegue(withIdentifier: roomScanSegue, sender: self)
            }
            
        }
        else
        {
            let moveVC = self.storyboard?.instantiateViewController(withIdentifier: verificationCompletedScreen) as! VerificationCompletedVC
            self.navigationController?.pushViewController(moveVC, animated: true)
        }
        
    }
    
    
    //UploadChunksInBackGround
    func uploadingChunksInBackground()
    {
        let sendResponse = sendSocketConnection(socketMessage: UDP_CODE_UPLOAD_ID_SCAN_SUCCESS + "_" + UserDefaults.standard.string(forKey: testsession_id)!)
        print("Pringt the response of the socket message send",UDP_CODE_UPLOAD_ID_SCAN_SUCCESS + "_" + UserDefaults.standard.string(forKey: testsession_id)!)
        if sendResponse == false
        {
            print("UDP Message is not send for ID scan completed")
            if(kibanaLogEnable == true)
            {
                NetworkingClass.submitKibanaLogApiCallFromNative(message: "Udp message not send for ID scan completed", level: kibanaLevelName)
            }
        }
        else
        {
            if(kibanaLogEnable == true)
            {
                NetworkingClass.submitKibanaLogApiCallFromNative(message: UDP_CODE_UPLOAD_ID_SCAN_SUCCESS + "_" + UserDefaults.standard.string(forKey: testsession_id)!, level: kibanaLevelName)
            }
            print("UDP Message is send for ID scan completed")
        }
        
        
//         self.performSegue(withIdentifier: roomScanSegue, sender: self)
//
//        if (UtilityClass.isInternetAvailable())
//        {
            self.navigateToScreenAccordingToConfiguration()
//            ChunksUploadManager.chunksListFromDirectory(completionHandler: {(success) in
//                if(success)
//                {
//                    print("Uploading Success")
//                }
//                else
//                {
//                    print("Uploading Fail or nothing to upload")
//                }
//            })
//        }else
//        {
//            alert(title: proctorTrackTitle , message: internetAccessAlertMessage)
//        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension String {
    
    func slice(from: String, to: String) -> String? {
        
        print((range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
                //                substring(with: substringFrom..<substringTo)
            }
            } as Any)
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
                //                substring(with: substringFrom..<substringTo)
            }
        }
    }
    
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}
