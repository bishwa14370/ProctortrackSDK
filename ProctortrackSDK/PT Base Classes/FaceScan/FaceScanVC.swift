//
//  FaceScanVC.swift
//  ProctorTrack
//
//  Created by Diwakar Garg on 28/01/2019.
//  Copyright © 2019 Diwakar Garg. All rights reserved.
//

import UIKit
import AVFoundation

@available(iOS 9.0, *)
class FaceScanVC: UIViewController,AVCaptureFileOutputRecordingDelegate,FaceScanOverlayDelegate,AVCaptureMetadataOutputObjectsDelegate {
    
    var navigationBarTitle : UILabel?
    var cameraView: UIView?
    //Camera operation variable
    let captureSession = AVCaptureSession()
    var previewLayer:AVCaptureVideoPreviewLayer?
    var longPressBeginTime: TimeInterval = 0.0
    var overLayImageView: UIImageView!
    //Record Button related variables
 //   var recordButtonBase : UIButton!
    var faceScanRecordingButton: UIButton!
 //   var button  : UIButton!
    var progressTimer : Timer!
    var progress : CGFloat! = 1
    //Custom Label
    var countDownLabel : UILabel!
    var instructionLabel : UILabel!
    var takeVideo = false
    var maxDuartionofFaceScan : Int =  10
    var snapShotCounter: Int = 0
    var reScanCounter : Int = 0
    var detectionCounter: Int = 0
    
    //Add loader
    var loadingView : LoadingView!
    
    //front camera accessing function
    lazy var frontCameraDevice: AVCaptureDevice? = {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        for device in deviceDiscoverySession.devices {
            if device.position == .front {
                return device
            }
        }
        return nil
    }()
    
    
    var movieOutput = AVCaptureMovieFileOutput()
    var metadataOutput = AVCaptureMetadataOutput()
    
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:facescan_start"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    //View did Appear function
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        //Add observer for foreground
        NotificationCenter.default.addObserver(self, selector: #selector(appForegroundStateFunction), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appBackgroundStateFunction), name: UIApplication.didEnterBackgroundNotification, object: nil)
        self.viewStyleMethod()
        
        self.navigationBarAddMethod()
        self.startMetaSession()
        
        self.overLayView()
        takeVideo = false
        
        //ScreenrecordingHandling
        if(screenRecordingStopEnable)
        {
            addObserverForScreenRecording()
        }
    }
    
    //View did Appear function
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        instructionLabel.attributedText = textColorChange(text: "BLUE")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:facescan_end"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func appBackgroundStateFunction()
    {
        isFaceRecordingStart = false
        self.captureSession.removeOutput(self.metadataOutput)
        self.stopTimer()
        self.detectionCounter = 0
    }
    
