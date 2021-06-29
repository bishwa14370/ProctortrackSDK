//
//  NotificationManager.swift
//   ProctorTrack
//
//  Created by Diwakar Garg on 28/01/2019.
//  Copyright © 2017 Diwakar Garg. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationManager: NSObject,UNUserNotificationCenterDelegate {
    
    //Local Notification Category setting
    struct Notification {
        
        struct Category {
            static let monitoringTest = "monitoringTest"
        }
        
        struct Action {
            static let resume = "Resume"
            static let cancel = "Cancel"
        }
    }
    
    
    //Local Notification permission Setting
    class func permissionForLocalNotification()
    {
        if #available(iOS 10.0, *)
        {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {(accepted, error) in
                
                if !accepted
                {
                    print("Notification access denied.")
                    
                }
            }
        }
        else
        {
            // ios 9 and below
            let notificationTypes: UIUserNotificationType
            notificationTypes = [.alert , .sound, .badge]
            
            let newNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
            
            UIApplication.shared.registerUserNotificationSettings(newNotificationSettings)
        }
    }
    
    //show the notification if user switch the app from app deleegate
    class func scheduleLocalNotification() {
        if ((UserDefaults.standard.string(forKey:sessionApiState)) != nil)
        {
            if ((UserDefaults.standard.object(forKey: sessionApiState)) as! String == "Start")
            {
                    // Configure User Notification Center
                    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
                    
                    // Define Actions
                    let actionShowDetails = UNNotificationAction(identifier: Notification.Action.resume, title: "Resume Test", options: [.foreground])
                    let actionCancel = UNNotificationAction(identifier: Notification.Action.cancel, title: "Cancel", options: [.destructive, .authenticationRequired])
                    
                    // Define Category
                    let monitoringCategory = UNNotificationCategory(identifier: Notification.Category.monitoringTest, actions:  [actionShowDetails, actionCancel], intentIdentifiers: [], options: [])
                    
                    // Register Category
                    UNUserNotificationCenter.current().setNotificationCategories([monitoringCategory])
                    
                    // Create Notification Content
                    let notificationContent = UNMutableNotificationContent()
                    
                    // Configure Notification Content
                    notificationContent.title = "Proctortrack Device Monitoring"
                    // notificationContent.subtitle = "Local Notifications"
                    notificationContent.body = "Please resume the Proctortrack App, otherwise it will be marked as a violation in 1 minute."
                    
                    // Set Category Identifier
                    notificationContent.categoryIdentifier = Notification.Category.monitoringTest
                
                    // Add Trigger
                    let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 01.0, repeats: false)

                    // Create Notification Request
                    let notificationRequest = UNNotificationRequest(identifier: "cocoacasts_local_notification", content: notificationContent, trigger: notificationTrigger)

                    // Add Request to User Notification Center
                    UNUserNotificationCenter.current().add(notificationRequest) { (error) in
                        if let error = error {
                            print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                        }
                    }
            }
        }
    }
    
    
  class func scheduleNotificationForEveryMinute()
    {
        self.scheduleLocalNotification()
        let n = scheduleTimeForBackgroundNotify
        print("integer conversion",n)
        for i in 1...n {
            print("For Loop Value",i)
            let timeIntervalValue =  minute * TimeInterval(i)
            
         self.setNotificationForMonitoring(time: timeIntervalValue, identifier: "Notification\(i)")
        }

    }
  

    //Remove notification method
    class func removeNotification()
    {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
            // or you can remove specifical notification:
            // center.removePendingNotificationRequests(withIdentifiers: ["triggerNotificationIdentifier"])
        } else {
            UIApplication.shared.cancelAllLocalNotifications()
            // Fallback on earlier versions
        }
        
    }
    // Notification trigger when start and end Upload chunks while app is in forground
    class func uploadStartAndUploadCompleteTriggerNotification(notificationMessage:String, notificationTitle:String)
    {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: notificationTitle, arguments: nil)
            print("Notifiation message which is triggered",notificationMessage)
            content.body = NSString.localizedUserNotificationString(forKey: notificationMessage , arguments: nil)
            content.sound = UNNotificationSound.default
            
//            content.badge = NSNumber(integerLiteral: UIApplication.shared.applicationIconBadgeNumber + 1);
            content.categoryIdentifier = "alarmTrigger"
