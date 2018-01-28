//
//  UIRecordButton.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 10/26/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit

class UIRecordButton: UIButton {

    public var isRecording: Bool = false
    public var maxRecordLength: Int = 15
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        drawNormalState()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        drawNormalState()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
    }
    */
    
    func drawNormalState() {
        // Make the button circular
        layer.cornerRadius = frame.width/2
        clipsToBounds = true
        
        // Draw not recording state
        backgroundColor = UIColor.red
        layer.borderWidth = 4
        layer.borderColor = UIColor.white.cgColor
        
        
        /*
        // Overlay red circle
        let redCircle = UIButton(frame: CGRect(x: 4, y: 4, width: frame.width - 8, height: frame.width - 8))
        redCircle.layer.cornerRadius = redCircle.frame.width/2
        redCircle.clipsToBounds = true
        redCircle.backgroundColor = UIColor.red
        redCircle.target(forAction: #selector(self.targ), withSender: <#T##Any?#>)
        
        addSubview(redCircle)
 */
    }

}
