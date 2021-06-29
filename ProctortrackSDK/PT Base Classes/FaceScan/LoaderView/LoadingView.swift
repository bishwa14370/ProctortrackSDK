//
//  LoadingView.swift
//  ProctorTrack
//
//  Created by Diwakar Garg on 30/05/2019.
//  Copyright © 2019 Diwakar Garg. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
class LoadingView {
    
    let uiView          :   UIView
    let message         :   String
    let messageLabel    =   UILabel()
    
    let loadingView     =   UIView()
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
    
    init(uiView: UIView, message: String) {
        self.uiView     =   uiView
        self.message    =   message
        self.setup()
    }
    
    func setup(){
        loadingView.frame           = uiView.frame
        loadingView.center          = uiView.center
        loadingView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.95)
        uiView.addSubview(loadingView)
        
        messageLabel.text             = message
        messageLabel.textColor        = UIColor.white
        messageLabel.textAlignment    = .center
        messageLabel.numberOfLines    = 3
        messageLabel.lineBreakMode    = .byWordWrapping
        messageLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
        messageLabel.center = loadingView.center
        loadingView.addSubview(messageLabel)
    }
    
    // Call this method to hide loadingView
    func show() {
        loadingView.isHidden = false
    }
    
    // Call this method to show loadingView
    func hide(){
        loadingView.isHidden = true
    }
    
    // Call this method to check if loading view already exists
    func isHidden() -> Bool{
        if loadingView.isHidden == false{
            return false
        }
        else{
            return true
        }
    }
}
