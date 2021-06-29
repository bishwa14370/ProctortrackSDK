//
//  SystemCheckVC.swift
//  Proctorscreen
//
//  Created by Diwakar Garg on 09/05/17.
//  Copyright © 2017 Diwakar Garg. All rights reserved.
//
import UIKit
import CoreBluetooth
import QuartzCore
import CoreTelephony
import AVFoundation
import WebKit

class SystemCheckVC: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate
{
    @IBOutlet weak var internetHeightConstraint: NSLayoutConstraint!
    // IBoutlet of label and Images for System check
    @IBOutlet weak var cameraCircleImage: UIImageView!
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var cameraLabel: UILabel!
    @IBOutlet weak var microphoneCircleImage: UIImageView!
    @IBOutlet weak var microphoneImage: UIImageView!
    @IBOutlet weak var microphoneLabel: UILabel!
    @IBOutlet weak var bluetoothCircleImage: UIImageView!
    @IBOutlet weak var bluetoothImage: UIImageView!
    @IBOutlet weak var bluetoothLabel: UILabel!
    @IBOutlet weak var internetCircleImage: UIImageView!
    @IBOutlet weak var internetImage: UIImageView!
    @IBOutlet weak var internetLabel: UILabel!
    @IBOutlet weak var storageCircleImage: UIImageView!
    @IBOutlet weak var storageImage: UIImageView!
    @IBOutlet weak var storageLabel: UILabel!
    @IBOutlet weak var batteryCircleImage: UIImageView!
    @IBOutlet weak var batteryImage: UIImageView!
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var systemCircleImage: UIImageView!
    @IBOutlet weak var systemImage: UIImageView!
    @IBOutlet weak var systemLabel: UILabel!
  //  @IBOutlet weak var desktopAppCircleImage: UIImageView!
  //  @IBOutlet weak var desktopAppImage: UIImageView!
  //  @IBOutlet weak var desktopAppLabel: UILabel!
    
    
    @IBOutlet weak var alertView: SystemCheckAlertView!
    //Variable declartion for the bluetooth
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var batteryCheckInSystemCheck:Bool = false
    var customAlert : Bool = false
    var internetAccessLoad : Bool = false
    
    var navigationBarTitle : UILabel?
    private var initialSpacing: CGFloat!
    private var chatView: UIView!
    private var supportWebView = WKWebView()
    private var proctorWebView = WKWebView()
    private var supportButton = UIButton()
    private var proctorButton = UIButton()
    
