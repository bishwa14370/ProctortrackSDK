//
//  ArcView.swift
//  ProctorTrack
//
//  Created by Diwakar Garg on 20/02/2019.
//  Copyright © 2019 Diwakar Garg. All rights reserved.
//

import UIKit

class ArcView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        createArc(rect: rect)
    }
    
    private func createArc(rect : CGRect) {
        
        let center = CGPoint(x: rect.width/2, y: rect.height/2)
        let lineWidth : CGFloat = 50.0
        let radius = rect.width / 2 - lineWidth
        let startingAngle = CGFloat(-10.0/180) * CGFloat.pi
        let endingAngle = CGFloat(-80/180.0) * CGFloat.pi
        let bezierPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startingAngle , endAngle: endingAngle, clockwise: false)
        bezierPath.lineWidth = lineWidth
        UIColor(red: 249/255.0, green: 179/255.0, blue: 127/255.0, alpha: 1.0).setStroke()
        bezierPath.stroke()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
