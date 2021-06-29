//
//  RoomScanNewVC.swift
//  ProctorTrack
//
//  Created by Diwakar Garg on 14/09/2019.
//  Copyright © 2019 Diwakar Garg. All rights reserved.
//

import UIKit
import WebRTC
import AVFoundation

class RoomScanNewVC: UIViewController,RoomScanNewOverlayDelegate,AVCaptureFileOutputRecordingDelegate {
    var roomScanTimer = Timer()
    var deskScanTimer = Timer()
    var dotLabel: UILabel!
    var roomScanCount = 20
    var deskScanCount = 10
    var navigationBarTitle = UILabel()
    
    @IBOutlet weak var liveRecordingTimerLabel: UILabel!
  
    //Camera operation variable
    var captureSession = AVCaptureSession()
    var previewLayer:AVCaptureVideoPreviewLayer?
    var captureDevice:AVCaptureDevice!
    var longPressBeginTime: TimeInterval = 0.0
    var instructionLabel = UILabel()
    var timerLabel: UILabel!
    var horizontalLabel : UILabel?
    var verticalLabel : UILabel?
    var maxDuartionofFaceScan : Int =  15
    var cameraView: UIView?
    let dataOutput = AVCaptureVideoDataOutput()
    var movieOutput = AVCaptureMovieFileOutput()

    //Custom Label
    var countDownLabel : UILabel!
    var takeVideo = false
    var recordAndStopButton : UIButton!
    var overlayBarViewforButton: UIView!
    var overLayBarViewforInstruction: UIView!
    
    var overlayViewforDesk: UIView!
    var intrctionForStep: UILabel!
    var instructionForOverLay: UILabel!
    var overlayInstructionImage: UIImageView!
   
    var isViewWillDisappear : Bool = false
  //  var isRoomScanProcessCompleted : Bool = false
  //  var isStreamStarted : Bool = false
    
    lazy var frontCameraDevice: AVCaptureDevice? = {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        for device in deviceDiscoverySession.devices {
            if device.position == .back {
                return device
            }
        }
        return nil
    }()
    
