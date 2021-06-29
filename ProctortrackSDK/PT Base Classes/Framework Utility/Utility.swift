//
//  Utility.swift
//  FrameWorkTestPOC

import UIKit
import AVFoundation

class Utility {
    
    static var rootAppVC: UIViewController?
    
    static func performSegueToIdentityVerification(caller: UIViewController) {
        rootAppVC = caller
        let bundle = Bundle(for: SystemCheckVC.self)
        let storyboard = UIStoryboard(name: "Framework", bundle: bundle)
        DispatchQueue.main.async {
            if let vc = storyboard.instantiateViewController(withIdentifier: "systemCheckVC") as? SystemCheckVC {
                let navController =  UINavigationController(rootViewController: vc)
                navController.modalPresentationStyle = .fullScreen
                caller.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    static func jumpBackToApp() {
        rootAppVC?.dismiss(animated: true, completion: nil)
    }
}

extension UIApplication {
    
    class func getTopViewController(base: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

extension UIViewController {
    func addQuitButtonOnNavigationBar() {
        let rightButton = UIButton(type: .custom)
        let bundle = Bundle(for: type(of: self))
        let quitImg = UIImage(named: "Quit-w", in: bundle, compatibleWith: nil)
        rightButton.setImage(quitImg, for: .normal)
        rightButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        rightButton.addTarget(self, action:#selector(applicationCloseAlert), for: .touchUpInside)
        let logoutBarButtonItem = UIBarButtonItem(customView: rightButton)
        self.navigationItem.rightBarButtonItem  = logoutBarButtonItem
    }
    
    @objc func applicationCloseAlert()
    {
        let alertController = UIAlertController (title: "\"Proctortrack\" Would like to close the application", message: "", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            if ((UserDefaults.standard.string(forKey:sessionApiState)) != nil)
            {
                if ((UserDefaults.standard.object(forKey: sessionApiState)) as! String == "Start")
                {
                    if(kibanaLogEnable == true)
                    {
                        NetworkingClass.submitKibanaLogApiCallFromNative(message: kibanaPrefix + "event:app_quit_from_menu_bar", level: kibanaLevelName)
                    }
                    
                    UserDefaults.standard.set("True", forKey: uploadCompleted)
                    UserDefaults.standard.set(Date(), forKey: uploadCancelDateTime)
                    UserDefaults.standard.set("End", forKey: sessionApiState)
                    //Trigger local notification for upload the data in 24 hours
                    // NotificationManager.uploadStartAndUploadCompleteTriggerNotification(notificationMessage: notificationMessageForQuitApplicationCallfromMonitoringScreen, notificationTitle: notificationTitleForQuitApplicationCallfromMonitoringScreen)
                    //Kill the application
                    self.terminateApplication()
                }
                else
                {
                    clearTempFolder()
                    self.terminateApplication()
                }
            }
            else
            {
                clearTempFolder()
                self.terminateApplication()
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ (action) in
            //add the action here
        }
        alertController.addAction(cancelAction)
        
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func terminateApplication(){
        UIApplication.shared.performSelector(inBackground: Selector(("terminateWithSuccess")), with: nil)
    }
    
    func deviceInputSettingConfiguration(input: AVCaptureDeviceInput) -> AVCaptureDeviceInput
    {
        let device = input.device
        
        if(device.hasMediaType(.video)){
            do {
                try device.lockForConfiguration()
                device.activeVideoMinFrameDuration = .invalid
                device.automaticallyAdjustsVideoHDREnabled = false
                device.videoZoomFactor = 1.0
                if(device.isSmoothAutoFocusSupported)
                {
                    device.isSmoothAutoFocusEnabled = false
                }
                device.unlockForConfiguration()
            } catch {
                print("Error setting configuration: \(error)")
            }
        }
        return input
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
