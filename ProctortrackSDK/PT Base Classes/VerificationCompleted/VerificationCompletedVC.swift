//
//  VerificationCompletedVC.swift
//  ProctorTrack
//
//  Created by Diwakar Garg on 12/02/2019.
//  Copyright © 2019 Diwakar Garg. All rights reserved.
//

import UIKit


class VerificationCompletedVC: UIViewController {

    @IBOutlet weak var launchDesktopTestButton: UIButton!
    
    @IBOutlet weak var verificationCompletedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addBackground()
        
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:VerificationCompleted_Start"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        
        self.customQuitButtonOnQrCode()
        self.verificationCompletedLabel.textColor = lightGreenColor
        launchDesktopTestButton.layer.cornerRadius = buttonRoundCornerValue
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:VerificationCompleted_end"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
            
        }
        NotificationCenter.default.removeObserver(self, name: .flagsChanged, object: nil)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        buttonClickedHandler = true
        DispatchQueue.main.async {
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
    
    //Notification Handler
    @objc func statusManager() {
        self.updateUserInterface()
    }
    
    //Network related method
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            debugPrint("ViewController: Network became unreachable")
        case .wifi:
            print("ViewController: Network reachable through WiFi")
        case .wwan:
            print("ViewController: Network reachable through Cellular Data")
        }
        
        if(status == .unreachable)
        {
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: proctorTrackTitle , message: internetAccessAlertMessage, preferredStyle: .alert)
                self.present(alertController, animated: true, completion:nil)
            }
        }
        else if(status == .wifi || status == .wwan)
        {
            DispatchQueue.main.async {
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
    
    
    var buttonClickedHandler : Bool = true
    
    @IBAction func launchDesktopTestButtonAction(_ sender: Any) {
        if (UtilityClass.isInternetAvailable())
        {
            self.showActivityIndicatory()
            if (buttonClickedHandler == true) {
                buttonClickedHandler = false
             
                /*
                if (app_type == "et") {
                    guard let documentID = UserDefaults.standard.string(forKey: testsession_uuid) else {return}
                    FirestoreDB.shared.updateRoomScanStateForElectronApp(documentID: documentID) {[weak self] (success, message) in
                        if self != nil {
                            if(kibanaLogEnable == true) {
                                let finalMessage = kibanaPrefix + "event: updateRoomScanStateForElectronApp" + seprator + "type: \(message)"
                                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                            }
                        }
                    }
                }
              */
                self.scanCompletedApi { (success) in
                    self.stopAnimating()
                    if (success) {
                        UserDefaults.standard.set("True", forKey: uploadCompleted)
                        self.navigateToNextScreen()
                    }
                    else {
                        self.buttonClickedHandler = true
                        self.showErrorAlert()
                    }
                }
            }
        }
        else {
            alert(title: proctorTrackTitle , message: internetAccessAlertMessage)
        }
    }
    
    private func showErrorAlert() {
        let alertController = UIAlertController(title: proctorTrackTitle, message: "Something went wrong, please try again", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: okAlertTitle, style: .default,handler:nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private var activityIndicator: UIActivityIndicatorView!
    private func showActivityIndicatory() {
        self.activityIndicator = UIActivityIndicatorView(style: .gray)
        self.activityIndicator.center = self.view.center
        self.view.addSubview(self.activityIndicator)
        self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
    }
    
    private func stopAnimating() {
        self.view.isUserInteractionEnabled = true
        self.activityIndicator.stopAnimating()
    }
    
    private func navigateToNextScreen() {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            if(liveMonitoringScanRequired)
            {
                self.performSegue(withIdentifier: liveScreenLockerSegue, sender: self)
            }
            else {
                if(monitoringWithLocalChunkRequired) {
                    self.performSegue(withIdentifier: liveScreenLockerSegue, sender: self)
                }
                else {
                    self.performSegue(withIdentifier: screenLockerSegue, sender: self)
                }
            }
            break
            
        case .pad:
          //  self.navigateToTestDeliveryScreen()
            break
            
        case .unspecified:
            break
            
        case .tv:
            break
            
        case .carPlay:
            break
        case .mac:
            break
        @unknown default:
            break
        }
    }
    
//    private func navigateToTestDeliveryScreen() {
//        let moveVC = self.storyboard?.instantiateViewController(withIdentifier: "TestDeliveryViewController") as! TestDeliveryViewController
//        self.navigationController?.pushViewController(moveVC, animated: true)
//    }
    
    //Function for satart session trigger
    func scanCompletedApi(complition: @escaping (_ success: Bool) -> Void)
    {
        var requestUrl: String?
        //Check for Application Type
        if (freshHire ==  true)
        {
            requestUrl = qRScanDoneURLRequestForFreshHire
        }
        else
        {
            requestUrl = qRScanDoneURLRequestForProctorScreen
        }
        
        NetworkingClass.sessionStartAndCloseApiCall(sessionUrl: requestUrl!) { (success) in
            if(success)
            {
                complition(true)
            }
            else
            {
                complition(false)
            }
        }
    }
  
    func customQuitButtonOnQrCode()
    {
        let rightButton = UIButton(type: .custom)
        rightButton.setImage(UIImage(named: "Quit-w"), for: .normal)
        rightButton.frame = CGRect(x: self.view.frame.width - 60, y: 40, width: 30, height: 30)
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        rightButton.addTarget(self, action:#selector(applicationCloseAlert), for: .touchUpInside)
        self.view.addSubview(rightButton)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIView {
    func addBackground() {
        // screen width and height:
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRect(x:0, y:0, width: width, height: height))
        imageViewBackground.image = UIImage(named: "ScreenBackgroundImage")
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill
        
        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }
    
}