    //Mic accessing function
    lazy var micDevice: AVCaptureDevice? = {
        return AVCaptureDevice.default(for: AVMediaType.audio)
    }()
    
    
    //temp file creation for recording
    private var tempFilePath: URL? = {
        if let tempPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tempMovie")?.appendingPathExtension(videoExtension).absoluteString {
            if FileManager.default.fileExists(atPath: tempPath) {
                do {
                    try FileManager.default.removeItem(atPath: tempPath)
                } catch {
                    print(error.localizedDescription)
                }
            }
            if let url = URL(string: tempPath) {
                return url
            }
        }
        return nil
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(liveRoomScanRequired)
        {
            if(kibanaLogEnable == true){
                let statusMessage =  kibanaPrefix + "event:RoomScan_start" + seprator + "type: live"
                NetworkingClass.submitKibanaLogApiCallFromNative(message: statusMessage, level: kibanaLevelName)
            }
        }
        else
        {
            if(kibanaLogEnable == true){
                let statusMessage =  kibanaPrefix + "event:RoomScan_start" + seprator + "type: offline"
                NetworkingClass.submitKibanaLogApiCallFromNative(message: statusMessage, level: kibanaLevelName)
            }
        }
    }
  
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
      
        liveRecordingTimerLabel.isHidden = true
        self.navigationBarAddMethod()

        NotificationCenter.default.addObserver(self, selector: #selector(appForegroundStateFunction), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appBackgroundStateFunction), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)

        //ScreenrecordingHandling
        if(screenRecordingStopEnable)
        {
            if #available(iOS 11.0, *) {
                addObserverForScreenRecording()
            } else {
                // Fallback on earlier versions
            }
        }
        
        if(liveRoomScanRequired)
        {
            self.loadLiveStreamingViewWhenViewAppears()
            self.viewStyleMethod ()
        }
        else
        {
            self.viewStyleMethod ()
            self.loadRecordingMethod()
        }
        self.overLayView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
        self.updateTimerAndTimerLabelText()
        if(liveRoomScanRequired)
        {
            if(self.client.isConnected())
            {
                self.isViewWillDisappear = true
                self.client.stop()
            }
        }
        
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:roomscan_end"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .flagsChanged, object: nil)
    }

    func setNavigationBarLabel(text:String) {
        if(text == "SendDelegate")
        {
            self.instructionLabel.isAccessibilityElement = true
            self.recordAndStopButton.isAccessibilityElement = true
            if(recordAndStopButton.isHidden == true)
            {
                if(!roomScanTimer.isValid)
                {
                    if(!deskScanTimer.isValid)
                    {
                        self.loadOverlayWithCustomNextButtonForDeskScan()
                    }
                    else
                    {
                        dotLabel.isHidden = false
                    }
                    self.navigationBarTitle.text = "Step 2: Record Desk Area"
                }
                else
                {
                    self.navigationBarTitle.text = "Step 1: 360 Video"
                    dotLabel.isHidden = false
                }
            }
            else
            {
                self.navigationBarTitle.text = "Step 1: 360 Video"
                if(roomScanTimer.isValid)
                {
                    dotLabel.isHidden = false
                }
            }
        }
        else
        {
            self.navigationBarTitle.text = text
            if self.overlayViewforDesk != nil {
                if self.view.subviews.contains(self.overlayViewforDesk) {
                    self.overlayViewforDesk.removeFromSuperview()
                }
            }
            dotLabel.isHidden = true
        }
    }

    //Custom function to call the pop up screen
    func overLayView()
    {
        let bottomSheetVC = storyboard?.instantiateViewController(withIdentifier: roomScanNewOverlay) as! RoomScanNewOverlayVC
        bottomSheetVC.delegate = self
        bottomSheetVC.didMove(toParent: self)
        let height = view.frame.height
        let width  = view.frame.width
        if((UserDefaults.standard.object(forKey:"roomScanChcekBoxStatus")) != nil)
        {
            if (deviceSize() == "X" || deviceSize() == "Xr") {
                bottomSheetVC.view.frame = CGRect(x: 0, y: height - 33, width: width, height: height - 85)
            }
            else{
                bottomSheetVC.view.frame = CGRect(x: 0, y: height - 20, width: width, height: height - 65)
            }
            self.instructionLabel.isAccessibilityElement = true
            self.recordAndStopButton.isAccessibilityElement = true
        }
        else
        {
            if (deviceSize() == "X" || deviceSize() == "Xr") {
                bottomSheetVC.view.frame = CGRect(x: 0, y: 84, width: width, height: height - 84)
                self.setNavigationBarLabel(text: roomScanOverlayTitle)
            }
            else {
                bottomSheetVC.view.frame = CGRect(x: 0, y: 65, width: width, height: height - 65)
                self.setNavigationBarLabel(text: roomScanOverlayTitle)
            }
            self.instructionLabel.isAccessibilityElement = false
            self.recordAndStopButton.isAccessibilityElement = false
        }
        
        self.view.addSubview(bottomSheetVC.view)
        self.addChild(bottomSheetVC)
    }
    
    
    //Navigation bar handling function
    fileprivate func navigationBarAddMethod()
    {
        guard let height = self.navigationController?.navigationBar.frame.size.height else {return}
        let customView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width - 100, height: height))
        
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 3.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        self.navigationController?.navigationBar.layer.masksToBounds = false
        
        navigationBarTitle = UILabel(frame: CGRect(x: 0, y: 10.0, width: customView.frame.width , height: customView.frame.height))
        navigationBarTitle.text = "Step 1: 360 Video"
        navigationBarTitle.textColor = UIColor.white
        navigationBarTitle.textAlignment = NSTextAlignment.left
        navigationBarTitle.center.y = customView.center.y
        navigationBarTitle.font =  UIFont(name: "Roboto-Bold", size: 18)
        
        //Add red Dot in the view
        dotLabel = UILabel(frame:  CGRect(x:navigationBarTitle.intrinsicContentSize.width + 5 , y: -navigationBarTitle.intrinsicContentSize.height/2 , width: 40, height: 40))
        dotLabel.textColor = UIColor.red
        dotLabel.text = "."
        dotLabel.textAlignment = .left
        dotLabel.font = dotLabel.font.withSize(40)
        customView.addSubview(dotLabel)
        
        customView.addSubview(navigationBarTitle)
        let leftButton = UIBarButtonItem(customView: customView)
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationController?.navigationBar.barTintColor =  textColorCode
        //Add Quit Button on navigation bar
        addQuitButtonOnNavigationBar()
        dotLabel.isHidden = true
    }
    
    
    @objc func moveToLockScreen()
    {
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix +  "event: roomscan_end" + seprator + "type: Move to approval/processing screen"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
        self.performSegue(withIdentifier: liveRoomScanProcessingScreenSegue, sender: self)
    }
    
    @objc func appForegroundStateFunction()
    {
       // start/stop capture session if necessary
    }
    
    @objc func appBackgroundStateFunction()
    {
        if (liveRoomScanRequired) {
            if (self.client.isConnected()) {
                self.client.stop()
            }
        }
        else {
            self.updateTimerAndTimerLabelText()
        }
    }
    
    func removeCustomViewFromParentView()
    {
        if  overlayViewforDesk != nil {
            if self.view.subviews.contains(overlayViewforDesk) {
                overlayViewforDesk.removeFromSuperview() 
            }
        }
    }
    
    //Mark: - Live streaming implementation
    let client: AntMediaClient = AntMediaClient.init()
    
    func loadLiveStreamingViewWhenViewAppears()
    {
        self.client.delegate = self
        self.client.setOptions(url: liveStreamBaseUrl, streamId: liveRoomScaningStreamID, token: roomScanTokenID, mode: .publish)
        self.client.setCameraPosition(position: .back)
        self.client.setTargetResolution(width: Int(self.view.frame.width), height: Int(self.view.frame.height))
        self.client.setLocalView(container: self.view, mode: .scaleAspectFill)
        self.client.initPeerConnection()
        self.isViewWillDisappear = false
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
    
    //MARK: normal recording
   
    fileprivate func viewStyleMethod ()
    {
        if(!liveRoomScanRequired)
        {
            cameraView = UIView(frame: CGRect(x: self.view.frame.origin.x ,y:self.view.frame.origin.y  ,width: self.view.frame.width ,height: self.view.frame.height))
            if let cameraView = self.cameraView {
                self.view.addSubview(cameraView)
            }
        }
        
        normalButtonToStartAndStopRecording()
        
        if(deviceSize() == "X" || deviceSize() == "Xr")
        {
            if let height = self.navigationController?.navigationBar.frame.size.height {
                overLayBarViewforInstruction = UIView(frame: CGRect(x: 0, y: height + 45, width: self.view.frame.width, height: 80))
                instructionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.overLayBarViewforInstruction.frame.width - 20, height: 80))
                countDownLabel = UILabel(frame: CGRect(x: 0, y:instructionLabel.frame.origin.y + 60, width: 100 , height: 30))
            }
        }
        else
        {
            if let height = self.navigationController?.navigationBar.frame.size.height {
                overLayBarViewforInstruction = UIView(frame: CGRect(x: 0, y: height + 20, width: self.view.frame.width, height: 80))
                instructionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.overLayBarViewforInstruction.frame.width - 20, height: 80))
                countDownLabel = UILabel(frame: CGRect(x: 0, y:instructionLabel.frame.origin.y + 50, width: 100 , height: 30))
            }
        }
        
        instructionLabel.text = instructionTextFor360RoomScan
        instructionLabel.center.x = overLayBarViewforInstruction.center.x
        instructionLabel.textAlignment = .center
        instructionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        instructionLabel.numberOfLines = 4
        instructionLabel.textColor = UIColor.white
        instructionLabel.font = UIFont(name: "Roboto-Regular", size: 16)
        self.overLayBarViewforInstruction.addSubview(instructionLabel)
        
        overLayBarViewforInstruction.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.view.addSubview(overLayBarViewforInstruction)
        
        countDownLabel.center.x = self.view.center.x
        countDownLabel.textAlignment = .center
        countDownLabel.text = String(maxDuartionofFaceScan)
        countDownLabel.font = UIFont(name: "Roboto-Regular", size: 20)
        countDownLabel.isHidden = true
        countDownLabel.textColor = UIColor.white
        self.view.addSubview(countDownLabel)
    }
    
    func normalButtonToStartAndStopRecording()
    {
        let normalImage = UIImage(named: "recordingButton", in: Bundle(for: type(of: self)), compatibleWith: nil)
        if(deviceSize() == "X" || deviceSize() == "Xr")
        {
             overlayBarViewforButton = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 130, width: self.view.frame.width, height: 100))
            recordAndStopButton = UIButton(frame: CGRect(x: 0,y: overlayBarViewforButton.frame.origin.y ,width: 50,height: 50))
        }
        else{
            overlayBarViewforButton = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 120, width: self.view.frame.width, height: 100))

            recordAndStopButton = UIButton(frame: CGRect(x: 0,y: self.view.frame.height - 68 ,width: 50,height: 50))
        }
        recordAndStopButton.setImage(normalImage, for: .normal)
        recordAndStopButton.center.x = self.overlayBarViewforButton.center.x
        recordAndStopButton.center.y = self.overlayBarViewforButton.center.y
        
        recordAndStopButton.addTarget(self, action: #selector(RoomScanNewVC.cameraButtonAction), for: UIControl.Event.touchUpInside)
        
        overlayBarViewforButton.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
      
        self.view?.addSubview(overlayBarViewforButton)
        self.view?.addSubview(recordAndStopButton)
        addTimerlabelToView()
    }
   
    //convert time in to the String format
    func timeStringForMinAndSec(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    @objc func roomScanTimerHandling() {
        roomScanCount -= 1
        if(timerLabel.text == "00:00")
        {
            overlayBarViewforButton.isHidden = true
            timerLabel.isHidden = true
            self.roomScanTimer.invalidate()
            self.dotLabel.stopBlink()
            dotLabel.isHidden = true
            roomScanCount = 20
            if(navigationBarTitle.text != roomScanOverlayTitle)
            {
                loadOverlayWithCustomNextButtonForDeskScan()
            }
            if(kibanaLogEnable == true)
            {
                NetworkingClass.submitKibanaLogApiCallFromNative(message: "Room Scan Timer Completed", level: kibanaLevelName)
            }
        }else
        {
            timerLabel.text = timeStringForMinAndSec(time: TimeInterval(roomScanCount))
        }
    }
    
    @objc func deskScanTimerHandling() {
        deskScanCount -= 1
        if(timerLabel.text == "00:00")
        {
            self.deskScanTimer.invalidate()
            deskScanCount = 10
            self.dotLabel.stopBlink()
            if(kibanaLogEnable == true)
            {
                NetworkingClass.submitKibanaLogApiCallFromNative(message: "Desk Scan Timer Completed", level: kibanaLevelName)
            }
            
            if(liveRoomScanRequired)
            {
                if(kibanaLogEnable == true)
                {
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: "Online: Navigating to Room scan approval screen", level: kibanaLevelName)
                }
                self.moveToLockScreen()
            }
            else
            {
                if(kibanaLogEnable == true)
                {
                    NetworkingClass.submitKibanaLogApiCallFromNative(message: "Offline: Navigating to MovieOutput delegate method", level: kibanaLevelName)
                }
                self.movieOutput.stopRecording()
            }
        }else
        {
            timerLabel.text = timeStringForMinAndSec(time: TimeInterval(deskScanCount))
        }
    }
   
    func loadOverlayWithCustomNextButtonForDeskScan()
    {
        //overlay add to the over view
        overLayBarViewforInstruction.isHidden = true
        instructionLabel.text = instructionTextForDeskScan
        navigationBarTitle.text = "Step 2: Record Desk Area"
        if(deviceSize() == "X" || deviceSize() == "Xr")
        {
            if let height = self.navigationController?.navigationBar.frame.size.height {
                overlayViewforDesk = UIView(frame: CGRect(x: 0, y: height + 45, width: self.view.frame.width, height: self.view.frame.height/2))
                
                intrctionForStep = UILabel(frame: CGRect(x: 0, y:overlayViewforDesk.frame.origin.y - 85, width: self.view.frame.width - 20, height: 30))
                
                instructionForOverLay = UILabel(frame: CGRect(x: 0, y:overlayViewforDesk.frame.origin.y + intrctionForStep.frame.height - 85, width: self.view.frame.width - 20, height: 60))
                
                overlayInstructionImage = UIImageView(frame: CGRect(x: 0, y:overlayViewforDesk.frame.origin.y + instructionForOverLay.frame.height + intrctionForStep.frame.height - 85, width: self.view.frame.width - 60, height: overlayViewforDesk.frame.height/2))
            }
        }
        else
        {
            if let height = self.navigationController?.navigationBar.frame.size.height {
                overlayViewforDesk = UIView(frame: CGRect(x: 0, y: height + 20, width: self.view.frame.width, height: self.view.frame.height/2))
                intrctionForStep = UILabel(frame: CGRect(x: 0, y:overlayViewforDesk.frame.origin.y - 65, width: self.view.frame.width - 20, height: 30))
                instructionForOverLay = UILabel(frame: CGRect(x: 0, y:overlayViewforDesk.frame.origin.y + intrctionForStep.frame.height - 65, width: self.view.frame.width - 20, height: 60))
                
                
                overlayInstructionImage = UIImageView(frame: CGRect(x: 0, y:overlayViewforDesk.frame.origin.y + instructionForOverLay.frame.height + intrctionForStep.frame.height - 65, width: self.view.frame.width - 60, height: overlayViewforDesk.frame.height/2))
            }
        }
        
        overlayInstructionImage.image = UIImage(named: "NewDeskScanImage", in: Bundle(for: type(of: self)), compatibleWith: nil)
        
        overlayInstructionImage.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        overlayInstructionImage.contentMode = .scaleAspectFill // OR .scaleAspectFill
        overlayInstructionImage.clipsToBounds = true
        overlayInstructionImage.layer.borderWidth = 2
        overlayInstructionImage.layer.borderColor = appThemeColorCode.cgColor
        overlayInstructionImage.center.x = overlayViewforDesk.center.x
        
           let  nextButtonForOverlay = UIButton(frame: CGRect(x: overlayViewforDesk.frame.width - 120,y: overlayViewforDesk.frame.height - 50 ,width: 100,height: 40))

        nextButtonForOverlay.setTitle("Next", for: .normal)

        nextButtonForOverlay.addTarget(self, action: #selector(RoomScanNewVC.overlaynextButtonAction), for: UIControl.Event.touchUpInside)
       
        intrctionForStep.text = "STEP : 2"
        intrctionForStep.center.x = overlayViewforDesk.center.x
        intrctionForStep.textColor = UIColor.white
        intrctionForStep.textAlignment = .center
        intrctionForStep.font = UIFont(name: "Roboto-Regular", size: 16)
        
        
        instructionForOverLay.text = instructionTextForDeskScan
        instructionForOverLay.center.x = overlayViewforDesk.center.x
//        instructionForOverLay.center.y = overlayViewforDesk.center.y
        instructionForOverLay.textAlignment = .center
        instructionForOverLay.lineBreakMode = NSLineBreakMode.byWordWrapping
        instructionForOverLay.numberOfLines = 3
        instructionForOverLay.textColor = UIColor.white
        instructionForOverLay.textAlignment = .center
        instructionForOverLay.font = UIFont(name: "Roboto-Regular", size: 16)
      
        nextButtonForOverlay.backgroundColor = textColorCode
        nextButtonForOverlay.layer.cornerRadius = 5
        overlayViewforDesk.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.overlayViewforDesk?.addSubview(nextButtonForOverlay)
        self.overlayViewforDesk?.addSubview(instructionForOverLay)
        self.overlayViewforDesk?.addSubview(intrctionForStep)
        self.overlayViewforDesk?.addSubview(overlayInstructionImage)
        self.view?.addSubview(overlayViewforDesk)
    }
    
    //custom button action method
    @objc func overlaynextButtonAction()
    {
        self.roomScanTimer.invalidate()
        self.overlayViewforDesk.removeFromSuperview()
        self.overLayBarViewforInstruction.isHidden = false
        timerLabel.isHidden = false
        
        dotLabel.frame = CGRect(x:navigationBarTitle.intrinsicContentSize.width + 5 , y: -navigationBarTitle.intrinsicContentSize.height/2 , width: 40, height: 40)
        dotLabel.isHidden = false
        overlayBarViewforButton.isHidden = false
        
        deskScanTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.deskScanTimerHandling), userInfo: nil, repeats: true)
        //  timerLabel.text = "00:01"
        timerLabel.text = timeStringForMinAndSec(time: TimeInterval(deskScanCount))
        self.dotLabel.blink()
    }
    
    func addTimerlabelToView()
    {
        timerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: overlayBarViewforButton.frame.width, height: 30))
        timerLabel.center.x = overlayBarViewforButton.center.x
        timerLabel.center.y = overlayBarViewforButton.center.y
        timerLabel.textColor = UIColor.white
        timerLabel.textAlignment = .center
        self.view?.addSubview(timerLabel)
        timerLabel.isHidden = true
    }
    
    func updateTimerAndTimerLabelText() {
        self.roomScanTimer.invalidate()
        self.deskScanTimer.invalidate()
        self.timerLabel.isHidden = true
        self.recordAndStopButton.isHidden = false
        self.roomScanCount = 20
        self.deskScanCount = 10
        self.removeCustomViewFromParentView()
        self.instructionLabel.text = instructionTextFor360RoomScan
        self.overLayBarViewforInstruction.isHidden = false
        self.navigationBarAddMethod()
    }
    
    //custom button action method
    @objc func cameraButtonAction()
    {
        self.recordAndStopButton.isHidden = true
        self.timerLabel.isHidden = false
        self.dotLabel.isHidden = false
        if(!liveRoomScanRequired)
        {
            self.takeVideo = true
            self.dotLabel.blink()
            self.timerLabel.text = timeStringForMinAndSec(time: TimeInterval(roomScanCount))
            self.roomScanTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.roomScanTimerHandling), userInfo: nil, repeats: true)
            
            if(kibanaLogEnable == true){
                let finalMessage = kibanaPrefix + "event: Offline_roomscan" + seprator + "camera record button selected"
                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
            }
            
            if let pathUrl = self.tempFilePath {
                movieOutput.startRecording(to: pathUrl, recordingDelegate: self)
            }
        }
        else {
            is_stream_auto_renaming_enabled = UserDefaults.standard.bool(forKey: streamAutoRenamingKey)
            if (is_stream_auto_renaming_enabled) {
                if (streamIdExtensionForRoomScan > 0) {
                    let newStreamId = liveRoomScaningStreamID + "_" + "\(streamIdExtensionForRoomScan)"
                    self.getCurrentRoomScanToken(streamName: newStreamId)
                }
                else {
                    guard let documentID = UserDefaults.standard.string(forKey: testsession_uuid) else {return}
                    FirestoreDB.shared.getStreamIdForRoomScan(documentID: documentID) {[weak self] (success, docSnapshot) in
                        if let this = self {
                            if (success) {
                                if (docSnapshot.count > 0) {
                                    if let lastStreamId = docSnapshot.last {
                                        let streamId = lastStreamId.components(separatedBy: "_roomscan_mobile")
                                        if let last = streamId.last, last.count > 0 {
                                            let finalStreamIdExtension = last.replacingOccurrences(of: "_", with: "")
                                            streamIdExtensionForRoomScan = (finalStreamIdExtension as NSString).integerValue
                                        }
                                        this.getCurrentRoomScanToken(streamName: lastStreamId)
                                    }
                                }
                                else {
                                    this.getCurrentRoomScanToken(streamName: liveRoomScaningStreamID)
                                }
                                
                                if(kibanaLogEnable == true){
                                    let finalMessage = kibanaPrefix + "event: Live_roomscan" + seprator + "type: Get data success \(docSnapshot)"
                                    NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                                }
                            }
                            else {
                                // To start stream with default stream id
                                this.getCurrentRoomScanToken(streamName: liveRoomScaningStreamID)
                                
                                if(kibanaLogEnable == true){
                                    let finalMessage = kibanaPrefix + "event: Live_roomscan" + seprator + "type: Get data: \(docSnapshot) | stream started with default stream id"
                                    NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                                }
                            }
                        }
                    }
                }
            }
            else {
                self.getCurrentRoomScanToken(streamName: liveRoomScaningStreamID)
            }
            self.timerLabel.text = "connecting..."
        }
    }
    
    private func getCurrentRoomScanToken(streamName: String) {
        NetworkingClass.getRoomScanStreamTokenId(streamName: streamName) {[weak self] (success) in
            if let this = self {
                if success {
                    this.client.setOptions(url: liveStreamBaseUrl, streamId: streamName, token: roomScanTokenID, mode: .publish)
                    this.client.start()
                }
                else {
                    let alertController = UIAlertController(title: proctorTrackTitle, message: "Server error, please try again", preferredStyle: .alert)
                    let action1 = UIAlertAction(title: reTryTitle, style: .default) { (action) in
                        this.getCurrentRoomScanToken(streamName: streamName)
                    }
                    alertController.addAction(action1)
                    this.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    //Load recording functions
    func loadRecordingMethod()
    {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSession.Preset.cif352x288
        
        if captureSession.inputs.isEmpty
        {
            if let cameraDevice = deviceInputFromDevice(device: frontCameraDevice) {
                if captureSession.canAddInput(cameraDevice) {
                    captureSession.addInput(cameraDevice)
                }
            }
            if let micDevice = deviceInputFromDevice(device: micDevice) {
                if captureSession.canAddInput(micDevice) {
                    captureSession.addInput(micDevice)
                }
            }
        }
        else
        {
            if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                for input in inputs {
                    captureSession.removeInput(input)
                    captureSession.removeOutput(movieOutput)
                    if captureSession.inputs.isEmpty
                    {
                        if let cameraDevice = deviceInputFromDevice(device: frontCameraDevice) {
                            if captureSession.canAddInput(cameraDevice) {
                                captureSession.addInput(cameraDevice)
                            }
                        }
                        if let micDevice = deviceInputFromDevice(device: micDevice) {
                            if captureSession.canAddInput(micDevice) {
                                captureSession.addInput(micDevice)
                            }
                        }
                    }
                }
            }
        }
        
        movieOutput.movieFragmentInterval = CMTime.invalid
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        if (changeVideoCodecFormat ==  true) {
            if let movieFileOutputConnection = movieOutput.connection(with: .video) {
                if #available(iOS 11.0, *) {
                    let availableVideoCodecTypes = movieOutput.availableVideoCodecTypes
                    if availableVideoCodecTypes.contains(.hevc) {
                        movieOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.h264], for: movieFileOutputConnection)
                    }
                }
            }
        }
        
        if let previewView = self.cameraView {
            self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            self.previewLayer?.frame = (previewView.layer.frame)
            if let previewLayer = self.previewLayer {
                self.cameraView?.layer.addSublayer(previewLayer)
            }
        }
        
        self.captureSession.commitConfiguration()
        self.captureSession.startRunning()
    }
    
    //Private device input and output access method
    private func deviceInputFromDevice(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let validDevice = device else { return nil }
        do {
            var input = try AVCaptureDeviceInput(device: validDevice)
            input = deviceInputSettingConfiguration(input: input)
            return input
        } catch let outError {
            print("Device setup error occured \(outError)")
            return nil
        }
    }
    
    //delegate method for video recording
    //Start Video recording
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!)
    {
        print("Start Recording")
    }

    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let err = error {
            if(kibanaLogEnable == true){
                let finalMessage = kibanaPrefix + "event: Offline_roomscan" + seprator + "\(err.localizedDescription)"
                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
            }
        }
        else {
            if (self.takeVideo)
            {
                self.takeVideo = false
                let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = outputFileURL
                
                let existingFileURL = (getDirectoryPath() as NSString).appendingPathComponent(roomScanVideoName + "." + videoExtension)
                
                if !FileManager.default.fileExists(atPath: existingFileURL) {
                    do {
                        try FileManager.default.moveItem(at: fileURL, to: documentsDirectoryURL.appendingPathComponent(roomScanVideoName).appendingPathExtension(videoExtension))
                        chunkCount = chunkCount + 1
                        
                        if(kibanaLogEnable == true){
                            let finalMessage = kibanaPrefix + "event: Offline_roomscan" + seprator + "type: Room scan saved successfully in new file location"
                            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.performSegue(withIdentifier: roomScanResultSegue, sender: self)
                        }
                    }
                    catch {
                        if(kibanaLogEnable == true){
                            let finalMessage = kibanaPrefix + "event: Offline_roomscan" + seprator + "type: Room scan saved error in new file location \(error.localizedDescription)"
                            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                        }
                    }
                }
                else
                {
                    chunkCount = chunkCount - 1
                    removeImageAndVideo(itemName:(getDirectoryPath() as NSString).appendingPathComponent(roomScanVideoName), fileExtension: videoExtension)
                    do {
                        try FileManager.default.moveItem(at: fileURL, to: documentsDirectoryURL.appendingPathComponent(roomScanVideoName).appendingPathExtension(videoExtension))
                        chunkCount = chunkCount + 1
                        
                        if(kibanaLogEnable == true){
                            let finalMessage = kibanaPrefix + "event: Offline_roomscan" + seprator + "type: Room scan saved successfully in existing file location"
                            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.performSegue(withIdentifier: roomScanResultSegue, sender: self)
                        }
                    }
                    catch {
                        if(kibanaLogEnable == true){
                            let finalMessage = kibanaPrefix + "event: Offline_roomscan" + seprator + "type: Room scan saved error in existing file location \(error.localizedDescription)"
                            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                        }
                    }
                }
            }
        }
    }
}

