//
//  LiveMonitoring.swift
//  SDKintegrationPOC

import Foundation
import UIKit
import AVFoundation
import UserNotifications

class LiveMonitoring: NSObject {
    
    private var session = AVCaptureSession()
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer!
    private var movieOutput = AVCaptureMovieFileOutput()
    private let client: AntMediaClient = AntMediaClient.init()
    weak var monitoringDelegate: SDKClientDelegate?
    private var getTokenCount = 0
    private var streamIdInUseTokenCount = 0
    private var tempArray = [String]()
    private var blinkImageView : UIImageView!
    var isViewWillDisappear : Bool = false
    
    private var tempFilePath: URL? = {
        let tempPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tempMovie").appendingPathExtension(videoExtension).absoluteString
        if FileManager.default.fileExists(atPath: tempPath) {
            do {
                try FileManager.default.removeItem(atPath: tempPath)
            } catch { }
        }
        guard let pathUrl = URL(string: tempPath) else {return nil}
        return pathUrl
    }()
    
    //front camera accessing method
    lazy var frontCameraDevice: AVCaptureDevice? = {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        for device in deviceDiscoverySession.devices {
            if device.position == .front {
                return device
            }
        }
        return nil
    }()
    
    //Mic accessing method
    lazy var micDevice: AVCaptureDevice? = {
        return AVCaptureDevice.default(for: AVMediaType.audio)
    }()
    
    private var monitoringTimer: Timer?
    
    static let shared = LiveMonitoring()
    
    private override init() {
        super.init()
        self.setupObserver()
        self.setupNotification()
        self.uploadingChunksInBackground()
    }
    