    //View Did Load function
    override func viewDidLoad() {
        super.viewDidLoad()
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:System_check_Start"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        if(offline == true)
        {
            internetHeightConstraint.constant = 0
        }else
        {
            initialSpacing = internetHeightConstraint.constant
        }
        
        bluetoothAccessScreen = true
        self.alertView.isHidden = true
        //        self.svRevealMethod()
        self.viewStyleMethod()
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        // Register to receive notification
        
        NotificationCenter.default.addObserver(self, selector: #selector(SystemCheckVC.receiveNotificationAction), name: NSNotification.Name(rawValue: startButtonClickNotificationSystemCheck), object: nil)
        
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
            let finalMessage = kibanaPrefix + "event:System_check_end"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        batteryCheckInSystemCheck = false
        bluetoothAccessScreen = false
        self.resetView()
        // Stop listening notification
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryStateDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: startButtonClickNotificationSystemCheck), object: nil)
        NotificationCenter.default.removeObserver(self, name: .flagsChanged, object: nil)
        UserDefaults.standard.removeObject(forKey: uploadSpeedValue)
        UserDefaults.standard.removeObject(forKey: downloadSpeedValue)
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            if let title = proctorWebView.title {
                if title != "0" && title.count > 0 {
                    self.chatView.subviews[1].isHidden = false
                }
            }
        }
    }
    
    private func setupPanGestureForChatView() {
        var panGestureForChatView = UIPanGestureRecognizer()
        panGestureForChatView = UIPanGestureRecognizer(target: self, action: #selector(draggedView))
        self.chatView.isUserInteractionEnabled = true
        self.chatView.addGestureRecognizer(panGestureForChatView)
    }
    
    private func setupChatView() {
        let window:UIWindow = UIApplication.shared.keyWindow!
        self.chatView = UIView(frame: CGRect(x: 20, y: 100, width: 270, height: 400))
        window.addSubview(self.chatView)
        let topView = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 60))
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.setImage(UIImage(named: "chatMessage"), for: .normal)
        button.addTarget(self, action: #selector(didSelectButton), for: .touchUpInside)
        topView.addSubview(button)
        self.chatView.addSubview(topView)
        let bottomView = UIView(frame: CGRect(x: 0, y: 60, width: 270, height: 340))
        let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 40))
        supportButton = UIButton(frame: CGRect(x: 20, y: 10, width: 100, height: 30))
        supportButton.setTitle("Support", for: .normal)
        supportButton.setImage(UIImage(named: "support"), for: .normal)
        supportButton.imageEdgeInsets.left = -5
        supportButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        supportButton.addTarget(self, action: #selector(didSelectSupportButton), for: .touchUpInside)
        supportButton.layer.cornerRadius = 5.0
        supportButton.backgroundColor = .systemBlue
        buttonView.addSubview(supportButton)
        proctorButton = UIButton(frame: CGRect(x: 150, y: 10, width: 100, height: 30))
        proctorButton.setTitle("Proctor", for: .normal)
        proctorButton.setImage(UIImage(named: "proctor"), for: .normal)
        proctorButton.imageEdgeInsets.left = -5
        proctorButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        proctorButton.addTarget(self, action: #selector(didSelectProctorButton), for: .touchUpInside)
        proctorButton.layer.cornerRadius = 5.0
        proctorButton.backgroundColor = .gray
        buttonView.addSubview(proctorButton)
        bottomView.addSubview(buttonView)
        
        supportWebView = WKWebView(frame: CGRect(x: 0, y: 50, width: 270, height: 290))
        bottomView.addSubview(supportWebView)
        
        proctorWebView = WKWebView(frame: CGRect(x: 0, y: 50, width: 270, height: 290))
        bottomView.addSubview(proctorWebView)
        proctorWebView.isHidden = true
        
        bottomView.isHidden = true
        self.chatView.addSubview(bottomView)
        
        if let loadUrl = URL(string: baseUrlForFreshHire + "/614e76646a34302518395604/support/freshchat/") {
            var request = URLRequest(url: loadUrl)
            request.httpShouldHandleCookies = true
            supportWebView.load(request)
        }
        
        if let loadUrl = URL(string: chatUrl) {
            var request = URLRequest(url: loadUrl)
            request.httpShouldHandleCookies = true
            proctorWebView.load(request)
        }
    }
    
    @objc func didSelectSupportButton() {
        proctorWebView.isHidden = true
        supportWebView.isHidden = false
        supportButton.backgroundColor = .systemBlue
        proctorButton.backgroundColor = .gray
    }
    
    @objc func didSelectProctorButton() {
        supportWebView.isHidden = true
        proctorWebView.isHidden = false
        proctorButton.backgroundColor = .systemBlue
        supportButton.backgroundColor = .gray
    }
    
    @objc func didSelectButton() {
        if self.chatView.subviews[1].isHidden == true {
            UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
                self.chatView.subviews[1].isHidden = false
            })
        }
        else {
            UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
                self.chatView.subviews[1].isHidden = true
            })
        }
    }
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer) {
        if (self.view.frame.contains(chatView.frame)) {
            let oldCenter = self.chatView.center
            let translation = sender.translation(in: self.view)
            chatView.center = CGPoint(x: chatView.center.x + translation.x, y: chatView.center.y + translation.y)
            sender.setTranslation(CGPoint.zero, in: self.view)
            if (!self.view.frame.contains(chatView.frame)) {
                chatView.center = oldCenter
            }
        }
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
            internetAccessLoad = true
            let alertController = UIAlertController(title: proctorTrackTitle , message: internetAccessAlertMessage, preferredStyle: .alert)
            //            if(customAlert == true)
            //            {
            //                self.dismiss(animated: true, completion: nil)
            //            }
            
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
            
            
            if(customAlert == true)
            {
                self.showAlert()
            }
            else
            {
                self.restartSystemCheck()
            }
        }
    }
    
    //Notification Handler
    @objc func statusManager() {
        self.updateUserInterface()
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
        navigationBarTitle?.text = systemCheckAlertTitle
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
    
    
    //Custom View style function
    fileprivate func viewStyleMethod ()
    {
        self.hideViewContent()
        self.navigationBarAddMethod()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.showAlert()
        })
    }
    
    //NotificationAction function
    @objc func receiveNotificationAction()
    {
        self.customAlert = false
        alertView.isHidden = true
        print("alert function ok button clicked")
        if (offline ==  true)
        {
            self.showViewContent()
            self.restartSystemCheck()
        }
        else
        {
            self.showViewContent()
            if(UtilityClass.isInternetAvailable())
            {
                self.fetchConfigurationforExam { (success) in
                    if (success)
                    {
                        self.restartSystemCheck()
                    }
                    else
                    {
                        
                        let alert = UIAlertController(title: alertTitle, message: configurationApiFailed , preferredStyle: UIAlertController.Style.alert)
                        let okAction = UIAlertAction(title: reTryTitle, style: .default) { (action) in
                            self.receiveNotificationAction()
                        }
                        let closeApp = UIAlertAction(title: abortAlertTitle, style: .default) { (action) in
                            //Send to back page
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                        alert.addAction(okAction)
                        alert.addAction(closeApp)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            else
            {
                print("No internet Connection")
            }
        }
    }
    
    //function for showing the alert in the screen
    func showAlert()
    {
        self.customAlert = true
        alertView.isHidden = false
        alertView.titleLabel.text = systemCheckAlertTitle
        alertView.messageLabel.text = systemCheckAlertMessage
        //Spring Animation
        self.alertView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        //Damping must be between 1 and 0 & Animation Effect
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 20.0, options: [] , animations: {
            self.alertView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
    }
    
    //function for changing the color of label text
    func changeLabelText(label:UILabel)
    {
        label.textColor = textColorCode
    }
    
    //Function for highliting the imageview
    func highlightImageViewImage(image:UIImageView)
    {
        image.image  =  image.image?.maskWithColor(color: textColorCode)
    }
    
    //Function for highliting the ERROR imageview
    func errorImageViewImage(image:UIImageView)
    {
        image.image  =  image.image?.maskWithColor(color:UIColor.red)
    }
    
    //function for changing the color of error label text
    func errorLabelText(label:UILabel)
    {
        label.textColor = UIColor.red
    }
    
    //Function for highliting the imageview
    func normalImageViewImage(image:UIImageView)
    {
        image.image  =  image.image?.maskWithColor(color: UIColor.black)
    }
    
    //function for changing the color of label text
    func defaultLabelText(label:UILabel)
    {
        label.textColor = UIColor.black
    }
    
    //Reset the view item
    func resetView()
    {
        //code for image hiding
        normalImageViewImage(image: cameraCircleImage)
        normalImageViewImage(image: microphoneCircleImage)
     //   normalImageViewImage(image: bluetoothCircleImage)
        normalImageViewImage(image: internetCircleImage)
        normalImageViewImage(image: storageCircleImage)
        normalImageViewImage(image: batteryCircleImage)
        normalImageViewImage(image: systemCircleImage)
    //    normalImageViewImage(image: desktopAppCircleImage)
        normalImageViewImage(image: cameraImage)
        normalImageViewImage(image: microphoneImage)
     //   normalImageViewImage(image: bluetoothImage)
        normalImageViewImage(image: internetImage)
        normalImageViewImage(image: storageImage)
        normalImageViewImage(image: batteryImage)
        normalImageViewImage(image: systemImage)
    //    normalImageViewImage(image: desktopAppImage)
        //Code for label hiding
        defaultLabelText(label: cameraLabel)
        defaultLabelText(label: microphoneLabel)
    //    defaultLabelText(label: bluetoothLabel)
        defaultLabelText(label: internetLabel)
        defaultLabelText(label: storageLabel)
        defaultLabelText(label: batteryLabel)
        defaultLabelText(label: systemLabel)
    //    defaultLabelText(label: desktopAppLabel)
    }
    
    
    //Hide the view items
    func hideViewContent()
    {
        //code for image hiding
        hideImageView(image: cameraCircleImage)
        hideImageView(image: microphoneCircleImage)
        hideImageView(image: bluetoothCircleImage)
        hideImageView(image: internetCircleImage)
        hideImageView(image: storageCircleImage)
        hideImageView(image: batteryCircleImage)
        hideImageView(image: systemCircleImage)
     //   hideImageView(image: desktopAppCircleImage)
        hideImageView(image: cameraImage)
        hideImageView(image: microphoneImage)
        hideImageView(image: bluetoothImage)
        hideImageView(image: internetImage)
        hideImageView(image: storageImage)
        hideImageView(image: batteryImage)
        hideImageView(image: systemImage)
     //   hideImageView(image: desktopAppImage)
        
        //Code for label hiding
        hideLabel(label: cameraLabel)
        hideLabel(label: microphoneLabel)
        hideLabel(label: bluetoothLabel)
        hideLabel(label: internetLabel)
        hideLabel(label: storageLabel)
        hideLabel(label: batteryLabel)
        hideLabel(label: systemLabel)
      //  hideLabel(label: desktopAppLabel)
    }
    
    func hideLabel(label:UILabel)
    {
        label.isHidden = true
    }
    
    //function for hide the images
    func hideImageView(image:UIImageView)
    {
        image.isHidden = true
    }
    
    func showLabel(label:UILabel)
    {
        label.isHidden = false
    }
    
    //function for hide the images
    func showImageView(image:UIImageView)
    {
        image.isHidden = false
    }
    
    //Show the view items
    func showViewContent()
    {
        
        if (offline ==  false)
        {
            showImageView(image: internetCircleImage)
            showImageView(image: internetImage)
            showLabel(label: internetLabel)
        }
        
        //code for image showing
        showImageView(image: cameraCircleImage)
        showImageView(image: microphoneCircleImage)
      //  showImageView(image: bluetoothCircleImage)
        showImageView(image: storageCircleImage)
        showImageView(image: batteryCircleImage)
        showImageView(image: systemCircleImage)
     //   showImageView(image: desktopAppCircleImage)
        showImageView(image: cameraImage)
        showImageView(image: microphoneImage)
      //  showImageView(image: bluetoothImage)
        showImageView(image: storageImage)
        showImageView(image: batteryImage)
        showImageView(image: systemImage)
     //   showImageView(image: desktopAppImage)
        //Code for label showing
        showLabel(label: cameraLabel)
        showLabel(label: microphoneLabel)
      //  showLabel(label: bluetoothLabel)
        showLabel(label: storageLabel)
        showLabel(label: batteryLabel)
        showLabel(label: systemLabel)
      //  showLabel(label: desktopAppLabel)
        self.cameraCircleImage.blinkImage()
        
        self.highlightImageViewImage(image: cameraCircleImage)
        
    }
    
    //function for fetching the configuration from the server (Api Call)
    func fetchConfigurationforExam(complition: @escaping (_ success: Bool) -> Void)
    {
        var url: String?
        //Check for Application Type
        if (freshHire ==  true)
        {
            url = "\(baseUrlForFreshHire)\(configurationUrl)"
        }
        else
        {
            url = "\(baseUrlForProctorScreen)\(configurationUrl)"
        }
        NetworkingClass.configurationApiCall(uploadUrl: url!, reuestForURLCompletionHandler: { (success, response) in
            if success
            {
                let status = response[statusResponse] as? String
                let message = response[messageResponse] as? String
                if (status == failedResponse)
                {
                    alert(title: alertTitle, message: message!)
                    complition(false)
                }
                else
                {
                    if(response["detail"] as? String == "Authentication credentials were not provided.")
                    {
                        complition(false)
                    }
                    else
                    {
                        if(kibanaLogEnable == true)
                        {
                            let finalMessage = kibanaPrefix + "config api response: \(response)"
                            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                        }
                        callBackUrl = response[test_callback_url] as! String
                        if let chat_url = response["chat_url"] as? String {
                            chatUrl = chat_url
                            switch UIDevice.current.userInterfaceIdiom {
                            case .phone:
                                break
                                
                            case .pad:
                                self.setupChatView()
                                self.setupPanGestureForChatView()
                                self.proctorWebView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
                                break
                                
                            case .unspecified:
                                break
                                
                            case .tv:
                                break
                                
                            case .carPlay:
                                break
                            @unknown default:
                                break
                            }
                        }
                        let testData = response[view_app_config] as! Dictionary<String,Any>
                        calculatorEnable  = testData[is_onscreen_calculator_allowed] as? Bool ?? false
                        copyPasteEnable  = testData[is_copy_paste_disabled] as? Bool ?? false
                        testMaxDuration  = testData[test_max_duration] as! Int
                        
                        if let bluetoothRequirement = testData["is_bluetooth_check_required"] as? Bool {
                            is_bluetooth_check_required = bluetoothRequirement
                        }
                        
                        if let diyProctoring = testData["is_diy_proctoring"] as? Bool {
                            is_diy_proctoring = diyProctoring
                        }
                        
                        if let isNoteRequired = testData["is_note_required"] as? Bool {
                            UserDefaults.standard.set(isNoteRequired, forKey: noteRequired)
                        }
                        
                        if let isKioskModeEnabled = testData["is_mobile_kiosk_mode_enabled"] as? Bool {
                            UserDefaults.standard.set(isKioskModeEnabled, forKey: kioskModeKey)
                        }
                        
                        //  if let requiresFaceScanVerification = testData["is_face_verification_activated"] as? Bool {
                        //        requires_face_scan_verification = requiresFaceScanVerification
                        //   }
                        
                        if let requiresIdScanVerification = testData["requires_id_scan_verification"] as? Bool {
                            requires_id_scan_verification = requiresIdScanVerification
                        }
                        
                        if let screenRecordingEnabled = testData["is_mobile_screen_recording_enabled"] as? Bool {
                            UserDefaults.standard.set(screenRecordingEnabled, forKey: screenRecordingKey)
                            if screenRecordingEnabled {
                                if let streamUrls = response[stream_urls] as? [String:Any] {
                                    if let streamUrl = streamUrls["screen_monitoring_mobile"] as? String {
                                        let screenSharingUrl = streamUrl.components(separatedBy: "websocket/")
                                        if let first = screenSharingUrl.first, let last = screenSharingUrl.last {
                                            screenRecordingUrl = first + "websocket"
                                            screenRecordingStreamID = last
                                            UserDefaults.standard.set(screenRecordingUrl, forKey: screenRecordingUrlKey)
                                            UserDefaults.standard.set(screenRecordingStreamID, forKey: screenRecordingStreamIDKey)
                                        }
                                    }
                                }
                            }
                        }
                        
                        if let firebaseConfig = testData["ios_fb_conf"] as? [String:String] {
                            UserDefaults.standard.set(firebaseConfig, forKey: firebaseConfigKey)
                            if(kibanaLogEnable == true){
                                let finalMessage = kibanaPrefix + "event: System_check" + seprator + "type: Firebase Environment: \(firebaseConfig)"
                                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                            }
                        }
                        else {
                            let dict:[String:String] = ["firebaseUrl": "https://proctortrack-prod-us.firebaseio.com", "gcmSenderID": "471638052311", "firebaseProjectId": "proctortrack-prod-us", "firebaseApiKey": "AIzaSyCXw1f5bofmgA39432-Xta14yCTPRJnvuk","firebaseApplicationId": "1:471638052311:ios:c677c9d3d8412c9e088f92"]
                            UserDefaults.standard.set(dict, forKey: firebaseConfigKey)
                            if(kibanaLogEnable == true){
                                let finalMessage = kibanaPrefix + "event: System_check" + seprator + "type: Default Live Firebase Environment: \(dict)"
                                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                            }
                        }
                        
                        if let isLiveScanRequired = testData["requires_live_scans"] as? Bool {
                            liveRoomScanRequired = isLiveScanRequired
                            if(liveRoomScanRequired) {
                                if(response[stream_urls] != nil)
                                {
                                    let streamUrls = response[stream_urls] as! Dictionary<String,Any>
                                    if(streamUrls["roomscan_mobile"] != nil)
                                    {
                                        if let streamUrl = streamUrls["roomscan_mobile"] as? String {
                                            let roomScanStreamUrl = streamUrl.components(separatedBy: "websocket/")
                                            if let first = roomScanStreamUrl.first, let last = roomScanStreamUrl.last {
                                                liveStreamBaseUrl = first + "websocket"
                                                liveRoomScaningStreamID = last
                                                UserDefaults.standard.set(liveStreamBaseUrl, forKey: appBaseUrl)
                                                UserDefaults.standard.set(liveRoomScaningStreamID, forKey: roomScanStramId)
                                            }
                                        }
                                        if let roomscan_mobile_token = streamUrls["roomscan_mobile_token"] as? [String:Any], let token = roomscan_mobile_token["stream_token"] as? String {
                                            roomScanTokenID = token
                                            UserDefaults.standard.set(roomScanTokenID, forKey: roomScanToken)
                                        }
                                    }
                                }
                            }
                        }
                        
                        var monitoringType = 0
                        if(testData[mobileMonitoringType] != nil)
                        {
                            monitoringType = testData[mobileMonitoringType] as! Int
                            if( monitoringType == 0)
                            {
                                monitoringWithLocalChunkRequired = false
                                liveMonitoringScanRequired = false
                            }
                            else if( monitoringType == 1)
                            {
                                monitoringWithLocalChunkRequired = true
                                liveMonitoringScanRequired = false
                            }
                            else if( monitoringType == 2)
                            {
                                monitoringWithLocalChunkRequired = false
                                liveMonitoringScanRequired = true
                            }
                            else
                            {
                                monitoringWithLocalChunkRequired = false
                                liveMonitoringScanRequired = true
                            }
                        }
                        else
                        {
                            monitoringWithLocalChunkRequired = false
                            liveMonitoringScanRequired = false
                        }
                        
                        UserDefaults.standard.set(liveMonitoringScanRequired, forKey: requires_live_monitoringKey)
                        
                        if(liveMonitoringScanRequired) {
                            if(response[stream_urls] != nil)
                            {
                                let streamUrls = response[stream_urls] as! Dictionary<String,Any>
                                if(streamUrls["monitoring_mobile"] != nil)
                                {
                                    if let streamUrl = streamUrls["monitoring_mobile"] as? String {
                                        let liveStreamUrl = streamUrl.components(separatedBy: "websocket/")
                                        if let first = liveStreamUrl.first, let last = liveStreamUrl.last {
                                            liveStreamBaseUrl = first + "websocket"
                                            liveMonitoringStreamID = last
                                            UserDefaults.standard.set(liveStreamBaseUrl, forKey: appBaseUrl)
                                            UserDefaults.standard.set(liveMonitoringStreamID, forKey: monitoringStramId)
                                        }
                                    }
                                   if let monitoring_mobile_token = streamUrls["monitoring_mobile_token"] as? [String:Any], let token = monitoring_mobile_token["stream_token"] as? String {
                                        liveStreamingTokenID = token
                                        UserDefaults.standard.set(liveStreamingTokenID, forKey: liveStreamingToken)
                                    }
                                }
                            }
                        }
                      
                        if let autoRenamingEnabled = testData["is_stream_auto_renaming_enabled"] as? Bool {
                            complition(true)
                          /*
                            is_stream_auto_renaming_enabled = autoRenamingEnabled
                            UserDefaults.standard.set(is_stream_auto_renaming_enabled, forKey: streamAutoRenamingKey)
                            
                            if is_stream_auto_renaming_enabled || app_type == "et"{
                                NetworkingClass.getFirebaseToken {[weak self] (success, auth_token) in
                                    if self != nil {
                                        if success {
                                            guard let token = auth_token else {return}
                                            FirestoreDB.shared.signUpWithFirebaseToken(auth_token: token) {[weak self] (success, message) in
                                                if self != nil {
                                                    if success {
                                                        if(kibanaLogEnable == true)
                                                        {
                                                            let finalMessage = "signUpWithFirebaseToken success:" + message
                                                            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                                                        }
                                                        complition(true)
                                                    }
                                                    else {
                                                        if(kibanaLogEnable == true)
                                                        {
                                                            let finalMessage = "signUpWithFirebaseToken failed:" + message
                                                            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                                                        }
                                                        complition(false)
                                                    }
                                                }
                                            }
                                        }
                                        else {
                                            complition(false)
                                        }
                                    }
                                }
                            }
                            else {
                                complition(true)
                            }
                         */
                        }
                        else {
                            complition(true)
                        }
                    }
                }
            }
            else
            {
                complition(false)
            }
        })
    }
    
    //Chceck for camera accesspermission
    func camerverification()
    {
        // First we check if the device has a camera (otherwise will crash in Simulator - also, some iPod touch models do not have a camera).
        let deviceHasCamera = UIImagePickerController.isSourceTypeAvailable(.camera)
        if (deviceHasCamera) {
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch authStatus {
            case .authorized: camerPermissionGiven()
            case .denied:
                if freshHire
                {
                    self.errorImageViewImage(image: cameraCircleImage)
                    self.errorImageViewImage(image: cameraImage)
                    self.errorLabelText(label: cameraLabel)
                    alertPromptToAllowCameraAccessViaSettings(title: proctorTrackCameraAlertTitle, message: cameraAlertMessage)
                }
                else
                {
                    self.errorImageViewImage(image: cameraCircleImage)
                    self.errorImageViewImage(image: cameraImage)
                    self.errorLabelText(label: cameraLabel)
                    alertPromptToAllowCameraAccessViaSettings(title: proctorScreenCameraAlertTitle, message: cameraAlertMessage)
                }
                if(kibanaLogEnable == true){
                    let finalMessage = kibanaPrefix + "event:system_check_camera_error/ permission is not given"
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                }
            case .notDetermined: permissionPrimeCameraAccess()
            default: permissionPrimeCameraAccess()
            }
        }
        else
        {
            self.errorImageViewImage(image: cameraCircleImage)
            self.errorImageViewImage(image: cameraImage)
            self.errorLabelText(label: cameraLabel)
            alert(title: alertTitle, message: checkCameraAccessMessage)
        }
    }
    
    // ask for the permission for camera
    func permissionPrimeCameraAccess() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        if deviceDiscoverySession.devices.count > 0 {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [weak self] granted in
                DispatchQueue.main.async {
                    self?.camerverification()
                }
            })
        }
    }
    
    //RestartSystem Check Method
    func restartSystemCheck()
    {
        internetAccessLoad = false
        self.highlightImageViewImage(image: cameraCircleImage)
        cameraCircleImage.blinkImage()
        self.camerverification()
    }
    
    //Camera Permission Gien
    func camerPermissionGiven()
    {
        self.cameraCircleImage.stopBlinkImage()
        self.highlightImageViewImage(image: cameraImage)
        self.changeLabelText(label: cameraLabel)
        
        if(kibanaLogEnable == true){
            let finalMessage = kibanaPrefix + "event:system_check_camera_ok"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
        //call microphone permission function here
        self.checkMicPermission()
    }
    
    //function for Check Mic permisssion
    func checkMicPermission(){
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            
            if(kibanaLogEnable == true){
                let finalMessage = kibanaPrefix + "event:system_check_microphone_ok"
                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
            }
            self.bluetoothVerfication()
        case AVAudioSession.RecordPermission.denied:
            if freshHire
            {
                self.errorImageViewImage(image: microphoneCircleImage)
                self.errorImageViewImage(image: microphoneImage)
                self.errorLabelText(label: microphoneLabel)
                alertPromptToAllowCameraAccessViaSettings(title: freshHireMicrophoneAlertTitle, message: microPhoneAccessrequestMessage)
            }
            else
            {
                self.errorImageViewImage(image: microphoneCircleImage)
                self.errorImageViewImage(image: microphoneImage)
                self.errorLabelText(label: microphoneLabel)
                alertPromptToAllowCameraAccessViaSettings(title: proctorScreenMicrophoneAlertTitle, message: microPhoneAccessrequestMessage)
            }
            if(kibanaLogEnable == true){
                let finalMessage = kibanaPrefix + "event:system_check_microphone_not_found / permission is not given"
                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
            }
            
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    if(kibanaLogEnable == true){
                        let finalMessage = kibanaPrefix + "event:system_check_microphone_ok"
                        NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                    }
                    
                    self.bluetoothVerfication()
                } else {
                    DispatchQueue.main.async {
                        if freshHire
                        {
                            self.errorImageViewImage(image: self.microphoneCircleImage)
                            self.errorImageViewImage(image: self.microphoneImage)
                            self.errorLabelText(label: self.microphoneLabel)
                            self.alertPromptToAllowCameraAccessViaSettings(title: freshHireMicrophoneAlertTitle, message: microPhoneAccessrequestMessage)
                        }
                        else
                        {
                            self.errorImageViewImage(image: self.microphoneCircleImage)
                            self.errorImageViewImage(image: self.microphoneImage)
                            self.errorLabelText(label: self.microphoneLabel)
                            self.alertPromptToAllowCameraAccessViaSettings(title: proctorScreenMicrophoneAlertTitle, message: microPhoneAccessrequestMessage)
                        }
                    }
                    if(kibanaLogEnable == true){
                        let finalMessage = kibanaPrefix + "event:system_check_microphone_not_found / permission is not given"
                        NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                    }
                }
            })
        @unknown default:
             break
        }
    }
    
    //Check for Bluetooth Status
    func bluetoothVerfication()
    {
        DispatchQueue.main.async {
            self.highlightImageViewImage(image: self.microphoneCircleImage)
            self.highlightImageViewImage(image: self.microphoneImage)
            self.changeLabelText(label: self.microphoneLabel)
        }
        
      //  let options = [CBCentralManagerOptionShowPowerAlertKey:0] //<-this is the magic bit!
      //  centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
        self.updateBluetoothAndMicroPhoneStaus()
    }
    
    //Update status
    func updateBluetoothAndMicroPhoneStaus()
    {
        // alert(title: "BlueTooth Status", message: "It is Off now")
    //    highlightImageViewImage(image: bluetoothCircleImage)
    //    highlightImageViewImage(image: bluetoothImage)
    //    changeLabelText(label: bluetoothLabel)
        
        DispatchQueue.main.async {
            self.highlightImageViewImage(image: self.internetCircleImage)
            self.internetCircleImage.blinkImage()
        }
        
        if (offline ==  false)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.networkTesting()
            })
        }
        else
        {
            self.highlightImageViewImage(image: self.storageCircleImage)
            self.highlightImageViewImage(image: self.storageImage)
            self.changeLabelText(label: self.storageLabel)
            self.updateDiskStatus()
        }
    }
    
    //Core function for checking the bluetooth status
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if #available(iOS 10.0, *){
            switch (central.state) {
            case CBManagerState.poweredOff:
                
                if(bluetoothAccessScreen)
                {
                    self.updateBluetoothAndMicroPhoneStaus()
                    if self.presentedViewController == nil
                    {
                        print("Alert not load")
                    }
                    else
                    {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
                if(kibanaLogEnable == true){
                    let finalMessage = kibanaPrefix + "event:Bluetooth is off"
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                }
                
            case CBManagerState.unauthorized:
                alertPromptToAllowCameraAccessViaSettings(title: bluetoothAlertTitle, message: bluetoothAccessRequestMessage)
            case CBManagerState.unknown:
                print("CBCentralManagerState.Unknown")
                if(bluetoothAccessScreen)
                {
                    self.updateBluetoothAndMicroPhoneStaus()
                }
                break
            case CBManagerState.poweredOn:
                print("CBCentralManagerState.PoweredOn")
                if (is_bluetooth_check_required) {
                    if freshHire
                    {
                        self.errorImageViewImage(image: bluetoothCircleImage)
                        self.errorImageViewImage(image: bluetoothImage)
                        self.errorLabelText(label: bluetoothLabel)
                        alertPromptToAllowCameraAccessViaSettings(title: freshHireBluetoothAlertTitle, message: blueToothAlertMessage)
                    }
                    else
                    {
                        self.errorImageViewImage(image: bluetoothCircleImage)
                        self.errorImageViewImage(image: bluetoothImage)
                        self.errorLabelText(label: bluetoothLabel)
                        alertPromptToAllowCameraAccessViaSettings(title: proctorScreenBluetoothAlertTitle, message: blueToothAlertMessage)
                    }
                }
                else {
                    if(bluetoothAccessScreen)
                    {
                        self.updateBluetoothAndMicroPhoneStaus()
                        if(kibanaLogEnable == true){
                            let finalMessage = kibanaPrefix + "event:Bluetooth is on"
                            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                        }
                    }
                }
            case CBManagerState.resetting:
                print("CBCentralManagerState.Resetting")
            case CBManagerState.unsupported:
                print("CBCentralManagerState.Unsupported")
                if(bluetoothAccessScreen)
                {
                    self.updateBluetoothAndMicroPhoneStaus()
                }
                break
            }
        }
        else
        {
            switch central.state.rawValue{
            case 0:
                print("CBCentralManagerState.Unknown")
                //For Simulator
                if(bluetoothAccessScreen)
                {
                    self.updateBluetoothAndMicroPhoneStaus()
                }
                break
            case 1:
                print("CBCentralManagerState.Resetting")
            case 2:
                print("CBCentralManagerState.Unsupported")
                if(bluetoothAccessScreen)
                {
                    self.updateBluetoothAndMicroPhoneStaus()
                    if self.presentedViewController == nil
                    {
                        print("Alert not load")
                    }
                    else
                    {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                break
            case 3:
                print("This app is not authorised to use Bluetooth low energy")
                break
            case 4:
                print("Bluetooth is currently powered off.")
                // alert(title: "BlueTooth Status", message: "It is Off now")
                if(bluetoothAccessScreen)
                {
                    self.updateBluetoothAndMicroPhoneStaus()
                    if self.presentedViewController == nil
                    {
                        print("Alert not load")
                    }
                    else
                    {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            //Handle th enext function here
            case 5:
                print("Bluetooth is currently powered on and available to use.")
                if freshHire
                {
                    self.errorImageViewImage(image: bluetoothCircleImage)
                    self.errorImageViewImage(image: bluetoothImage)
                    self.errorLabelText(label: bluetoothLabel)
                    alertPromptToAllowCameraAccessViaSettings(title: freshHireBluetoothAlertTitle, message: blueToothAlertMessage)
                }
                else
                {
                    self.errorImageViewImage(image: bluetoothCircleImage)
                    self.errorImageViewImage(image: bluetoothImage)
                    self.errorLabelText(label: bluetoothLabel)
                    alertPromptToAllowCameraAccessViaSettings(title: proctorScreenBluetoothAlertTitle, message: blueToothAlertMessage)
                }
            default:break
            }
        }
    }
    
    //Network testing
    func networkTesting() {
        let speedTest = NetworkSpeedTest()
        speedTest.checkDownloadSpeed {[weak self] (success) in
            if let this = self {
                if success {
                    if let speed = (UserDefaults.standard.object(forKey: downloadSpeedValue)) as? CGFloat {
                        if speed > minimumInternetSpeed {
                            DispatchQueue.main.async {
                                this.internetCircleImage.stopBlinkImage()
                                this.highlightImageViewImage(image: this.storageCircleImage)
                                this.highlightImageViewImage(image: this.storageImage)
                                this.changeLabelText(label: this.storageLabel)
                                this.updateDiskStatus()
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                this.errorImageViewImage(image: this.internetCircleImage)
                                this.errorImageViewImage(image: this.internetImage)
                                this.errorLabelText(label: this.internetLabel)
                                
                                let speed = (UserDefaults.standard.object(forKey: downloadSpeedValue)) as! CGFloat
                                let alert = UIAlertController(title:alertTitle , message: "Your downloding speed is: \(speed) kb/sec which is less than 128 Kbps so please check the internet speed", preferredStyle: UIAlertController.Style.alert)
                                let okAction = UIAlertAction(title: reTryTitle, style: .default) { (action) in
                                    this.networkTesting()
                                }
                                alert.addAction(okAction)
                                this.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
                else {
                    this.networkTesting()
                }
            }
        }
    }
    
    func uploadDataTesting() {
        let speedTest = NetworkSpeedTest()
        speedTest.checkUploadSpeed {[weak self] (success) in
            if let this = self {
                if success {
                    if let speed = (UserDefaults.standard.object(forKey: uploadSpeedValue)) as? CGFloat {
                        if speed > minimumInternetSpeed {
                            this.internetCircleImage.stopBlinkImage()
                            this.highlightImageViewImage(image: this.storageCircleImage)
                            this.highlightImageViewImage(image: this.storageImage)
                            this.changeLabelText(label: this.storageLabel)
                            this.updateDiskStatus()
                        }
                        else {
                            DispatchQueue.main.async {
                                this.errorImageViewImage(image: this.internetCircleImage)
                                this.errorImageViewImage(image: this.internetImage)
                                this.errorLabelText(label: this.internetLabel)
                                
                                let speed = (UserDefaults.standard.object(forKey: uploadSpeedValue)) as! CGFloat
                                let alert = UIAlertController(title:alertTitle , message: "Your uploading speed is: \(speed) kb/sec which is less than 128 Kbps so please check the internet speed", preferredStyle: UIAlertController.Style.alert)
                                let okAction = UIAlertAction(title: reTryTitle, style: .default) { (action) in
                                    this.uploadDataTesting()
                                }
                                alert.addAction(okAction)
                                this.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                }
                else {
                    this.uploadDataTesting()
                }
            }
        }
    }
    
    //Function for Storage Availability check
    func updateDiskStatus() {
        highlightImageViewImage(image: internetCircleImage)
        highlightImageViewImage(image: internetImage)
        changeLabelText(label: internetLabel)
        
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:SystemCheckDiskSpaceDetails" + seprator + "Used Space:" + DiskStatus.usedDiskSpace + seprator + "free space:" + DiskStatus.freeDiskSpace + seprator + "free space in bytes:\(DiskStatus.freeDiskSpaceInBytes)" + seprator + "Device Total Space:\(DiskStatus.totalDiskSpace)"
            
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
        
        
        if(liveMonitoringScanRequired)
        {
            checkDiskSpaceAccordingToMonitoringType(minimumHardDiskRequired: minimumMemoryForLiveScanRequired)
        }
        else
        {
            if(monitoringWithLocalChunkRequired)
            {
                checkDiskSpaceAccordingToMonitoringType(minimumHardDiskRequired: UInt64(UtilityClass.calculateMemoryAllocation(testMaxDuration * 60)))
            }
            else
            {
                checkDiskSpaceAccordingToMonitoringType(minimumHardDiskRequired: minimumMemoryForLiveScanRequired)
            }
        }
    }
    
    func checkDiskSpaceAccordingToMonitoringType(minimumHardDiskRequired:UInt64)
    {
        if (DiskStatus.freeDiskSpaceInBytes < minimumHardDiskRequired)
        {
            if(kibanaLogEnable == true)
            {
                NetworkingClass.submitKibanaLogApiCallFromNative(message:  kibanaPrefix + "Disk space is low during check", level: kibanaLevelName)
            }
            self.errorImageViewImage(image: storageCircleImage)
            self.errorImageViewImage(image: storageImage)
            self.errorLabelText(label: storageLabel)
            
            let alert = UIAlertController(title: memoryAlertTitle, message: memoryAlertMessage , preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: reTryTitle, style: .default) { (action) in
                self.restartSystemCheck()
            }
            let closeApp = UIAlertAction(title: closeAlertTitle, style: .default) { (action) in
                self.closeApplication(message: closeApplicationDeviceStorageMessage)
            }
            alert.addAction(okAction)
            alert.addAction(closeApp)
            present(alert, animated: true, completion: nil)
        }
        else
        {
            
            if (batteryCheck() == true)
            {
                if(kibanaLogEnable == true)
                {
                    let finalMessage = kibanaPrefix + "event:system_check_battery/ is below 50%"
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                }
                
                self.errorImageViewImage(image: batteryCircleImage)
                self.errorImageViewImage(image: batteryImage)
                self.errorLabelText(label: batteryLabel)
                let alert = UIAlertController(title: batteryLowAlertTitle, message: batteryLowAlertMessage , preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: reTryTitle, style: .default) { (action) in
                    self.restartSystemCheck()
                }
                let closeApp = UIAlertAction(title: closeAlertTitle, style: .default) { (action) in
                    self.closeApplication(message: closeApplicationBatteryLowMessage)
                }
                alert.addAction(okAction)
                alert.addAction(closeApp)
                present(alert, animated: true, completion: nil)
                //                alert(title: batteryAlertTitle, message: batteryAlertMessage)
            }
            else
            {
                highlightImageViewImage(image: batteryCircleImage)
                highlightImageViewImage(image: batteryImage)
                changeLabelText(label: batteryLabel)
                self.deviceDetails()
                //Do the next systemCheck
                print("BatteryCheckPass")
            }
            print("Sufficent Memory")
        }
    }
    //Function for Battery check
    func batteryCheck() -> Bool
    {
        batteryCheckInSystemCheck = true
        //Check for device battery
        UIDevice.current.isBatteryMonitoringEnabled = true;
        //        Notification message send if change in the battery level.
        NotificationCenter.default.addObserver(self, selector: #selector(batteryStateDidChange), name: UIDevice.batteryStateDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        //battery sate check
        let state = UIDevice.current.batteryState
        
        if state == .charging || state == .full {
            print("Device plugged in.")
            return false
        }
        else
        {
            //Find the batteryLevel
            var batteryLevel: Float {
                return UIDevice.current.batteryLevel
            }
            print(batteryLevel)
            if batteryLevel.isEqual(to: -1)
            {
                return false
            }
            else if batteryLevel .isLess(than: 50.0/100)
            {
                return true
            }
            else
            {
                return false
            }
        }
    }
    
    //Function For Battery parameter
    @objc func batteryStateDidChange(){
        // The stage did change: plugged, unplugged, full charge..
        let state = UIDevice.current.batteryState
        print("plugged, unplugged, full charge")
        if state == .charging || state == .full
        {
            if (batteryCheckInSystemCheck == true)
            {
                //Condition for chceking for alert present or not if present then dismiss and contrinue.
                if presentedViewController == nil {
                    
                } else{
                    self.dismiss(animated: false)
                }
                highlightImageViewImage(image: batteryCircleImage)
                highlightImageViewImage(image: batteryImage)
                changeLabelText(label: batteryLabel)
                self.deviceDetails()
            }
        }
    }
    
    //Function for battery level did change
    @objc func batteryLevelDidChange(){
        // The battery's level did change (98%, 99%, ...)
        print("plugged, unplugged, full charge")
        var batteryLevel: Float {
            return UIDevice.current.batteryLevel
        }
        print("Battery Level",batteryLevel)
        if batteryLevel .isLess(than: 50.0/100)
        {
            alert(title: batteryLowAlertTitle, message: batteryLowAlertMessage)
            if(kibanaLogEnable == true)
            {
                let finalMessage = kibanaPrefix + "event:system_check_battery/percentage:\(batteryLevel)"
                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
            }
        }
    }
    //Function for system check & Device Detail
    func deviceDetails()
    {
        self.report_memory()
        
        if(ProcessInfo.processInfo.physicalMemory < minimumRam)
        {
            
            if(kibanaLogEnable == true)
            {
                NetworkingClass.submitKibanaLogApiCallFromNative(message:  kibanaPrefix + "Minimum ram requirement is 512MB", level: kibanaLevelName)
            }
            self.closeApplication(message:closeApplicationDeviceMessage)
        }
        else
        {
            highlightImageViewImage(image: systemCircleImage)
            highlightImageViewImage(image: systemImage)
            changeLabelText(label: systemLabel)
            self.navigateToScreenAccordingToConfiguration()
          //  self.checkDesktopAppConnectivity()
        }
    }
    //checkDesktop App
//    func checkDesktopAppConnectivity()
//    {
//        self.desktopAppCircleImage.blinkImage()
//        highlightImageViewImage(image: desktopAppCircleImage)
//        highlightImageViewImage(image: desktopAppImage)
//        changeLabelText(label: desktopAppLabel)
//        //code for pinging the system desktop connectivity
//        if (UtilityClass.isInternetAvailable())
//        {
//            self.desktopAppCircleImage.stopBlinkImage()
//            self.navigateToScreenAccordingToConfiguration()
//        }
//
//    }
    
    func navigateToScreenAccordingToConfiguration()
    {
        
        if(faceScanRequired == true)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                if((UserDefaults.standard.object(forKey:"identityVerificationStatus")) != nil)
                {
                    //Bypass the view
                    self.performSegue(withIdentifier: byPassVerificationScreenSegue, sender: self)
                }
                else
                {
                    
                    self.performSegue(withIdentifier: identificationVerificationSegue, sender: self)
                }
            })
        }
        else if(photoIdRequired == true)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                if((UserDefaults.standard.object(forKey:"identityVerificationStatus")) != nil)
                {
                    //Bypass the view
                    let moveVC = self.storyboard?.instantiateViewController(withIdentifier: idScanViewController) as! IDScanVC
                    self.navigationController?.pushViewController(moveVC, animated: true)
                }
                else
                {
                    
                    self.performSegue(withIdentifier: identificationVerificationSegue, sender: self)
                }
            })
            
            
        }
        else if(roomScanRequired == true)
        {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                if((UserDefaults.standard.object(forKey:"identityVerificationStatus")) != nil)
                {
                    //Bypass the view
                    let moveVC = self.storyboard?.instantiateViewController(withIdentifier: roomScanViewController) as! RoomScanNewVC
                    self.navigationController?.pushViewController(moveVC, animated: true)
                }
                else
                {
                    
                    self.performSegue(withIdentifier: identificationVerificationSegue, sender: self)
                }
            })
            
        }
        else
        {
            let moveVC = self.storyboard?.instantiateViewController(withIdentifier: verificationCompletedScreen) as! VerificationCompletedVC
            self.navigationController?.pushViewController(moveVC, animated: true)
        }
        
    }
    
    //Memory Detail used
    func report_memory() {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        if kerr == KERN_SUCCESS {
            print("Memory used in bytes: \(taskInfo.resident_size)")
        }
        else {
            print("Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
        }
    }
    
    //Function for showing the genric setting alert for all the system check
    func alertPromptToAllowCameraAccessViaSettings(title:String, message: String) {
        
        if(message == blueToothAlertMessage)
        {
            let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: reTryTitle, style: .cancel) { (action) in
                if(bluetoothAccessScreen)
                {
                    self.restartSystemCheck()
                }
                else
                {
                    self.bluetoothVerfication()
                }
            }
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
            
        }
        else
        {
            let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: settingAlertTitle, style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    } else {
                        
                        let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
                        if let url = settingsUrl {
                            UIApplication.shared.openURL(url as URL)
                        }
                        print("Settings opened") // Prints true
                    }
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: cancelAlertTitle, style: .cancel) { (action) in
                if(bluetoothAccessScreen)
                {
                    self.restartSystemCheck()
                }
                else
                {
                    self.bluetoothVerfication()
                }
            }
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    //function for closing Application
    func closeApplication(message:String)
    {
        let alertController = UIAlertController (title: alertTitle, message: message , preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: okAlertTitle, style: .default) { (_) -> Void in
            UIApplication.shared.performSelector(inBackground: Selector(("terminateWithSuccess")), with: nil)
        }
        alertController.addAction(settingsAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - DGTopMenu Delegate
    func topMenuWillOpen() {
        print("topMenuWillOpen")
    }
    
    func topMenuWillClose() {
        print("topMenuWillClose")
    }
    
    func topMenuShouldOpenTopDownMenu() -> Bool {
        print("topMenuShouldOpenTopDownMenu")
        return false
    }
    
    func topMenuDidClose() {
        print("topMenuDidClose")
    }
    
    func topMenuDidOpen() {
        print("topMenuDidOpen")
    }
}

extension UIImageView {
    func blinkImage() {
        UIView.animate(withDuration: 0.8,
                       delay:0.0,
                       options:[.autoreverse, .repeat],
                       animations: {
                        self.alpha = 0
        }, completion: nil)
    }
    func stopBlinkImage() {
        alpha = 1
        layer.removeAllAnimations()
    }
}

extension UIImage {
    func maskWithColor(color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        
        color.setFill()
        
        context!.translateBy(x: 0, y: self.size.height)
        context!.scaleBy(x: 1.0, y: -1.0)
        
        context!.setBlendMode(CGBlendMode.colorBurn)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context!.draw(self.cgImage!, in: rect)
        
        context!.setBlendMode(CGBlendMode.sourceIn)
        context!.addRect(rect)
        context!.drawPath(using: CGPathDrawingMode.fill)
        
        let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return coloredImage
    }
}
