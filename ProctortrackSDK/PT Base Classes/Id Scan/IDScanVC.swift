//
//  IDScanVC.swift
//  ProctorTrack
//
//  Created by Diwakar Garg on 28/01/2019.
//  Copyright © 2019 Diwakar Garg. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class IDScanVC: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate,IDScanOverlayDelegate,SwiftySwitchDelegate{
    var navigationBarTitle : UILabel?
    //Camera operation variable
    var captureSession = AVCaptureSession()
    var previewLayer:AVCaptureVideoPreviewLayer?
    var captureDevice:AVCaptureDevice!
    var takePhoto = false
    var recordButton : UIButton?
    var longPressBeginTime: TimeInterval = 0.0
    var instructionLabel : UILabel?
    var horizontalLabel : UILabel?
    var verticalLabel : UILabel?
    var switchView: SwiftySwitch!
    var overLayImageView: UIImageView?
    var cameraView: UIView?
    let dataOutput = AVCaptureVideoDataOutput()
    var loadOverlay : Bool = false
    
    //front camera accessing function
    lazy var frontCameraDevice: AVCaptureDevice? = {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        for device in deviceDiscoverySession.devices {
            if device.position == .back {
                return device
            }
        }
        return nil
    }()
    
    //View did load function
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:IDscan_start"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    //View Will appear function
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.viewStyleMethod()
        self.navigationBarAddMethod()
        self.loadRecordingMethod()
        self.overLayView()
        NotificationCenter.default.addObserver(self, selector: #selector(appForegroundStateFunction), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appBackgroundStateFunction), name: UIApplication.didEnterBackgroundNotification, object: nil)
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
        self.captureSession.stopRunning()
        
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:IDscan_end"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func appForegroundStateFunction()
    {
        if takePhoto
        {
            takePhoto = false
            recordButton?.isEnabled = true
        }
        self.captureSession.startRunning()
    }
    
    @objc func appBackgroundStateFunction() {
        self.captureSession.stopRunning()
    }
    
    fileprivate func viewStyleMethod ()
    {
        cameraView = UIView(frame: CGRect(x: self.view.frame.origin.x ,y:self.view.frame.origin.y  ,width: self.view.frame.width ,height: self.view.frame.height))
        self.view.addSubview(cameraView!)
        
        overLayImageView  = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width , height: self.view.frame.height))
        overLayImageView?.center.x = self.view.center.x
        overLayImageView?.center.y = self.view.center.y
        if(deviceSize() ==  "X")
        {
            overLayImageView?.image = UIImage(named: "IdFrameOverlay-HX")
        }
        else if(deviceSize() == "iPad 9.7")
        {
            overLayImageView?.image = UIImage(named: "idFrameOverlayV9.7")
        }
        else if(deviceSize() == "iPad 10.2")
        {
            overLayImageView?.image = UIImage(named: "idFrameOverlayV10.5")
        }
        else if(deviceSize() == "iPad 10.5")
        {
            overLayImageView?.image = UIImage(named: "idFrameOverlayV10.5")
        }
        else if(deviceSize() == "iPad 11")
        {
            overLayImageView?.image = UIImage(named: "idFrameOverlayV10.5")
        }
        else if(deviceSize() == "iPad 12.9")
        {
            overLayImageView?.image = UIImage(named: "idFrameOverlayV12.9")
        }
        else
        {
            overLayImageView?.image = UIImage(named: "IdFrameOverlay-H")
        }
        
        overLayImageView?.isUserInteractionEnabled = true
        self.view.addSubview(overLayImageView!)
        
        let image = UIImage(named: "Camera-P")
        let button = UIButton(frame: CGRect(x: 0,y: self.view.frame.height - 85 ,width: 30,height: 30))
        button.setImage(image?.maskWithColor(color: appThemeColorCode) as UIImage?, for: .normal)
        button.center.x = self.view.center.x
        self.overLayImageView?.addSubview(button)
        
        // set up recorder button
        recordButton = UIButton(frame: CGRect(x: 0,y: self.view.frame.height - 100 ,width: 60,height: 60))
        // recordButton.setImage(UIImage(named: "Camera-P") as UIImage?, for: .normal)
        recordButton?.addTarget(self, action: #selector(IDScanVC.camerButtonAction), for: UIControl.Event.touchUpInside)
        recordButton?.center.x = self.view.center.x
        recordButton?.layer.cornerRadius = (self.recordButton?.frame.height)!/2
        recordButton?.layer.borderColor = UIColor(red:0.19, green:0.59, blue:0.97, alpha:1.0).cgColor
        recordButton?.layer.borderWidth = 2
        recordButton?.isUserInteractionEnabled = true
        recordButton?.layer.backgroundColor = UIColor(red:0.39, green:0.97, blue:1.00, alpha:0.2).cgColor
        self.overLayImageView?.addSubview(recordButton!)
        
        if(deviceSize() ==  "X")
        {
             instructionLabel = UILabel(frame: CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.size.height)! + 60, width: self.view.frame.width - 20, height: 90))
        }
        else
        {
             instructionLabel = UILabel(frame: CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.size.height)! + 25, width: self.view.frame.width - 20, height: 90))
        }
        
       
        instructionLabel?.center.x = self.view.center.x
        instructionLabel?.lineBreakMode = .byWordWrapping
        instructionLabel?.numberOfLines = 2
        instructionLabel?.textAlignment = .center
        instructionLabel?.adjustsFontSizeToFitWidth = true