    //TODO: To call at end monitoring
    private func removeAllAndCloseSocket() {
        if(liveMonitoringScanRequired) {
            if(self.client.isConnected()) {
                self.isViewWillDisappear = true
                self.client.stop()
            }
            if(kibanaLogEnable == true) {
                let finalMessage = kibanaPrefix + "event:Live_monitoring_end"
                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
            }
        }
        else {
            self.monitoringTimer?.invalidate()
            if(kibanaLogEnable == true) {
                let finalMessage = kibanaPrefix + "event:Offline_monitoring_end"
                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
            }
        }
        self.blinkImageView.stopBlinkImage()
        NotificationManager.removeNotification()
        NotificationCenter.default.removeObserver(self, name: .flagsChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    // TODO: set up for app back/foreground state
    // background chunk upload service call
    // Remove observer, remove notification, close socket, stop recording timer on View will disappear
    private func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        NotificationCenter.default.addObserver(self, selector: #selector(appForegroundStateFunction), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appBackgroundstate), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func setupNotification() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
        }
        NotificationManager.permissionForLocalNotification()
    }
    
    @objc private func rotated() {
        if let imageView = self.blinkImageView {
            imageView.removeFromSuperview()
        }
        self.setupBlinkIndicatorView()
    }
    
    private func setupBlinkIndicatorView() {
        if let vc = UIApplication.getTopViewController(), let view = vc.view {
            self.blinkImageView = UIImageView(image: UIImage(named: "Circle-w", in: Bundle(for: type(of: self)), compatibleWith: nil))
            let y = (vc.navigationController?.navigationBar.frame.height ?? 0.0)
            //   let const = UIDevice.current.orientation.isLandscape ? 10.0 : 50.0
            let screenSize = UIScreen.main.bounds.size.width
            self.blinkImageView.frame = CGRect(x: screenSize - 20, y: y + 50, width: 10, height: 10)
            self.blinkImageView.image = self.blinkImageView.image?.maskWithColor(color: .red)
            view.addSubview(self.blinkImageView)
            if(liveMonitoringScanRequired) {
                if(self.client.isConnected()) {
                    self.blinkImageView.blinkImage()
                }
            }
            else {
                if self.movieOutput.isRecording {
                    self.blinkImageView.blinkImage()
                }
            }
        }
    }
    
    func setupLiveCameraPreview() {
        self.rotated()
        if(liveMonitoringScanRequired) {
            let cameraView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            self.setupLiveStreaming(view: cameraView)
        }
        else {
            self.setupCaptureSession()
            self.setupInputOutput()
            let cameraView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            self.setupPreviewLayer(cameraView: cameraView)
            self.startSession()
            if (changeVideoCodecFormat == true) {
                self.recordMovieInH264CodecFormat()
            }
        }
    }
    
    private func setupLiveStreaming(view: UIView) {
        liveStreamBaseUrl = "wss://ca-livemedia-5.verificient.com:5443/WebRTCAppEE/websocket"
        self.client.delegate = self
        self.client.setOptions(url: liveStreamBaseUrl, streamId: liveMonitoringStreamID, token: liveStreamingTokenID, mode: .publish)
        if self.client.getCurrentMode() == AntMediaClientMode.publish {
            self.client.setCameraPosition(position: .front)
            self.client.setTargetResolution(width: 360, height: 240)
            self.client.setLocalView(container: view, mode: .scaleAspectFill)
            self.client.initPeerConnection()
        }
    }
    
    private func getCurrentMonitoringToken(streamName: String) {
        self.getTokenCount = self.getTokenCount + 1
        NetworkingClass.getMonitoringStreamTokenId(streamName: streamName) {[weak self] (success) in
            if let this = self {
                if success {
                    this.client.setOptions(url: liveStreamBaseUrl, streamId: streamName, token: liveStreamingTokenID, mode: .publish)
                    this.client.start()
                    this.getTokenCount = 0
                }
                else {
                    if this.getTokenCount < 5 {
                        this.getCurrentMonitoringToken(streamName: streamName)
                    }
                    else {
                        if let delegate = this.monitoringDelegate {
                            delegate.sdkMonitoringError(message: "Monitoring token error")
                        }
                    }
                }
            }
        }
    }
    
    private func getTokenForstreamIdInUse(streamName: String) {
        self.streamIdInUseTokenCount = self.streamIdInUseTokenCount + 1
        NetworkingClass.getMonitoringStreamTokenId(streamName: streamName) {[weak self] (success) in
            if let this = self {
                if success {
                    this.client.stop()
                    this.client.setOptions(url: liveStreamBaseUrl, streamId: streamName, token: liveStreamingTokenID, mode: .publish)
                    this.streamIdInUseTokenCount = 0
                }
                else {
                    if this.streamIdInUseTokenCount < 5 {
                        this.getTokenForstreamIdInUse(streamName: streamName)
                    }
                    else {
                        if let delegate = this.monitoringDelegate {
                            delegate.sdkMonitoringError(message: "Monitoring token error")
                        }
                    }
                }
            }
        }
    }
    
    private func setupCaptureSession() {
        session.beginConfiguration()
        session.sessionPreset = .low
    }
    
    private func setupInputOutput() {
        if self.session.inputs.isEmpty {
            if let cameraDevice = self.deviceInputFromDevice(device: self.frontCameraDevice) {
                if self.session.canAddInput(cameraDevice) {
                    self.session.addInput(cameraDevice)
                }
            }
            if let micDevice = self.deviceInputFromDevice(device: self.micDevice) {
                if self.session.canAddInput(micDevice) {
                    self.session.addInput(micDevice)
                }
            }
        }
        else {
            if let inputs = self.session.inputs as? [AVCaptureDeviceInput] {
                for input in inputs {
                    self.session.removeInput(input)
                    self.session.removeOutput(self.movieOutput)
                    if self.session.inputs.isEmpty
                    {
                        if let cameraDevice = self.deviceInputFromDevice(device: self.frontCameraDevice) {
                            if self.session.canAddInput(cameraDevice) {
                                self.session.addInput(cameraDevice)
                            }
                        }
                        if let micDevice = self.deviceInputFromDevice(device: self.micDevice) {
                            if self.session.canAddInput(micDevice) {
                                self.session.addInput(micDevice)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func setupPreviewLayer(cameraView: UIView) {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.cameraPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer.connection?.videoOrientation = .landscapeLeft
        let rootLayer :CALayer = cameraView.layer
        self.cameraPreviewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(self.cameraPreviewLayer)
    }
    
    private func startSession() {
        self.movieOutput.movieFragmentInterval = CMTime.invalid
        if self.session.canAddOutput(self.movieOutput) {
            self.session.addOutput(self.movieOutput)
        }
        self.session.commitConfiguration()
        self.session.startRunning()
    }
    
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
    
    private func deviceInputSettingConfiguration(input: AVCaptureDeviceInput) -> AVCaptureDeviceInput {
        let device = input.device
        
        if(device.hasMediaType(.video)){
            do {
                try device.lockForConfiguration()
                device.activeVideoMinFrameDuration = .invalid
                device.automaticallyAdjustsVideoHDREnabled = false
                device.videoZoomFactor = 1.0
                if(device.isSmoothAutoFocusSupported) {
                    device.isSmoothAutoFocusEnabled = false
                }
                device.unlockForConfiguration()
            } catch {
                print("Error setting configuration: \(error)")
            }
        }
        return input
    }
    
    func startMovieRecording() {
        if liveMonitoringScanRequired {
            is_stream_auto_renaming_enabled = UserDefaults.standard.bool(forKey: streamAutoRenamingKey)
            if (is_stream_auto_renaming_enabled) {
                guard let documentID = UserDefaults.standard.string(forKey: testsession_uuid) else {return}
                FirestoreDB.shared.getStreamIdForLiveProctoring(documentID: documentID) {[weak self] (success, docSnapshot) in
                    if let this = self {
                        if (success) {
                            if (docSnapshot.count > 0) {
                                if let lastStreamId = docSnapshot.last {
                                    let streamId = lastStreamId.components(separatedBy: "_monitoring_mobile")
                                    if let last = streamId.last, last.count > 0 {
                                        let finalStreamIdExtension = last.replacingOccurrences(of: "_", with: "")
                                        streamIdExtension = (finalStreamIdExtension as NSString).integerValue
                                    }
                                    this.getCurrentMonitoringToken(streamName: lastStreamId)
                                }
                            }
                            else {
                                this.getCurrentMonitoringToken(streamName: liveMonitoringStreamID)
                            }
                            
                            if(kibanaLogEnable == true){
                                let finalMessage = kibanaPrefix + "event: Live_Monitoring" + seprator + "type: Get data success \(docSnapshot)"
                                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                            }
                        }
                        else {
                            this.getCurrentMonitoringToken(streamName: liveMonitoringStreamID)
                            
                            if(kibanaLogEnable == true){
                                let finalMessage = kibanaPrefix + "event: Live_Monitoring" + seprator + "type: Get data: \(docSnapshot) | stream started with default stream id"
                                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                            }
                        }
                    }
                }
            }
            else {
                self.getCurrentMonitoringToken(streamName: liveMonitoringStreamID)
            }
        }
        else {
            if let tempPathUrl = self.tempFilePath {
                self.movieOutput.startRecording(to: tempPathUrl, recordingDelegate: self )
                self.monitoringTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.stopMovieRecording), userInfo: nil, repeats: true)
                self.blinkImageView.blinkImage()
            }
        }
    }
    
    @objc func stopMovieRecording() {
        self.movieOutput.stopRecording()
    }
    
    private func recordMovieInH264CodecFormat() {
        if let movieFileOutputConnection = movieOutput.connection(with: .video) {
            if #available(iOS 11.0, *) {
                let availableVideoCodecTypes = movieOutput.availableVideoCodecTypes
                if availableVideoCodecTypes.contains(.hevc) {
                    movieOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.h264], for: movieFileOutputConnection)
                }
            }
        }
        
    }
    
    @objc private func statusManager() {
        self.updateUserInterface()
    }
    
    //Network related method
    private func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        if(status == .unreachable) {
            self.client.stop()
            if(kibanaLogEnable == true) {
                let finalMessage = kibanaPrefix +  "event: Network Loss" + seprator + "type: Internet is not reachable"
                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
            }
        }
    }
    
    @objc private func appBackgroundstate() {
        NotificationManager.scheduleNotificationForEveryMinute()
        appBackgroundStateFunction()
    }
    
    @objc private func appBackgroundStateFunction() {
        if(liveMonitoringScanRequired) {
            if( self.client.isConnected()) {
                self.client.stop()
            }
        }
        else {
            self.monitoringTimer?.invalidate()
            self.blinkImageView.stopBlinkImage()
        }
        
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event: Violation" + seprator + "App enter background violation"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    //    MARK: - appForegroundStateFunction
    @objc private func appForegroundStateFunction() {
        if(liveMonitoringScanRequired) {
        }
        else {
            if (changeVideoCodecFormat ==  true) {
                self.recordMovieInH264CodecFormat()
            }
            if let pathUrl = self.tempFilePath {
                self.movieOutput.startRecording(to: pathUrl, recordingDelegate: self )
            }
            self.monitoringTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.stopMovieRecording), userInfo: nil, repeats: true)
            self.blinkImageView.blinkImage()
        }
    }
    
    private func uploadingChunksInBackground() {
        tempArray = listFilesFromDocumentsFolder()!
        directoryFilePathArray = tempArray.sorted { $0.compare($1, options: .numeric) == .orderedAscending }
        
        if (directoryFilePathArray.count > 0) {
            ChunksUploadManager.chunksListFromDirectory(completionHandler: {(success) in
                self.uploadingChunksInBackground()
            })
        }
        else {
            NotificationCenter.default.post(name: Notification.Name(chunkUploadInProgressInMonitoringScreen) , object: nil)
        }
    }
}


extension LiveMonitoring: AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("Start Recording")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let err = error {
            print(err.localizedDescription)
        }
        else {
            chunkCount = chunkCount + 1
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = outputFileURL
            
            do {
                try FileManager.default.moveItem(at: fileURL, to: documentsDirectoryURL.appendingPathComponent(fileNameForMonitoring + String(chunkCount)).appendingPathExtension(videoExtension))
            } catch {
                print(error.localizedDescription)
            }
            
            if (changeVideoCodecFormat ==  true) {
                self.recordMovieInH264CodecFormat()
            }
            
            if let pathUrl = self.tempFilePath {
                self.movieOutput.startRecording(to: pathUrl, recordingDelegate: self )
            }
            self.uploadingChunksInBackground()
        }
    }
}

