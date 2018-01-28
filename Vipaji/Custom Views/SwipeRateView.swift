//
//  RateView.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 11/20/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit
import Shimmer

class SwipeRateView: UIView {
    public var parentCell: FeedViewCell?
    public var postID: String!
    public var currentVotes: Int = 0
    public var newVotes: Int = 0
    public var isVotesUpdated: Bool = true
    
    private var downVoteBox: UILabel = UILabel()
    private var upVoteBox: UILabel = UILabel()
    private var shimmeringLabel: UILabel = UILabel()
    private var shimmerView: FBShimmeringView = FBShimmeringView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
    }
    
    func initView() {
        // Prepare view
        frame = CGRect(x: -80, y: frame.origin.y, width: UIScreen.main.bounds.width + 128, height: 64)
        backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.0)
        
        // Prepare subviews
        shimmeringLabel.text = "swipe to vote"
        shimmeringLabel.textColor = .white
        shimmeringLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        shimmeringLabel.textAlignment = .center
        
        shimmerView.contentView = shimmeringLabel
        shimmerView.isShimmering = true
        
        upVoteBox.text = "+1"
        upVoteBox.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        upVoteBox.textAlignment = .center
        upVoteBox.textColor = .white
        upVoteBox.backgroundColor = .green
        
        downVoteBox.text = "-1"
        downVoteBox.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        downVoteBox.textAlignment = .center
        downVoteBox.textColor = .white
        downVoteBox.backgroundColor = .red
        
        // Add subviews
        addSubview(shimmerView)
        addSubview(upVoteBox)
        addSubview(downVoteBox)
        
        // Add gesture recognizers
        let upVoteSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(SwipeRateView.upVote))
        upVoteSwipeGesture.direction = .right
        
        let downVoteSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(SwipeRateView.downVote))
        downVoteSwipeGesture.direction = .left
        
        addGestureRecognizer(upVoteSwipeGesture)
        addGestureRecognizer(downVoteSwipeGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shimmerView.frame = bounds
        shimmeringLabel.frame = shimmerView.bounds
        upVoteBox.frame = CGRect(x: -80, y: 0, width: 80, height: frame.height)
        downVoteBox.frame = CGRect(x: frame.width, y: 0, width: 80, height: frame.height)
    }
    
    // MARK: - Handle Votes
    
    @objc func upVote() {
        if currentVotes + newVotes < 3 {
            // Batch vote updates
            newVotes += 1
            isVotesUpdated = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: updateVotes)
        
            let totalVotes = currentVotes + newVotes
            if totalVotes > 0 {
                shimmeringLabel.text = "+\(totalVotes)"
            } else if totalVotes == 0 {
                shimmeringLabel.text = "swipe to vote"
            } else {
                shimmeringLabel.text = "\(totalVotes)"
            }
            
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
                self.frame.origin.x += 80
            }, completion: { (completed) in
                UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
                    self.frame.origin.x -= 80
                }, completion: { (completed) in
                    if self.parentCell != nil {
                        let voteCount = Int(self.parentCell!.VotesLabel.text!)! + 1
                        self.parentCell!.VotesLabel.text = "\(voteCount)"
                    }
                })
            })
        }
    }
    
    @objc func downVote() {
        if currentVotes + newVotes > -3 {
            // Batch vote updates
            newVotes -= 1
            isVotesUpdated = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: updateVotes)
            
            let totalVotes = currentVotes + newVotes
            if totalVotes > 0 {
                shimmeringLabel.text = "+\(totalVotes)"
            } else if totalVotes == 0 {
                shimmeringLabel.text = "swipe to vote"
            } else {
                shimmeringLabel.text = "\(totalVotes)"
            }
            
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
                self.frame.origin.x -= 80
            }, completion: { (completed) in
                UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
                    self.frame.origin.x += 80
                }, completion: { (completed) in
                    if self.parentCell != nil {
                        let voteCount = Int(self.parentCell!.VotesLabel.text!)! - 1
                        self.parentCell!.VotesLabel.text = "\(voteCount)"
                    }
                })
            })
        }
    }
    
    func updateVotes() {
        if !isVotesUpdated {
            PostManager.updateVotes(forPostID: postID, currentUserVotes: currentVotes, newVotes: newVotes)
            currentVotes += newVotes
            newVotes = 0
            isVotesUpdated = true
        }
    }
    
    func reloadVotes() {
        if currentVotes > 0 {
            shimmeringLabel.text = "+\(currentVotes)"
        } else if currentVotes < 0 {
            shimmeringLabel.text = "\(currentVotes)"
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
