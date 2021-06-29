//
//  IDScanOverlayVC.swift
//   ProctorTrack
//
//  Created by Diwakar Garg on 28/01/2019.
//  Copyright © 2017 Diwakar Garg. All rights reserved.
//

import UIKit

protocol IDScanOverlayDelegate {
    func setNavigationBarLabel(text: String)
}

class IDScanOverlayVC: UIViewController {
    var shadowView: UIView!
    @IBOutlet weak var idScanImageView: UIImageView!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var gotItButton: UIButton!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var holdView: UIView!
    var delegate: IDScanOverlayDelegate?
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
            let finalMessage = kibanaPrefix + "event:IDscan_Overlay_start"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    //View will appear function
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.viewStyleMethod()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:IDscan_Overlay_end"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    //Custom View style function
    func viewStyleMethod ()
    {
        // Blur effect to background view
        let effect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: effect)
        blurView.frame = self.view.bounds
        self.view.addSubview(blurView)
        self.view.sendSubviewToBack(blurView)
        
        if( "6And7" == deviceSize())
        {
            shadowView = UIView(frame: CGRect(x: idScanImageView.frame.origin.x + 10, y: idScanImageView.frame.origin.y + 70 , width: idScanImageView.frame.size.width , height: idScanImageView.frame.size.height))
        }
        else if ("6And7Plus" == deviceSize())
        {
            shadowView = UIView(frame: CGRect(x: idScanImageView.frame.origin.x + 10 , y: idScanImageView.frame.origin.y + 90, width: idScanImageView.frame.size.width + 50 , height: idScanImageView.frame.size.height + 30))
        }
        else if ("X" == deviceSize())
        {
            shadowView = UIView(frame: CGRect(x: idScanImageView.frame.origin.x + 10 , y: idScanImageView.frame.origin.y + 135, width: idScanImageView.frame.size.width  , height: idScanImageView.frame.size.height ))
        }
        else
        {
            shadowView = UIView(frame: CGRect(x: idScanImageView.frame.origin.x + 10, y: idScanImageView.frame.origin.y + 30, width: idScanImageView.frame.size.width - 50, height: idScanImageView.frame.size.height - 30))
        }
        
        shadowView.dropShadow(color: .black, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
        self.view.addSubview(shadowView)
        self.view.sendSubviewToBack(shadowView)
        
        idScanImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        idScanImageView.contentMode = .scaleAspectFill // OR .scaleAspectFill
        idScanImageView.clipsToBounds = true
        idScanImageView.layer.borderWidth = 2
        idScanImageView.layer.borderColor = appThemeColorCode.cgColor
        
        gotItButton.layer.cornerRadius = buttonRoundCornerValue
        //Checkbox button handling
        checkBoxButton.setImage(UIImage(named: "CheckBoxFilled-g"), for: .selected )
        checkBoxButton.setImage(UIImage(named: "CheckBoxBlank-g"), for: .normal )
        if((UserDefaults.standard.object(forKey:"idScanChcekBoxStatus")) != nil)
        {
            checkBoxButton.isSelected = true
        }
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(IDScanOverlayVC.panGesture))
        view.addGestureRecognizer(gesture)
        
        //Add gesture to view
        let swipeUpView = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureAction))
        self.sliderView.addGestureRecognizer(swipeUpView)
        
        let tapUpView = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureAction))
        self.holdView.addGestureRecognizer(tapUpView)
        self.holdView.layer.cornerRadius = self.holdView.frame.size.height / 2
    }
    
    // tap gesture Action
    @objc func tapGestureAction()
    {
        if  tap == false {
            UIView.animate(withDuration: 0.3, animations: {
                let frame = self.view.frame
                self.view.frame = CGRect(x: 0, y: self.fullView, width: frame.width, height: frame.height)
                self.tap = true
                self.delegate?.setNavigationBarLabel(text: idScanOverlayTitle)
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
            print("@objc Chcek box is selected")
            UserDefaults.standard.set(true, forKey:"idScanChcekBoxStatus")
        }
        else
        {
            UserDefaults.standard.removeObject(forKey: "idScanChcekBoxStatus")
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
            self.delegate?.setNavigationBarLabel(text: idScanTitle)
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
                    self.delegate?.setNavigationBarLabel(text: idScanTitle)
                    
                } else {
                    self.view.frame = CGRect(x: 0, y: self.fullView, width: self.view.frame.width, height: self.view.frame.height)
                    self.tap = true
                    self.delegate?.setNavigationBarLabel(text: idScanOverlayTitle)
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
extension UIView
{
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
}
