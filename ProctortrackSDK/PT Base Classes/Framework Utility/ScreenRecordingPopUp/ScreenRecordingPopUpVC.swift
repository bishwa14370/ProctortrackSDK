//
//  ScreenRecordingPopUpVC.swift
//  ProctorTrack
//
//  Created by Diwakar Garg on 28/01/2019.
//  Copyright © 2019 Diwakar Garg. All rights reserved.
//

import UIKit

class ScreenRecordingPopUpVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        NotificationCenter.default.addObserver(self, selector: #selector(removeAnimate), name: NSNotification.Name(rawValue: "removeOverlay"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    @objc  func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
            }
        })
    }
}
@available(iOS 11.0, *)
extension UIViewController
{
    func addObserverForScreenRecording() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: UIScreen.capturedDidChangeNotification, object: nil)
    }
    
    func loadPopUpView()
    {
        let popvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "screenRecordingPopUpView") as! ScreenRecordingPopUpVC
        self.addChild(popvc)
        popvc.view.frame = self.view.frame
        self.view.addSubview(popvc.view)
        popvc.didMove(toParent: self)
    }
    
    @objc func handleNotification(){
        let isCaptured = UIScreen.main.isCaptured
        if(isCaptured == true)
        {
            self.loadPopUpView()
        }
        else
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeOverlay"), object: nil)
        }
    }
}

