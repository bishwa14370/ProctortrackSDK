//
//  IdentityVerificationVC.swift
//   ProctorTrack
//
//  Created by Diwakar Garg on 28/01/2019.
//  Copyright © 2017 Diwakar Garg. All rights reserved.
//

import UIKit

class IdentityVerificationVC: UIViewController {
    
    var navigationBarTitle : UILabel?
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var allowButton: UIButton?
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
  
    
    
    //outlets for the configurable view for scan type
    
    @IBOutlet weak var numberLabel1: UILabel!
    @IBOutlet weak var numberLabel2: UILabel!
    @IBOutlet weak var numberLabel3: UILabel!
    
    @IBOutlet weak var scanNameLabel1: UILabel!
    @IBOutlet weak var scanNameLabel2: UILabel!
    @IBOutlet weak var scanNameLabel3: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(kibanaLogEnable == true)
        {
            let finalMessage = kibanaPrefix + "event:IdentityVerificationVC_start"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    //View will appear function
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.setConfigurableLabelsForScans()
        self.viewStyleMethod()
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
            let finalMessage = kibanaPrefix + "event:IdentityVerificationVC_end"
            NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
        }
    }
    
    
    func setConfigurableLabelsForScans()
    {

        if(faceScanRequired == true && photoIdRequired == true && roomScanRequired == true)
        {
            numberLabel1.isHidden = false
            numberLabel1.text = "1."
            numberLabel2.isHidden = false
            numberLabel2.text = "2."
            numberLabel3.isHidden = false
            numberLabel3.text = "3."
            
            scanNameLabel1.isHidden = false
            scanNameLabel1.text = "Face Scan"
            scanNameLabel2.isHidden = false
            scanNameLabel2.text =   "ID Scan"
            scanNameLabel3.isHidden = false
            scanNameLabel3.text = "Room Scan"
            titleLabel.text = "Proctortrack requires three steps verification."
        }
        else  if(faceScanRequired == true && photoIdRequired == false && roomScanRequired == true)
        {
            numberLabel1.isHidden = false
            numberLabel1.text = "1."
            numberLabel2.isHidden = false
            numberLabel2.text = "2."
            numberLabel3.isHidden = true
            numberLabel3.text = ""
            
            scanNameLabel1.isHidden = false
            scanNameLabel1.text = "Face Scan"
            scanNameLabel2.isHidden = false
            scanNameLabel2.text =   "Room Scan"
            scanNameLabel3.isHidden = true
            scanNameLabel3.text = ""
             titleLabel.text = "Proctortrack requires two steps verification."
            
        }
        else  if(faceScanRequired == true && photoIdRequired == true && roomScanRequired == false)
        {
            numberLabel1.isHidden = false
            numberLabel1.text = "1."
            numberLabel2.isHidden = false
            numberLabel2.text = "2."
            numberLabel3.isHidden = true
            numberLabel3.text = ""
            
            scanNameLabel1.isHidden = false
            scanNameLabel1.text = "Face Scan"
            scanNameLabel2.isHidden = false
            scanNameLabel2.text =   "ID Scan"
            scanNameLabel3.isHidden = true
            scanNameLabel3.text = ""
            titleLabel.text = "Proctortrack requires two steps verification."
            
        }
        else  if(faceScanRequired == true && photoIdRequired == false && roomScanRequired == false)
        {
            numberLabel1.isHidden = false
            numberLabel1.text = "1."
            numberLabel2.isHidden = true
            numberLabel2.text = ""
            numberLabel3.isHidden = true
            numberLabel3.text = ""
            
            scanNameLabel1.isHidden = false
            scanNameLabel1.text = "Face Scan"
            scanNameLabel2.isHidden = true
            scanNameLabel2.text =   ""
            scanNameLabel3.isHidden = true
            scanNameLabel3.text = ""
             titleLabel.text = "Proctortrack requires one step verification."
            
        }
        else  if(faceScanRequired == false && photoIdRequired == true && roomScanRequired == true)
        {
            numberLabel1.isHidden = false
            numberLabel1.text = "1."
            numberLabel2.isHidden = false
            numberLabel2.text = "2."
            numberLabel3.isHidden = true
            numberLabel3.text = ""
            
            scanNameLabel1.isHidden = false
            scanNameLabel1.text = "ID Scan"
            scanNameLabel2.isHidden = false
            scanNameLabel2.text = "Room Scan"
            scanNameLabel3.isHidden = true
            scanNameLabel3.text = ""
            titleLabel.text = "Proctortrack requires two steps verification."
        }
         else  if(faceScanRequired == false && photoIdRequired == false && roomScanRequired == true)
        {
            numberLabel1.isHidden = false
            numberLabel1.text = "1."
            numberLabel2.isHidden = true
            numberLabel2.text = ""
            numberLabel3.isHidden = true
            numberLabel3.text = ""
            
            scanNameLabel1.isHidden = false
            scanNameLabel1.text = "Room Scan"
            scanNameLabel2.isHidden = true
            scanNameLabel2.text =   ""
            scanNameLabel3.isHidden = true
            scanNameLabel3.text = ""
            titleLabel.text = "Proctortrack requires one step verification."
        }else  if(faceScanRequired == false && photoIdRequired == true && roomScanRequired == false)
        {
            numberLabel1.isHidden = false
            numberLabel1.text = "1."
            numberLabel2.isHidden = true
            numberLabel2.text = ""
            numberLabel3.isHidden = true
            numberLabel3.text = ""
            
            scanNameLabel1.isHidden = false
            scanNameLabel1.text = "ID Scan"
            scanNameLabel2.isHidden = true
            scanNameLabel2.text =   ""
            scanNameLabel3.isHidden = true
            scanNameLabel3.text = ""
            titleLabel.text = "Proctortrack requires one step verification."
        }
        else
        {
            numberLabel1.isHidden = true
            numberLabel1.text = ""
            numberLabel2.isHidden = true
            numberLabel2.text = ""
            numberLabel3.isHidden = true
            numberLabel3.text = ""
            
            scanNameLabel1.isHidden = true
            scanNameLabel1.text = ""
            scanNameLabel2.isHidden = true
            scanNameLabel2.text =   ""
            scanNameLabel3.isHidden = true
            scanNameLabel3.text = ""
              titleLabel.text = "Proctortrack does not requires any verification."
        }
        
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
        navigationBarTitle = UILabel(frame: CGRect(x: 0, y: 0.0, width: self.view.frame.width , height: customView.frame.height))
        navigationBarTitle?.text = identityVerificationTitle
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
  fileprivate  func viewStyleMethod ()
    {
        contentView.dropShadow()
        checkBoxButton.setImage(UIImage(named: "CheckBoxFilled-g"), for: .selected )
        checkBoxButton.setImage(UIImage(named: "CheckBoxBlank-g"), for: .normal )
        if((UserDefaults.standard.object(forKey:"identityVerificationStatus")) != nil)
        {
            checkBoxButton.isSelected = true
        }
        self.navigationBarAddMethod()
    }
    
    //ChcekBox Button Action function
    @IBAction func checkBoxButtonAction(_ sender: Any)
    {
        checkBoxButton.isSelected = !checkBoxButton.isSelected
        if(checkBoxButton.isSelected)
        {
            print("Chcek box is selected")
            UserDefaults.standard.set(true, forKey:"identityVerificationStatus")
        }
        else
        {
            UserDefaults.standard.removeObject(forKey: "identityVerificationStatus")
            print("Chcek box is Unslected")
        }
        
    }
    
    //Function for allow button Action
    @IBAction func allowButtonAction(_ sender: Any) {
       self.navigateToScreenAccordingToConfiguration()
    }
    
    func navigateToScreenAccordingToConfiguration()
    {
        if(faceScanRequired == true)
        {
            performSegue(withIdentifier: faceScanSegue, sender: self)
        }
        else if(photoIdRequired == true)
        {
                    let moveVC = self.storyboard?.instantiateViewController(withIdentifier: idScanViewController) as! IDScanVC
                    self.navigationController?.pushViewController(moveVC, animated: true)
        }
        else if(roomScanRequired == true)
        {
                    let moveVC = self.storyboard?.instantiateViewController(withIdentifier: roomScanViewController) as! RoomScanNewVC
                    self.navigationController?.pushViewController(moveVC, animated: true)
        }
        else
        {
            let moveVC = self.storyboard?.instantiateViewController(withIdentifier: verificationCompletedScreen) as! VerificationCompletedVC
            self.navigationController?.pushViewController(moveVC, animated: true)
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
extension UIView {
    
    func dropShadow(scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 10
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