    @objc func appForegroundStateFunction()
    {
        isFaceRecordingStart = false
        
        if(deviceSize() == "X" || deviceSize() == "Xr")
        {
            overLayImageView.image = UIImage(named: "DefaultFaceScanOverlayX", in: Bundle(for: type(of: self)), compatibleWith: nil)
        }
        else if(deviceSize() == "iPad 9.7")
        {
            overLayImageView.image = UIImage(named: "defaultFaceOverlay9.7", in: Bundle(for: type(of: self)), compatibleWith: nil)
        }
        else if(deviceSize() == "iPad 10.2")
        {
            overLayImageView.image = UIImage(named: "defaultFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
        }
        else if(deviceSize() == "iPad 10.5")
        {
            overLayImageView.image = UIImage(named: "defaultFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
        }
        else if(deviceSize() == "iPad 11")
        {
            overLayImageView.image = UIImage(named: "defaultFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
        }
        else if(deviceSize() == "iPad 12.9")
        {
            overLayImageView.image = UIImage(named: "defaultFaceOverlay12.9", in: Bundle(for: type(of: self)), compatibleWith: nil)
        }
        else
        {
            overLayImageView.image = UIImage(named: "DefaultFaceScanOverlay", in: Bundle(for: type(of: self)), compatibleWith: nil)
        }
        
        if isFaceScanTimeEnd {
            instructionLabel.text = instructionForFaceScanWithButton
        }
        else {
            instructionLabel.text = instructionTextForRTFV
        }
        
        instructionLabel.attributedText = textColorChange(text: "BLUE")
        countDownLabel.isHidden = true
        
        progress = 1
        self.startMetaSession()
    }
    
    //Custom View style Function
    fileprivate func viewStyleMethod ()
    {
        cameraView = UIView(frame: CGRect(x: self.view.frame.origin.x ,y:self.view.frame.origin.y  ,width: self.view.frame.width ,height: self.view.frame.height ))
        self.view.addSubview(cameraView!)
        
        overLayImageView  = UIImageView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height))
        if(deviceSize() == "X" || deviceSize() == "Xr")
        {
            overLayImageView.image = UIImage(named: "DefaultFaceScanOverlayX", in: Bundle(for: type(of: self)), compatibleWith: nil)
        }
        else if(deviceSize() == "iPad 9.7")
        {
            overLayImageView.image = UIImage(named: "defaultFaceOverlay9.7", in: Bundle(for: type(of: self)), compatibleWith: nil)
        }
        else if(deviceSize() == "iPad 10.2")
        {
            overLayImageView.image = UIImage(named: "defaultFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
        }
        else if(deviceSize() == "iPad 10.5")
        {
            overLayImageView.image = UIImage(named: "defaultFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
        }
        else if(deviceSize() == "iPad 11")
        {
            overLayImageView.image = UIImage(named: "defaultFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
        }
        else if(deviceSize() == "iPad 12.9")
        {
            overLayImageView.image = UIImage(named: "defaultFaceOverlay12.9", in: Bundle(for: type(of: self)), compatibleWith: nil)
        }
        else
        {
            overLayImageView.image = UIImage(named: "DefaultFaceScanOverlay", in: Bundle(for: type(of: self)), compatibleWith: nil)
        }
        
        overLayImageView.isUserInteractionEnabled = true
        self.view.addSubview(overLayImageView)
        
        // setup Face Scan Recording button
        self.setupFaceScanRecordingButton()
        
        if(deviceSize() == "X" || deviceSize() == "Xr")
        {
            instructionLabel = UILabel(frame: CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.size.height)! + 60, width: self.view.frame.width - 20, height: 90))
            
            countDownLabel = UILabel(frame: CGRect(x: 0, y:instructionLabel.frame.origin.y + 60, width: 100 , height: 30))
        }
        else
        {
            instructionLabel = UILabel(frame: CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.size.height)! + 25, width: self.view.frame.width - 20, height: 90))
            
            countDownLabel = UILabel(frame: CGRect(x: 0, y:instructionLabel.frame.origin.y + 50, width: 100 , height: 30))
        }
        instructionLabel.center.x = self.view.center.x
        instructionLabel.textAlignment = .center
        instructionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        instructionLabel.numberOfLines = 4
        instructionLabel.text = instructionTextForRTFV
        instructionLabel.textColor = UIColor.white
        instructionLabel.font = UIFont(name: "Roboto-Regular", size: 16)
        self.overLayImageView.addSubview(instructionLabel)
        countDownLabel.center.x = self.view.center.x
        countDownLabel.textAlignment = .center
        countDownLabel.text = "3"
        countDownLabel.font = UIFont(name: "Roboto-Regular", size: 16)
        countDownLabel.isHidden = true
        countDownLabel.textColor = UIColor.white
        self.overLayImageView.addSubview(countDownLabel)
    }
    