extension LiveMonitoring: UNUserNotificationCenterDelegate {
    
}

extension LiveMonitoring: AntMediaClientDelegate {
    func localStreamStarted(streamId: String) {
        if(kibanaLogEnable == true){
            let finalMessage = kibanaPrefix + "event: Live_Monitoring" + seprator + "type: localStreamStarted"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    func clientDidConnect(_ client: AntMediaClient) {
        if let delegate = self.monitoringDelegate {
            delegate.clientDidConnect(message: "client connected")
        }
        
        if(kibanaLogEnable == true){
            let finalMessage = kibanaPrefix + "event: Live_Monitoring" + seprator + "type: clientDidConnect on \(client.getWsUrl())"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    func clientDidDisconnect(_ message: String) {
        if let delegate = self.monitoringDelegate {
            delegate.clientDidDisconnect(message: "client disconnected \(message)")
        }
        self.blinkImageView.stopBlinkImage()
        if (!self.isViewWillDisappear) {
            self.reconnectAntMedia()
            
            if(kibanaLogEnable == true){
                let finalMessage = kibanaPrefix + "event: Live_Monitoring" + seprator + "type: clientDidDisconnect \(message)"
                NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
            }
        }
    }
    
    func reconnectAntMedia() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.client.start()
        }
        
        if(kibanaLogEnable == true) {
            let finalMessage = kibanaPrefix + "event: Live_Monitoring" + seprator + "type: reconnectAntMedia"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    func disconnected(streamId: String) {
        if(kibanaLogEnable == true){
            let finalMessage = kibanaPrefix + "event: Live_Monitoring" + seprator + "type: disconnected for \(streamId)"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    func clientHasError(_ message: String) {
        if let delegate = self.monitoringDelegate {
            delegate.clientHasError(message: "client has error \(message)")
        }
        if message.contains("streamIdInUse") {
            is_stream_auto_renaming_enabled = UserDefaults.standard.bool(forKey: streamAutoRenamingKey)
            if (is_stream_auto_renaming_enabled) {
                streamIdExtension = streamIdExtension + 1
                let newStreamId = liveMonitoringStreamID + "_" + "\(streamIdExtension)"
                self.getTokenForstreamIdInUse(streamName: newStreamId)
            }
        }
        else {
            self.client.stop()
        }
        
        if(kibanaLogEnable == true){
            let finalMessage = kibanaPrefix + "event: Live_Monitoring" + seprator + "type: clientHasError \(message)"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    func publishStarted(streamId: String) {
        if let delegate = self.monitoringDelegate {
            delegate.publishStarted(message: "publish started")
        }
        self.blinkImageView.blinkImage()
        is_stream_auto_renaming_enabled = UserDefaults.standard.bool(forKey: streamAutoRenamingKey)
        if (is_stream_auto_renaming_enabled) {
            guard let documentID = UserDefaults.standard.string(forKey: testsession_uuid) else {return}
            FirestoreDB.shared.updateStreamIDForLiveProctoring(documentID: documentID, streamID: streamId) {[weak self] (message) in
                if self != nil {
                    if(kibanaLogEnable == true){
                        let finalMessage = kibanaPrefix + "event: Live_Monitoring" + seprator + "type: publishStarted | \(message)"
                        NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                    }
                }
            }
        }
        else {
            if(kibanaLogEnable == true){
                let finalMessage = kibanaPrefix + "event: Live_Monitoring" + seprator + "type: publishStarted with \(streamId)"
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
