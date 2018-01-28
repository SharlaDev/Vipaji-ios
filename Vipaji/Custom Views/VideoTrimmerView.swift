//
//  VideoTrimmerView.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 11/29/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit

class VideoTrimmerView: UIView {

    public var playerView: UIView?
    public var startBar: UIView!
    public var endBar: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = .black
        
        initSubviews()
    }
    
    func initSubviews() {
        // Create white bar view
        let barView = UIView(frame: CGRect(x: 13, y: 4, width: 6, height: frame.height + 8))
        barView.tag = 1
        barView.backgroundColor = .white
        barView.layer.cornerRadius = 3
        
        // Configure Views
        startBar = UIView()
        startBar.addSubview(barView)
        addSubview(startBar)
        
        endBar = UIView()
        endBar.addSubview(barView)
        addSubview(endBar)
        
        // Add pan gesture recognizer
        let startDragGesture = UIPanGestureRecognizer(target: self, action: #selector(handleLeftPan))
        startBar.addGestureRecognizer(startDragGesture)
        let endDragGesture = UIPanGestureRecognizer(target: self, action: #selector(handleRightPan))
        endBar.addGestureRecognizer(endDragGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        startBar.frame = CGRect(x: -13, y: -8, width: 32, height: frame.height + 16)
        endBar.frame = CGRect(x: frame.width - 13, y: -8, width: 32, height: frame.height + 16)
    }
    
    // MARK: -  Slide Gestures
    @objc func handleLeftPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        print("Left Drag me!")
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self)
            let newX = gestureRecognizer.view!.center.x + translation.x
            
            if newX < 0 {
                gestureRecognizer.view!.center = CGPoint(x: 0, y: gestureRecognizer.view!.center.y)
            } else {
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y)
            }
            
            gestureRecognizer.setTranslation(CGPoint.zero, in: self)
        } else {
            print("finished dragging")
        }
        
    }
    
    @objc func handleRightPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        print("Right Drag me!")
        
        //UIView.animate(withDuration: <#T##TimeInterval#>, animations: <#T##() -> Void#>, completion: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self)
            let newX = gestureRecognizer.view!.center.x + translation.x
            
            if newX > self.frame.width {
                gestureRecognizer.view!.center = CGPoint(x: self.frame.width, y: gestureRecognizer.view!.center.y)
            } else {
                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y)
            }
            
            gestureRecognizer.setTranslation(CGPoint.zero, in: self)
        } else {
            print("finished dragging")
        }
        
    }

}
