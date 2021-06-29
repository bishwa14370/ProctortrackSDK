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
        
        if(kibanaLogEnable == true) {
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
        if(kibanaLogEnable == true) {
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
        Utility.jumpBackToApp()
    }
  
    func customQuitButtonOnQrCode()
    {
        let rightButton = UIButton(type: .custom)
        rightButton.setImage(UIImage(named: "Quit-w", in: Bundle(for: type(of: self)), compatibleWith: nil), for: .normal)
        rightButton.frame = CGRect(x: self.view.frame.width - 60, y: 40, width: 30, height: 30)
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        rightButton.addTarget(self, action:#selector(applicationCloseAlert), for: .touchUpInside)
        self.view.addSubview(rightButton)
    }
}

extension UIView {
    func addBackground() {
        // screen width and height:
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        let imageViewBackground = UIImageView(frame: CGRect(x:0, y:0, width: width, height: height))
        imageViewBackground.image = UIImage(named: "ScreenBackgroundImage", in: Bundle(for: type(of: VerificationCompletedVC())), compatibleWith: nil)
        
        // you can change the content mode:
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill
        
        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }
    
}
