//
//  LiveMonitoring.swift
//  SDKintegrationPOC

import Foundation
import UIKit
import AVFoundation

class LiveMonitoring: NSObject, AVCaptureFileOutputRecordingDelegate {
    
    private var session = AVCaptureSession()
    private var frontCamera: AVCaptureDevice?
    private var micDevice: AVCaptureDevice?
    private var cameraPreviewLayer: AVCaptureVideoPreviewLayer!
    private var movieOutput = AVCaptureMovieFileOutput()
    
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
    private var monitoringTimer: Timer?
    
    static let shared = LiveMonitoring()
    
    private override init() {
    }
    
    func setupLiveCameraPreview(cameraView: UIView) {
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer(cameraView: cameraView)
        self.startSession()
    }
    
    private func setupCaptureSession() {
        session.beginConfiguration()
        session.sessionPreset = .medium
    }
    
    private func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        for device in deviceDiscoverySession.devices {
            if device.position == .front {
                self.frontCamera = device
            }
        }
        self.micDevice = AVCaptureDevice.default(for: .audio)
    }
    
    
    private func setupInputOutput() {
        do {
            guard let currentCamera = self.frontCamera, let micDevice = self.micDevice else { return }
            let videoDeviceInput = try AVCaptureDeviceInput.init(device: currentCamera)
            let audioDeviceInput = try AVCaptureDeviceInput.init(device: micDevice)
            if session.canAddInput(videoDeviceInput) && session.canAddInput(audioDeviceInput){
                session.addInput(videoDeviceInput)
                session.addInput(audioDeviceInput)
            }
            if session.canAddOutput(self.movieOutput) {
                self.movieOutput.movieFragmentInterval = kCMTimeInvalid
                self.session.addOutput(self.movieOutput)
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    
    private func setupPreviewLayer(cameraView: UIView) {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        self.cameraPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.cameraPreviewLayer.connection?.videoOrientation = .portrait
        let rootLayer :CALayer = cameraView.layer
        self.cameraPreviewLayer.frame = rootLayer.bounds
        rootLayer.addSublayer(self.cameraPreviewLayer)
    }
    
    private func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }
    
    func stopSession() {
        self.session.stopRunning()
    }
    
    func startMovieRecording() {
        if let tempPathUrl = self.tempFilePath {
            print(tempPathUrl)
            self.movieOutput.startRecording(to: tempPathUrl, recordingDelegate: self )
            self.monitoringTimer  = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.stopMovieRecording), userInfo: nil, repeats: true);
        }
    }
    
    @objc func stopMovieRecording() {
        self.movieOutput.stopRecording()
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!)
    {
        print("Start Recording")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("stop recording")
        print(output.isRecording)
        print(output.recordedFileSize)
        print(error?.localizedDescription as Any)
        print(outputFileURL)
    }
}
