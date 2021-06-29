//
//  RoomScanResultVC.swift
//  ProctorTrack
//
//  Created by Diwakar Garg on 28/01/2019.
//  Copyright © 2019 Diwakar Garg. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import CoreMedia

class RoomScanResultVC: UIViewController {
    @IBOutlet weak var videoPlayView: UIView!
    @IBOutlet weak var reScanButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    var contentURL: String!
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    let screenSize : CGRect = UIScreen.main.bounds
    let  playerVC = AVPlayerViewController()
    var tapView: Bool = false
    var videoPlayIcon: UIImageView!
    
    //View did load function
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewStyleMethod()

        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:RoomScan_ResultScreen_Start"
                                              NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    //View will appear function
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //ScreenrecordingHandling
        if(screenRecordingStopEnable)
        {
            if #available(iOS 11.0, *) {
                addObserverForScreenRecording()
            } else {
                // Fallback on earlier versions
            }
        }
         self.navigationBarAddMethod()
    }
    
    //View did load function
    override func viewDidAppear(_ animated: Bool)
    {
        super .viewDidAppear(animated)
        self.playLocalVideo()
    }
    
    //View did disappear
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        if(kibanaLogEnable == true)
        {
                let finalMessage = kibanaPrefix + "event:RoomScan_ResultScreen_end"
                                              NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
        
        self.player?.pause()
        self.playerLayer?.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    //video player add to the videoPlayView
    func playLocalVideo(){
        
        let stringPath = (getDirectoryPath() as NSString).appendingPathComponent(roomScanVideoName + "." + String(videoExtension))

        self.player = AVPlayer(url: NSURL(fileURLWithPath:stringPath) as URL)
        self.player?.allowsExternalPlayback = false
        self.player?.usesExternalPlaybackWhileExternalScreenIsActive = false
        self.playerLayer = AVPlayerLayer(player: player)
        self.loopVideo(videoPlayer: player!)
        self.playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.player?.allowsExternalPlayback = false
        self.playerLayer?.frame =  videoPlayView.bounds
        videoPlayView.layer.addSublayer(playerLayer!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlurButton(_:)))
        self.videoPlayView.addGestureRecognizer(tapGesture)
    }
    
    func loopVideo(videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            self.player?.seek(to: CMTime.zero)
            self.player?.pause()
            self.videoPlayIcon.isHidden = false
            self.tapView = false
        }
    }
    
    //Tap getsure handling
    @objc func tapBlurButton(_ sender: UITapGestureRecognizer)
    {
        if (tapView == false)
        {
            tapView = true
            videoPlayIcon.isHidden = true
            player?.play()
        }
        else
        {
            tapView = false
            videoPlayIcon.isHidden = false
            player?.pause()
        }
    }
    
    //Custom View style Function
  fileprivate  func viewStyleMethod ()
    {
        videoPlayIcon = UIImageView (frame: CGRect(x: 0, y: 0, width: 40 , height: 40))
        videoPlayIcon.center.x = self.view.center.x
        videoPlayIcon.center = self.view.center
        videoPlayIcon.image = UIImage(named: "VideoPlay-g", in: Bundle(for: type(of: self)), compatibleWith: nil)?.maskWithColor(color: appThemeColorCode)
    
 
        self.view.addSubview(videoPlayIcon)
        reScanButton.layer.cornerRadius = buttonRoundCornerValue
        submitButton.layer.cornerRadius = buttonRoundCornerValue
    }
    
    //Navigation bar handling function
  fileprivate  func navigationBarAddMethod()
    {
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 3.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        self.navigationController?.navigationBar.layer.masksToBounds = false
        
        let customView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width - 100, height: (self.navigationController?.navigationBar.frame.size.height)!))
       
        let label = UILabel(frame: CGRect(x: 0, y: 0.0, width: self.view.frame.width, height: customView.frame.height))
        label.text = roomScanTitle
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
                   
                   let finalMessage = kibanaPrefix + "event:room_scan_rescan"
                   NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
               }

        //print("Back Button Clicked")
        _ = navigationController?.popViewController(animated: true)
    }
    
    //submitButtonAction function
    @IBAction func submitButtonAction(_ sender: Any) {
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:room_scan_submit"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
        if(bypassScanUploadFlow == true){
            
                self.performSegue(withIdentifier: verificationCompletedSegue, sender: self) 
        }
        else
        {
            self.uploadingChunksInBackground()
        }
    }
    
    //UploadChunksInBackGround
    func uploadingChunksInBackground() {
         self.performSegue(withIdentifier: verificationCompletedSegue, sender: self)
    }
}