//        instructionLabel.text = "Click to take picture"
        instructionLabel?.text = idScanInstructionText
        instructionLabel?.textColor = UIColor.white
        self.overLayImageView?.addSubview(instructionLabel!)
        
        switchView = SwiftySwitch (frame: CGRect(x: 0, y: (recordButton?.frame.origin.y)! - 55, width: 50, height: 29))
        switchView.mySize = CGSize(width: 50, height: 29)
        switchView.delegate = self
        switchView.corners0to1 = 0.5
        switchView.dotSpacer = 2
        switchView.smallDot0to1 = 0
        switchView.dotOffColor = lightGreenColor
        switchView.dotOnColor = lightGreenColor
        switchView.dotTime = 0.5
        switchView.myColor = UIColor.clear
        switchView.layer.borderWidth = 1
        switchView.layer.borderColor = UIColor.white.cgColor
        
        //        switchView.onTintColor = textColorCode
        switchView.center.x = self.view.center.x
        //        switchView.addTarget(self, action:#selector(IDScanVC.switchValueDidChange(sender:)), for: .valueChanged)
        switchView.isOn =  true
        self.overLayImageView?.addSubview(switchView)
        
        horizontalLabel = UILabel(frame: CGRect(x: (self.view.frame.width/2) + 40, y: (recordButton?.frame.origin.y)! - 55, width: 100, height: 31))
        horizontalLabel?.textAlignment = .left
        horizontalLabel?.text = "Horizontal"
         horizontalLabel?.textColor = lightGreenColor
        self.overLayImageView?.addSubview(horizontalLabel!)
        
        verticalLabel = UILabel(frame: CGRect(x: (self.view.frame.width/2) - 140, y: (recordButton?.frame.origin.y)! - 55, width: 100, height: 31))
        verticalLabel?.textAlignment = .right
        verticalLabel?.text = "Vertical"
        verticalLabel?.textColor = UIColor.white
        self.overLayImageView?.addSubview(verticalLabel!)
    }
    
    func valueChanged(sender: SwiftySwitch) {
        if sender.isOn {
            switchView.isOn =  true
            if(deviceSize() ==  "X")
            {
                overLayImageView?.image = UIImage(named: "IdFrameOverlay-HX")
            }
            else if(deviceSize() == "iPad 9.7")
            {
                overLayImageView?.image = UIImage(named: "idFrameOverlayV9.7")
            }
            else if(deviceSize() == "iPad 10.2")
            {
                overLayImageView?.image = UIImage(named: "idFrameOverlayV10.5")
            }
            else if(deviceSize() == "iPad 10.5")
            {
                overLayImageView?.image = UIImage(named: "idFrameOverlayV10.5")
            }
            else if(deviceSize() == "iPad 11")
            {
                overLayImageView?.image = UIImage(named: "idFrameOverlayV10.5")
            }
            else if(deviceSize() == "iPad 12.9")
            {
                overLayImageView?.image = UIImage(named: "idFrameOverlayV12.9")
            }
            else
            {
                overLayImageView?.image = UIImage(named: "IdFrameOverlay-H")
            }
            horizontalLabel?.text = "Horizontal"
            horizontalLabel?.textColor = lightGreenColor
            verticalLabel?.textColor = UIColor.white
            
        } else {
            
            switchView.isOn =  false
            if(deviceSize() ==  "X")
            {
                overLayImageView?.image = UIImage(named: "IdFrameOverlayX")
            }
            else if(deviceSize() == "iPad 9.7")
            {
                overLayImageView?.image = UIImage(named: "idFrameOverlayH9.7")
            }
            else if(deviceSize() == "iPad 10.2")
            {
                overLayImageView?.image = UIImage(named: "idFrameOverlayH10.5")
            }
            else if(deviceSize() == "iPad 10.5")
            {
                overLayImageView?.image = UIImage(named: "idFrameOverlayH10.5")
            }
            else if(deviceSize() == "iPad 11")
            {
                overLayImageView?.image = UIImage(named: "idFrameOverlayH10.5")
            }
            else if(deviceSize() == "iPad 12.9")
            {
                overLayImageView?.image = UIImage(named: "idFrameOverlayH12.9")
            }
            else
            {
                overLayImageView?.image = UIImage(named: "IdFrameOverlay")
            }
            
            verticalLabel?.text = "Vertical"
            verticalLabel?.textColor = lightGreenColor
            horizontalLabel?.textColor = UIColor.white
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
       
        navigationBarTitle = UILabel(frame: CGRect(x: 0, y: 10.0, width: customView.frame.width , height: customView.frame.height))
        navigationBarTitle?.text = idScanTitle
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
    
    //Load recording functions
    func loadRecordingMethod()
    {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo

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
                    captureSession.removeOutput(dataOutput)
                    if let cameraDevice = deviceInputFromDevice(device: frontCameraDevice) {
                        if captureSession.canAddInput(cameraDevice) {
                            captureSession.addInput(cameraDevice)
                        }
                    }
                }
            }
        }
        if let previewView = self.cameraView {
            self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.previewLayer?.frame = (previewView.layer.frame)
            if let previewLayer = self.previewLayer {
                self.cameraView?.layer.addSublayer(previewLayer)
            }
        }
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(value:kCMPixelFormat_32BGRA)]
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }
        DispatchQueue.global(qos: .background).async {
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
        }
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
    //Delegate Function for capture photo
      func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if takePhoto
        {
            takePhoto = false
            // getImageFromSampleBuffer
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer)
            {
                let finalImage = resizeImage(image: image, targetSize: CGSize(width:640, height: 640))

                let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                print("Print the path:- ",documentsDirectoryURL)
                let fileURL =  (getDirectoryPath() as NSString).appendingPathComponent(idScanImageName + "." + imageExtension)

                if !FileManager.default.fileExists(atPath: fileURL) {
                    do {

                        try finalImage.pngData()!.write(to:URL( fileURLWithPath: fileURL))
                        DispatchQueue.main.async
                            {
                                 chunkCount = chunkCount + 1
                            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                                        self.performSegue(withIdentifier: iDScanResultSegue, sender: self)
                                })

                        }
                        print("Image Added Successfully")
                    } catch {
                        print(error)
                    }
                } else {
                     chunkCount = chunkCount - 1
                    removeImageAndVideo(itemName:(getDirectoryPath() as NSString).appendingPathComponent(idScanImageName), fileExtension: imageExtension)
                    do {
                        let finalImage = resizeImage(image: image, targetSize: CGSize(width:640, height: 640))
                        try finalImage.pngData()!.write(to:URL( fileURLWithPath: fileURL))
                        DispatchQueue.main.async
                            {
                                 chunkCount = chunkCount + 1
                                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                                    self.performSegue(withIdentifier: iDScanResultSegue, sender: self)
                                })
                        }
                        print("Image Added Successfully")
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    
    //Function for get Image from sample Buffer
    func getImageFromSampleBuffer(buffer:CMSampleBuffer) -> UIImage?
    {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer)
        {
            if #available(iOS 9.0, *) {
                let ciImage = CIImage (cvImageBuffer: pixelBuffer)
                let context = CIContext()
                
                let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
                if let image = context.createCGImage(ciImage, from: imageRect)
                {
                    return UtilityClass.fixOrientationOfImage(image: UIImage(cgImage: image, scale: 0.0, orientation: .right))
                }
                //
            } else {
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer);
                let image = UIImage(data: imageData!) //  Here you have UIImage
                return UtilityClass.fixOrientationOfImage(image: image!)
                // Fallback on earlier versions
            }
        }
        return nil
    }
    
    //custom burton action method
    @objc func camerButtonAction()
    {
        recordButton?.isEnabled = false
        print("add action here")
        takePhoto = true
        
        let queue = DispatchQueue(label: "testing video demo")
        dataOutput.setSampleBufferDelegate(self, queue: queue)
    }
    
    //    FaceScanOverLayDelegateMethodImplementation for changing the navigation bar title
    func setNavigationBarLabel(text:String) {
        self.navigationBarTitle?.text = text
    }
    //Custom function to call the pop up screen
    func overLayView()
    {
        loadOverlay = true
        let bottomSheetVC = storyboard?.instantiateViewController(withIdentifier: idScanOverlay) as! IDScanOverlayVC
        bottomSheetVC.delegate = self
        bottomSheetVC.didMove(toParent: self)
        let height = view.frame.height
        let width  = view.frame.width
        //  print("Value of Object : ",(UserDefaults.standard.object(forKey:"faceScanChcekBoxStatus"))!)
        if((UserDefaults.standard.object(forKey:"idScanChcekBoxStatus")) != nil)
        {
            if (deviceSize() == "X") {
                bottomSheetVC.view.frame = CGRect(x: 0, y: height - 20, width: width, height: height - 85)
            }
            else{
                bottomSheetVC.view.frame = CGRect(x: 0, y: height - 20, width: width, height: height - 65)
            }
            //Not Load the overlay view
            print("overlay is not to be loaded");
        }
        else
        {
            if (deviceSize() == "X") {
                bottomSheetVC.view.frame = CGRect(x: 0, y: 85, width: width, height: height - 85)
                 self.setNavigationBarLabel(text:idScanOverlayTitle)
                
            }
            else{
                bottomSheetVC.view.frame = CGRect(x: 0, y: 65, width: width, height: height - 65)
                self.setNavigationBarLabel(text:idScanOverlayTitle)
            } 
        }
        self.view.addSubview(bottomSheetVC.view)
        self.addChild(bottomSheetVC)
    }
    
    //Memory management Function
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    // MARK: - DGTopMenu Delegate
}