extension RoomScanNewVC: AntMediaClientDelegate {
    
    func localStreamStarted(streamId: String) {
        if(kibanaLogEnable == true){
            let finalMessage = kibanaPrefix + "event: Live_roomscan" + seprator + "type: localStreamStarted"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    func clientDidConnect(_ client: AntMediaClient) {
        if(kibanaLogEnable == true){
            let finalMessage = kibanaPrefix + "event: Live_roomscan" + seprator + "type: clientDidConnect on \(client.getWsUrl())"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    func clientDidDisconnect(_ message: String) {
        self.dotLabel.stopBlink()
        if (!self.isViewWillDisappear) {
            self.client.initPeerConnection()
            self.updateTimerAndTimerLabelText()
            
            if(kibanaLogEnable == true){
                let finalMessage = kibanaPrefix + "event: Live_roomscan" + seprator + "type: clientDidDisconnect \(message)"
                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
            }
        }
    }
    
    func disconnected(streamId: String) {
        if(kibanaLogEnable == true){
            let finalMessage = kibanaPrefix + "event: Live_Roomscan" + seprator + "type: disconnected for \(streamId)"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    func clientHasError(_ message: String) {
        self.dotLabel.stopBlink()
        self.client.stop()
        
        if message.contains("streamIdInUse") {
            is_stream_auto_renaming_enabled = UserDefaults.standard.bool(forKey: streamAutoRenamingKey)
            if (is_stream_auto_renaming_enabled) {
                streamIdExtensionForRoomScan = streamIdExtensionForRoomScan + 1
            }
        }
        
        if(kibanaLogEnable == true){
            let finalMessage = kibanaPrefix + "event: Live_Roomscan" + seprator + "type: clientHasError \(message)"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    func publishStarted(streamId: String) {
        self.dotLabel.blink()
        self.timerLabel.text = self.timeStringForMinAndSec(time: TimeInterval(self.roomScanCount))
        self.roomScanTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.roomScanTimerHandling), userInfo: nil, repeats: true)
        
        is_stream_auto_renaming_enabled = UserDefaults.standard.bool(forKey: streamAutoRenamingKey)
        if (is_stream_auto_renaming_enabled) {
            guard let documentID = UserDefaults.standard.string(forKey: testsession_uuid) else {return}
            FirestoreDB.shared.updateStreamIDForRoomScan(documentID: documentID, streamID: streamId) {[weak self] (message) in
                if self != nil {
                    if(kibanaLogEnable == true){
                        let finalMessage = kibanaPrefix + "event: Live_roomscan" + seprator + "type: publishStarted | \(message)"
                        NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                    }
                }
            }
        }
        else {
            if(kibanaLogEnable == true){
                let finalMessage = kibanaPrefix + "event: Live_roomscan" + seprator + "type: publishStarted with \(streamId)"
                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
            }
        }
    }
    
    func remoteStreamStarted(streamId: String) {
    }
    
    func remoteStreamRemoved(streamId: String) {
    }
    
    func playStarted(streamId: String) {
    }
    
    func playFinished(streamId: String) {
    }
    
    func publishFinished(streamId: String) {
    }
    
    func audioSessionDidStartPlayOrRecord(streamId: String) {
    }
    
    func dataReceivedFromDataChannel(streamId: String, data: Data, binary: Bool) {
    }
    
    func streamInformation(streamInfo: [StreamInformation]) {
    }
}

extension UILabel {
    func blink() {
        UIView.animate(withDuration: 1.0,
                       delay:0.0,
                       options:[.autoreverse, .repeat],
                       animations: {
                        self.alpha = 0
        }, completion: nil)
    }
    func stopBlink() {
        alpha = 1
        layer.removeAllAnimations()
    }
}

