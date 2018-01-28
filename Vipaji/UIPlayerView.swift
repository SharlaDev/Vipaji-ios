//
//  UIPlayerView.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 1/24/18.
//  Copyright © 2018 AndresGutierrez. All rights reserved.
//

import UIKit

class UIPlayerView: UIView {

    var voteView = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addConstrainedSubview(subview: voteView)
        
        // Enable Swipe Gestures
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(UIPlayerView.voteDown))
        leftSwipeGesture.direction = .left
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(UIPlayerView.voteUp))
        rightSwipeGesture.direction = .right
        
        self.addGestureRecognizer(leftSwipeGesture)
        self.addGestureRecognizer(rightSwipeGesture)
    }
    
    // MARK: - Handle Voting
    
    @objc func voteUp() {
        voteView.backgroundColor = .green
        flashVotedOverlay()
    }
    
    @objc func voteDown() {
        voteView.backgroundColor = .red
        flashVotedOverlay()
    }
    
    // MARK: - Animation
    
    func flashVotedOverlay() {
        let duration = 0.15
        
        UIView.animate(withDuration: duration, animations: {
            self.voteView.alpha = 1.0
        }) { (completed) in
            UIView.animate(withDuration: duration, animations: {
                self.voteView.alpha = 0.0
            })
        }
    }
    
    // MARK: - Configure Subview
    func addConstrainedSubview(subview: UIView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        subview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        subview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