//            content.setValue(true, forKey: "shouldAlwaysAlertWhileAppIsForeground")
            // Deliver the notification in five seconds.
            /**** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'time interval must be at least 60 if repeating'*/
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "startAndCompleteNotification", content: content, trigger: trigger)
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request){ (error:Error?) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }
                print("Notification Register Success")
            }
        }
        else {
            // ios 9
            let notification = UILocalNotification()
            print("Notifiation message which is triggered",notificationMessage)
            notification.alertBody = notificationMessage
            notification.soundName = UILocalNotificationDefaultSoundName
            if #available(iOS 8.2, *) {
                notification.alertTitle =  notificationTitle
            } else {
                notification.userInfo = ["Title": notificationTitle ]
                // Fallback on earlier versions
            }
            notification.fireDate = NSDate(timeIntervalSinceNow: 1) as Date
//            notification.applicationIconBadgeNumber = UIApplication.shared.scheduledLocalNotifications!.count
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    //Add multiple notification for particular time period.
   class func setNotification (time : TimeInterval,identifier : String,notificationMessage:String, notificationTitle:String)
    {
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: notificationTitle, arguments: nil)
            print("Notifiation message which is triggered",notificationMessage)
            content.body = NSString.localizedUserNotificationString(forKey: notificationMessage , arguments: nil)
            content.sound = UNNotificationSound.default
            
            //            content.badge = NSNumber(integerLiteral: UIApplication.shared.applicationIconBadgeNumber + 1);
            content.categoryIdentifier = "alarmTrigger"
            // Deliver the notification in five seconds.
            /**** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'time interval must be at least 60 if repeating'*/
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request){ (error:Error?) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }
                print("Notification Register Success")
            }
        }
        else {
            // ios 9
            let notification = UILocalNotification()
            print("Notifiation message which is triggered",notificationMessage)
            notification.alertBody = notificationMessage
            notification.soundName = UILocalNotificationDefaultSoundName
            if #available(iOS 8.2, *) {
                notification.alertTitle =  notificationTitle
            } else {
                notification.userInfo = ["Title": notificationTitle ]
                // Fallback on earlier versions
            }
            notification.fireDate = NSDate(timeIntervalSinceNow: time) as Date
            //            notification.applicationIconBadgeNumber = UIApplication.shared.scheduledLocalNotifications!.count
            UIApplication.shared.scheduleLocalNotification(notification)
        }
    }
    
    
    //Add multiple notification for particular time period.
    class func setNotificationForMonitoring(time : TimeInterval,identifier : String)
    {
        if ((UserDefaults.standard.string(forKey:sessionApiState)) != nil)
        {
            if ((UserDefaults.standard.object(forKey: sessionApiState)) as! String == "Start")
            {
                // Configure User Notification Center
                UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
                
                // Define Actions
                let actionShowDetails = UNNotificationAction(identifier: Notification.Action.resume, title: "Resume Test", options: [.foreground])
                let actionCancel = UNNotificationAction(identifier: Notification.Action.cancel, title: "Cancel", options: [.destructive, .authenticationRequired])
                
                // Define Category
                let monitoringCategory = UNNotificationCategory(identifier: Notification.Category.monitoringTest, actions:  [actionShowDetails, actionCancel], intentIdentifiers: [], options: [])
                
                // Register Category
                UNUserNotificationCenter.current().setNotificationCategories([monitoringCategory])
                
                // Create Notification Content
                let notificationContent = UNMutableNotificationContent()
                
                // Configure Notification Content
                notificationContent.title = "Proctortrack Device Monitoring"
                // notificationContent.subtitle = "Local Notifications"
                notificationContent.body = "Please resume the Proctortrack App, otherwise it will be marked as a violation in 1 minute."
                
                
                // Set Category Identifier
                notificationContent.categoryIdentifier = Notification.Category.monitoringTest
                
                // Add Trigger
                let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
                
                // Create Notification Request
                let notificationRequest = UNNotificationRequest(identifier: identifier , content: notificationContent, trigger: notificationTrigger)
                
                // Add Request to User Notification Center
                UNUserNotificationCenter.current().add(notificationRequest) { (error) in
                    if let error = error {
                        print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
                    }
                }
            }
        }
    }
}