    private func setupFaceScanRecordingButton() {
        if(deviceSize() == "X" || deviceSize() == "Xr")
        {
            faceScanRecordingButton = UIButton(frame: CGRect(x: 0,y: self.view.frame.height - 115 ,width: 70,height: 70))
        }
        else
        {
            faceScanRecordingButton = UIButton(frame: CGRect(x: 0,y: self.view.frame.height - 95 ,width: 70,height: 70))
        }
        faceScanRecordingButton.layer.cornerRadius = self.faceScanRecordingButton.frame.height/2
        faceScanRecordingButton.layer.borderColor = UIColor.red.cgColor
        faceScanRecordingButton.layer.borderWidth = 2
        faceScanRecordingButton.layer.backgroundColor = UIColor(red:0.39, green:0.97, blue:1.00, alpha:0.2).cgColor
        faceScanRecordingButton.center.x = self.view.center.x
        faceScanRecordingButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        faceScanRecordingButton.addTarget(self, action: #selector(didSelectFaceScanRecording), for: .touchUpInside)
        self.overLayImageView.addSubview(faceScanRecordingButton)
        faceScanRecordingButton.isHidden = true
        
        if let status = UserDefaults.standard.object(forKey:"faceScanChcekBoxStatus") as? Bool, status == true {
            self.setupTimerForFaceScanButton()
        }
    }
    
    private func setupTimerForFaceScanButton() {
        weak var wSelf = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            if let this = wSelf {
                if !isFaceRecordingStart {
                    this.faceScanRecordingButton.isHidden = false
                    self.instructionLabel.text = instructionForFaceScanWithButton
                    isFaceScanTimeEnd = true
                }
            }
        }
    }
    
    @objc func didSelectFaceScanRecording() {
        self.faceScanButtonAction()
    }
    
