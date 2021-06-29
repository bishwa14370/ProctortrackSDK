//
//  SystemCheckAlertView.swift
//  Proctorscreen
//
//  Created by Diwakar Garg on 18/08/17.
//  Copyright © 2017 Diwakar Garg. All rights reserved.
//

import UIKit

class SystemCheckAlertView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
   
    @IBAction func startButtonAction(_ sender: Any) {
        if(kibanaLogEnable == true)
                          {
                              let finalMessage = kibanaPrefix + "event:SystemCheckAlertView_Start_Button_Clicked"
                              NetworkingClass.submitKibanaLogApiCallFromNative(message: finalMessage, level: kibanaLevelName)
                                                                          
                          }
            let notificationName = Notification.Name(startButtonClickNotificationSystemCheck)
            // Post notification
            NotificationCenter.default.post(name: notificationName, object: nil)
    }
     
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
