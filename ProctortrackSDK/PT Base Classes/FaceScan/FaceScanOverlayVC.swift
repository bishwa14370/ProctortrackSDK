//
//  FaceScanOverlayVC.swift
//  ProctorTrack
//
//  Created by Diwakar Garg on 28/01/2019.
//  Copyright © 2019 Diwakar Garg. All rights reserved.
//

import UIKit

protocol FaceScanOverlayDelegate {
    func setNavigationBarLabel(text: String)
}

class FaceScanOverlayVC: UIViewController {
    
    @IBOutlet weak var faceScanImageView: UIImageView!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var gotItButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var holdView: UIView!
    var delegate: FaceScanOverlayDelegate?
    var tap : Bool = false
    
    var fullView: CGFloat {
        if (deviceSize() == "X") {
            return 90
        }
        else
        {
            return 65
        }
    }
    var partialView: CGFloat {
        if (deviceSize() == "X") {
            return UIScreen.main.bounds.height - 33
        }
        else
        {
            return UIScreen.main.bounds.height - 20
        }
        
    }
    
    //View Didload
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:facescan_Overlay_start"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.viewStyleMethod()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:facescan_Overlay_end"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    //Custom View style function
    func viewStyleMethod ()
    {
        self.instructionLabel.text = "Record a 10 seconds video of your full face, including right and left sides."
        // Blur effect to background view
        let effect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: effect)
        blurView.frame = self.view.bounds
        self.view.addSubview(blurView)
        self.view.sendSubviewToBack(blurView)
        
        faceScanImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        faceScanImageView.contentMode = .scaleAspectFill // OR .scaleAspectFill
        faceScanImageView.clipsToBounds = true
        faceScanImageView.layer.borderWidth = 2
        faceScanImageView.layer.borderColor = appThemeColorCode.cgColor
//        let  image = UIImage.gifImageWithName("FaceScan_Marcela")
//        self.faceScanImageView.image = image
//        
        gotItButton.layer.cornerRadius = buttonRoundCornerValue
        //Checkbox button handling
        checkBoxButton.setImage(UIImage(named: "CheckBoxFilled-g"), for: .selected )
        checkBoxButton.setImage(UIImage(named: "CheckBoxBlank-g"), for: .normal )
        
        if((UserDefaults.standard.object(forKey:"faceScanChcekBoxStatus")) != nil)
        {
            checkBoxButton.isSelected = true
        }
        
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(FaceScanOverlayVC.panGesture))
        view.addGestureRecognizer(gesture)
        
        //Add gesture to view
        let swipeUpView = UITapGestureRecognizer(target: self, action: #selector(self.faceScanTapGestureAction))
        self.sliderView.addGestureRecognizer(swipeUpView)
        
        let tapUpView = UITapGestureRecognizer(target: self, action: #selector(self.faceScanTapGestureAction))
        self.holdView.addGestureRecognizer(tapUpView)
        self.holdView.layer.cornerRadius = self.holdView.frame.size.height / 2
    }
    
    // face scan tap gesture Action
    @objc func faceScanTapGestureAction()
    {
        if  tap == false {
            UIView.animate(withDuration: 0.3, animations: {
                let frame = self.view.frame
                self.view.frame = CGRect(x: 0, y: self.fullView, width: frame.width, height: frame.height)
                self.tap = true
                self.delegate?.setNavigationBarLabel(text: faceScanOverlayTitle)
            })
        }
        else
        {
            gotItButtonAction(self)
        }
    }
    
    //ChceckBox button Action function
    @IBAction func checkBoxButtonAction(_ sender: Any)
    {
        checkBoxButton.isSelected = !checkBoxButton.isSelected
        if(checkBoxButton.isSelected)
        {
            print("Chcek box is selected")
            UserDefaults.standard.set(true, forKey:"faceScanChcekBoxStatus")
        }
        else
        {
            UserDefaults.standard.removeObject(forKey: "faceScanChcekBoxStatus")
            print("Chcek box is Unslected")
        }
    }
    
    //Got it button action
    @IBAction func gotItButtonAction(_ sender: Any)
    {
        UIView.animate(withDuration: 0.3, animations: {
            let frame = self.view.frame
            self.view.frame = CGRect(x: 0, y: self.partialView, width: frame.width, height: frame.height)
            self.tap = false
            self.delegate?.setNavigationBarLabel(text: faceScanTitle)
        })
    }
    
    //Custom Function
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        let velocity = recognizer.velocity(in: self.view)
        let y = self.view.frame.minY
        if ( y + translation.y >= fullView) && (y + translation.y <= partialView ) {
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if recognizer.state == .ended {
            var duration =  velocity.y < 0 ? Double((y - fullView) / -velocity.y) : Double((partialView - y) / velocity.y )
            
            duration = duration > 1.3 ? 1 : duration
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.allowUserInteraction], animations: {
                if  velocity.y >= 0 {
                    self.view.frame = CGRect(x: 0, y: self.partialView, width: self.view.frame.width, height: self.view.frame.height)
                    self.tap = false
                    self.delegate?.setNavigationBarLabel(text: faceScanTitle)
                    
                } else {
                    self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)
                    self.tap = true
                    self.delegate?.setNavigationBarLabel(text: faceScanOverlayTitle)
                }
                
            }, completion: nil)
        }
    }
    
    //function for memory management
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
}