    private func faceScanButtonAction() {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.captureSession.removeOutput(self.metadataOutput)
            self.startTimer()
        })
    }
    
    //Text color change to attributed string
    func textColorChange(text: String) -> NSMutableAttributedString
    {
        let string_to_color = text
        let convertInstructionLabelToString = instructionLabel.text! as NSString
        let range = convertInstructionLabelToString.range(of: string_to_color)
        
        let attributedString = NSMutableAttributedString(string:instructionLabel.text!)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: lightGreenColor , range: range)
        
        return attributedString
    }
    
    //Update the progress bar of the button
    @objc func updateProgress() {
        
        if (changeVideoCodecFormat ==  true) {
            if let movieFileOutputConnection = movieOutput.connection(with: .video) {
                let availableVideoCodecTypes = movieOutput.availableVideoCodecTypes
                if availableVideoCodecTypes.contains(.hevc) {
                    movieOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.h264], for: movieFileOutputConnection)
                }
            }
        }
        if let pathUrl = self.tempFilePath {
            movieOutput.startRecording(to: pathUrl, recordingDelegate: self)
        }
        
        let maxDuration = CGFloat(maxDuartionofFaceScan)
        
        progress = progress - (CGFloat(0.1) / maxDuration)
        countDownLabel.isHidden = false
        isFaceRecordingStart = true
        if (progress <= 0.33)
        {
            if(deviceSize() == "X" || deviceSize() == "Xr")
            {
                overLayImageView.image = UIImage(named: "LeftFaceOverlayX", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 9.7")
            {
                overLayImageView.image = UIImage(named: "leftFaceOverlay9.7", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 10.2")
            {
                overLayImageView.image = UIImage(named: "leftFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 10.5")
            {
                overLayImageView.image = UIImage(named: "leftFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 11")
            {
                overLayImageView.image = UIImage(named: "leftFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 12.9")
            {
                overLayImageView.image = UIImage(named: "leftFaceOverlay12.9", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else
            {
                overLayImageView.image = UIImage(named: "LeftFaceOverlay", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            
            instructionLabel.text = "FACE LEFT"
            instructionLabel.attributedText = textColorChange(text: "LEFT")
            if(progress <= 0.11)
            {
                countDownLabel.text = "1"
            }
            else if(progress <= 0.22)
            {
                countDownLabel.text = "2"
            }
            else
            {
                countDownLabel.text = "3"
            }
            
        }
        else if(progress <= 0.66)
        {
            if(deviceSize() == "X" || deviceSize() == "Xr")
            {
                overLayImageView.image = UIImage(named: "RightFaceOverlayX", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 9.7")
            {
                overLayImageView.image = UIImage(named: "rightFaceOverlay9.7", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 10.2")
            {
                overLayImageView.image = UIImage(named: "rightFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 10.5")
            {
                overLayImageView.image = UIImage(named: "rightFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 11")
            {
                overLayImageView.image = UIImage(named: "rightFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 12.9")
            {
                overLayImageView.image = UIImage(named: "rightFaceOverlay12.9", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else
            {
                overLayImageView.image = UIImage(named: "RightFaceOverlay", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            instructionLabel.text = "FACE RIGHT"
            instructionLabel.attributedText = textColorChange(text: "RIGHT")
            if(progress <= 0.44)
            {
                countDownLabel.text = "1"
            }
            else if(progress <= 0.55)
            {
                countDownLabel.text = "2"
            }
            else
            {
                countDownLabel.text = "3"
            }
        }
        else if(progress <= 0.99){
            if(deviceSize() == "X" || deviceSize() == "Xr")
            {
                overLayImageView.image = UIImage(named: "FullFaceOverlayX", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 9.7")
            {
                overLayImageView.image = UIImage(named: "FullFaceOverlay9.7", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 10.2")
            {
                overLayImageView.image = UIImage(named: "fullFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 10.5")
            {
                overLayImageView.image = UIImage(named: "fullFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 11")
            {
                overLayImageView.image = UIImage(named: "fullFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 12.9")
            {
                overLayImageView.image = UIImage(named: "fullFaceOverlay12.9", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else
            {
                overLayImageView.image = UIImage(named: "FullFaceOverlay", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            instructionLabel.text = "FACE FORWARD"
            instructionLabel.attributedText = textColorChange(text: "FORWARD")
            
            if(progress <= 0.77)
            {
                countDownLabel.text = "1"
            }
            else if(progress <= 0.88)
            {
                countDownLabel.text = "2"
            }
            else
            {
                countDownLabel.text = "3"
            }
        }
        if progress <= 0 {
            if(realTimeFaceVerification)
            {
                if(!isOnBoarding)
                {
                   overLayImageView.isHidden = true
                }
            }
            takeVideo = true
            progress = 1
            if(deviceSize() == "X" || deviceSize() == "Xr")
            {
                overLayImageView.image = UIImage(named: "DefaultFaceScanOverlayX", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 9.7")
            {
                overLayImageView.image = UIImage(named: "defaultFaceOverlay9.7", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 10.2")
            {
                overLayImageView.image = UIImage(named: "defaultFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 10.5")
            {
                overLayImageView.image = UIImage(named: "defaultFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 11")
            {
                overLayImageView.image = UIImage(named: "defaultFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else if(deviceSize() == "iPad 12.9")
            {
                overLayImageView.image = UIImage(named: "defaultFaceOverlay12.9", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            else
            {
                overLayImageView.image = UIImage(named: "DefaultFaceScanOverlay", in: Bundle(for: type(of: self)), compatibleWith: nil)
            }
            instructionLabel.text = instructionTextForRTFV
            instructionLabel.attributedText = textColorChange(text: "BLUE")
            countDownLabel.isHidden = true
            self.stopTimer()
            self.movieOutput.stopRecording()
        }
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
        navigationBarTitle = UILabel(frame: CGRect(x: 0, y: 0.0, width: customView.frame.width , height: customView.frame.height))
        navigationBarTitle?.text = faceScanTitle
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
        captureOutput.maxRecordedDuration = CMTimeMake(value: Int64(maxDuartionofFaceScan), timescale: 0)
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (takeVideo)
        {
            takeVideo = false
            snapShotCounter =  0
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL =  outputFileURL
            
            let existingFileURL =  (getDirectoryPath() as NSString).appendingPathComponent(faceScanVideoName + "." + videoExtension)
            
            if !FileManager.default.fileExists(atPath: existingFileURL) {
                do {
                    try  FileManager.default.moveItem(at: fileURL, to: documentsDirectoryURL.appendingPathComponent(faceScanVideoName).appendingPathExtension(videoExtension))
                        print("Face Scan saved")
                    chunkCount = chunkCount + 1
                        //Navigate to face scan result screen
                        performSegue(withIdentifier: faceScanResultSegue, sender: self)
                } catch {
                    print(error)
                }
            }
            else
            {
                 chunkCount = chunkCount - 1
                removeImageAndVideo(itemName:(getDirectoryPath() as NSString).appendingPathComponent(faceScanVideoName), fileExtension: videoExtension)
                do {
                    try  FileManager.default.moveItem(at: fileURL, to: documentsDirectoryURL.appendingPathComponent(faceScanVideoName).appendingPathExtension(videoExtension))
                        print("Face Scan saved")
                        chunkCount = chunkCount + 1
                        //Navigate to face scan result screen
                        performSegue(withIdentifier: faceScanResultSegue, sender: self)
                } catch {
                    print(error)
                }
                
            }
            isFaceRecordingStart = false
            isFaceScanTimeEnd = false
        }
    }
 
    //    FaceScanOverLayDelegateMethodImplementation for changing the navigation bar title
    func setNavigationBarLabel(text:String) {
        self.navigationBarTitle?.text = text
        if text == faceScanTitle {
            self.setupTimerForFaceScanButton()
        }
    }
    
    //Custom function to call the pop up screen
    func overLayView()
    {
        let bottomSheetVC = storyboard?.instantiateViewController(withIdentifier: faceScanOverlay) as! FaceScanOverlayVC
        bottomSheetVC.delegate = self
        bottomSheetVC.didMove(toParent: self)
        let height = view.frame.height
        let width  = view.frame.width
        //  print("Value of Object : ",(UserDefaults.standard.object(forKey:"faceScanChcekBoxStatus"))!)
        if((UserDefaults.standard.object(forKey:"faceScanChcekBoxStatus")) != nil)
        {
            if (deviceSize() == "X" || deviceSize() == "Xr") {
                bottomSheetVC.view.frame = CGRect(x: 0, y: height - 20, width: width, height: height - 85)
            }
            else{
                bottomSheetVC.view.frame = CGRect(x: 0, y: height - 20, width: width, height: height - 65)
            }
        }
        else
        {
            if (deviceSize() == "X" || deviceSize() == "Xr") {
                bottomSheetVC.view.frame = CGRect(x: 0, y: 85, width: width, height: height - 85)
                setNavigationBarLabel(text:faceScanOverlayTitle)
                
            }
            else{
                bottomSheetVC.view.frame = CGRect(x: 0, y: 65, width: width, height: height - 65)
                setNavigationBarLabel(text:faceScanOverlayTitle)
            }
            
        }
        self.view.addSubview(bottomSheetVC.view)
        self.addChild(bottomSheetVC)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate let sessionQueue = DispatchQueue(
        label: "facescanMetaData",
        qos: .userInteractive,
        target: nil
    )
    
    func startMetaSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSession.Preset.cif352x288
        
        if captureSession.inputs.isEmpty
        {
            if let cameraDevice = deviceInputFromDevice(device: frontCameraDevice) {
                if captureSession.canAddInput(cameraDevice) {
                    captureSession.addInput(cameraDevice)
                }
            }
        }
        else
        {
            if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                for input in inputs {
                    captureSession.removeInput(input)
                    captureSession.removeOutput(movieOutput)
                    captureSession.removeOutput(metadataOutput)
                    if captureSession.inputs.isEmpty
                    {
                        if let cameraDevice = deviceInputFromDevice(device: frontCameraDevice) {
                            if captureSession.canAddInput(cameraDevice) {
                                captureSession.addInput(cameraDevice)
                            }
                        }
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
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: self.sessionQueue)
        if self.captureSession.canAddOutput(metadataOutput) {
            self.captureSession.addOutput(metadataOutput)
            self.captureSession.addOutput(movieOutput)
        }
        metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.face]
        DispatchQueue.global(qos: .background).async {
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
    }
    
    // MARK: - Meta data detection Delegate
    func printFaceLayer(layer: CALayer, faceObjects: [AVMetadataFaceObject]) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        // hide all the face layers
        var faceLayers = [CALayer]()
        for layer: CALayer in layer.sublayers! {
            if layer.name == "face" {
                faceLayers.append(layer)
            }
        }
        for faceLayer in faceLayers {
            faceLayer.removeFromSuperlayer()
        }
        
        var overLayRect = UIView()
        if(deviceSize() == "X" || deviceSize() == "Xr")
        {
            overLayRect = UIView(frame: CGRect(x: 50, y: 345, width: 275, height: 200))
        }
        else if(deviceSize() ==  "5sAndSE")
        {
            overLayRect = UIView(frame: CGRect(x: 40, y: 220, width: 240, height: 180))
        }
        else if(deviceSize() ==  "6And7Plus")
        {
            overLayRect = UIView(frame: CGRect(x: 50, y: 250, width: 310, height: 300))
        }
        else if(deviceSize() ==  "6And7")
        {
            overLayRect = UIView(frame: CGRect(x: 50, y: 255, width: 275, height: 220))
        }
        else if(deviceSize() == "iPad 9.7")
        {
            overLayRect = UIView(frame: CGRect(x: 200, y: 300, width: 350, height: 400))
        }
        else if(deviceSize() == "iPad 10.2")
        {
            overLayRect = UIView(frame: CGRect(x: 220, y: 300, width: 350, height: 400))
        }
        else if(deviceSize() == "iPad 10.5")
        {
            overLayRect = UIView(frame: CGRect(x: 220, y: 300, width: 350, height: 400))
        }
        else if(deviceSize() == "iPad 11")
        {
            overLayRect = UIView(frame: CGRect(x: 220, y: 300, width: 350, height: 400))
        }
        else if(deviceSize() == "iPad 12.9")
        {
            overLayRect = UIView(frame: CGRect(x: 270, y: 350, width: 350, height: 400))
        }
        
        let xCordinateForRect = overLayRect.frame.origin.x
        let yCordinateForRect = overLayRect.frame.origin.y
        let heightCordinateForRect = overLayRect.frame.size.height
        let widthCordinateForRect = overLayRect.frame.size.width
        overLayRect.backgroundColor = UIColor.green.withAlphaComponent(0.3)
        
        for faceObject in faceObjects {
            let featureLayer = CALayer()
            featureLayer.frame = faceObject.bounds
            featureLayer.name = "face"
            layer.addSublayer(featureLayer)
            
            let xCordinateForFaceObject = featureLayer.frame.origin.x
            let yCordinateForFaceObject = featureLayer.frame.origin.y
            let heightCordinateForFaceObject = featureLayer.frame.size.height
            let widthCordinateForFaceObject = featureLayer.frame.size.width
            
            
            if((xCordinateForFaceObject >= (xCordinateForRect - 20) &&  xCordinateForFaceObject <= (xCordinateForRect + 50)) && (yCordinateForFaceObject >= (yCordinateForRect - 20)  &&  yCordinateForFaceObject <= (yCordinateForRect + 50)) && (widthCordinateForFaceObject >= (widthCordinateForRect - 100)  &&  widthCordinateForFaceObject <= (widthCordinateForRect + 40)) && (heightCordinateForFaceObject >= (heightCordinateForRect - 100)  &&  heightCordinateForFaceObject <= (heightCordinateForRect + 40)))
            {
               
                if(deviceSize() == "X" || deviceSize() == "Xr")
                {
                    overLayImageView.image = UIImage(named: "FullFaceOverlayX", in: Bundle(for: type(of: self)), compatibleWith: nil)
                }
                else if(deviceSize() == "iPad 9.7")
                {
                    overLayImageView.image = UIImage(named: "FullFaceOverlay9.7", in: Bundle(for: type(of: self)), compatibleWith: nil)
                }
                else if(deviceSize() == "iPad 10.2")
                {
                    overLayImageView.image = UIImage(named: "fullFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
                }
                else if(deviceSize() == "iPad 10.5")
                {
                    overLayImageView.image = UIImage(named: "ullFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
                }
                else if(deviceSize() == "iPad 11")
                {
                    overLayImageView.image = UIImage(named: "fullFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
                }
                else if(deviceSize() == "iPad 12.9")
                {
                    overLayImageView.image = UIImage(named: "fullFaceOverlay12.9", in: Bundle(for: type(of: self)), compatibleWith: nil)
                }
                else
                {
                    overLayImageView.image = UIImage(named: "FullFaceOverlay", in: Bundle(for: type(of: self)), compatibleWith: nil)
                }
                detectionCounter = detectionCounter + 1
        
                if( detectionCounter == 45)
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.captureSession.removeOutput(self.metadataOutput)
                        self.startTimer()
                        self.detectionCounter = 0
                    })
                }
                
            }
            else
            {
                detectionCounter = 0
                if(deviceSize() == "X" || deviceSize() == "Xr")
                {
                    overLayImageView.image = UIImage(named: "DefaultFaceScanOverlayX", in: Bundle(for: type(of: self)), compatibleWith: nil)
                }
                else if(deviceSize() == "iPad 9.7")
                {
                    overLayImageView.image = UIImage(named: "defaultFaceOverlay9.7", in: Bundle(for: type(of: self)), compatibleWith: nil)
                }
                else if(deviceSize() == "iPad 10.2")
                {
                    overLayImageView.image = UIImage(named: "defaultFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
                }
                else if(deviceSize() == "iPad 10.5")
                {
                    overLayImageView.image = UIImage(named: "defaultFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
                }
                else if(deviceSize() == "iPad 11")
                {
                    overLayImageView.image = UIImage(named: "defaultFaceOverlay10.5", in: Bundle(for: type(of: self)), compatibleWith: nil)
                }
                else if(deviceSize() == "iPad 12.9")
                {
                    overLayImageView.image = UIImage(named: "defaultFaceOverlay12.9", in: Bundle(for: type(of: self)), compatibleWith: nil)
                }
                else
                {
                    overLayImageView.image = UIImage(named: "DefaultFaceScanOverlay", in: Bundle(for: type(of: self)), compatibleWith: nil)
                }
            }
        }
        CATransaction.commit()
    }
    //Meta data output for the frame capturing.
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        var faceObjects = [AVMetadataFaceObject]()
        for metadataObject in metadataObjects {
            if let metaFaceObject = metadataObject as? AVMetadataFaceObject,
                metaFaceObject.type == AVMetadataObject.ObjectType.face {
                if let object = self.previewLayer?.transformedMetadataObject(
                    for: metaFaceObject) as? AVMetadataFaceObject {
                    faceObjects.append(object)
                }
            }
        }
        if faceObjects.count > 0, let layer = self.previewLayer {
            
            if faceObjects.count > 1
            {
                //Show the alert for multiple face detection
                self.loaderOverlay(messageLabel: monitoringCameraMessageForMultiplePeople)
                print("Multiple people found")
            }
            else
            {
                DispatchQueue.main.async {
                    if (self.loadingView) != nil{ // If loadingView already exists
                        self.loadingView.hide()
                    }
                }
                
                self.printFaceLayer(layer: layer, faceObjects: faceObjects)
            }
        }
        else
        {
            //Face is not detected
            self.loaderOverlay(messageLabel: monitoringCameraMessageForNoPeople)
            self.printFaceLayer(layer: self.previewLayer!, faceObjects: faceObjects)
        }
    }

    func startTimer()
    {
        if progressTimer == nil {
           self.progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(FaceScanVC.updateProgress), userInfo: nil, repeats: true)
        }
    }
    
    func stopTimer()
    {
        if progressTimer != nil {
            progressTimer!.invalidate()
            progressTimer = nil
        }
    }
    
    func loaderOverlay(messageLabel: String)
    {
        DispatchQueue.main.async {
            if let loaderView = self.loadingView{ // If loadingView already exists
                if loaderView.isHidden() {
                    //                loaderView.show()  // To show activity indicator
                    self.loadingView = LoadingView(uiView: self.view, message: messageLabel)
                    self.loadingView.activityIndicator.isHidden = true
                    self.loadingView.messageLabel.textColor = UIColor.white
                }
            }
            else{
                self.loadingView = LoadingView(uiView: self.view, message: messageLabel)
                self.loadingView.activityIndicator.isHidden = true
                self.loadingView.messageLabel.textColor = UIColor.white
            }
        }
    }
}
