//
//  NewFeedViewController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 11/27/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit
import AVFoundation

class FeedViewCell: UITableViewCell {
    @IBOutlet weak var AuthorView: UIStackView!
    @IBOutlet weak var AuthorImageView: UIImageView!
    @IBOutlet weak var AuthorLabel: UILabel!
    @IBOutlet weak var PlayerView: UIPlayerView!
    @IBOutlet weak var CommentView: UIStackView!
    @IBOutlet weak var ShareView: UIStackView!
    @IBOutlet weak var DescriptionTextView: UITextView!
    @IBOutlet weak var SwipeView: SwipeRateView!
    @IBOutlet weak var VotesLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var CommentCountLabel: UILabel!
    @IBOutlet weak var ShareCountLabel: UILabel!
    
    public var authorID: String!
    public var postID: String!
    public var postURL: URL!
    public var parentController: FeedViewController!
    
    public var isPlaying: Bool = false
    public var isFullscreen: Bool = false
    
    private var hasArrow: Bool = false
    private var arrowLayer: CALayer!
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Style user image
        AuthorImageView.layer.cornerRadius = AuthorImageView.frame.width/2
        AuthorImageView.clipsToBounds = true
        
        // Configure description text view
        DescriptionTextView.textContainer.lineFragmentPadding = 0
        DescriptionTextView.textContainerInset = .zero
        
        // Add tap gesture to video player
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.togglePlayback))
        PlayerView.addGestureRecognizer(tapGesture)
        
        // Add double tap gesture to video player
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.enterFullscreenDisplay))
        doubleTapGesture.numberOfTapsRequired = 2
        PlayerView.addGestureRecognizer(doubleTapGesture)
        tapGesture.require(toFail: doubleTapGesture)
        
        // Add tap gesture to authorView
        let authorTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showUserProfile))
        AuthorView.addGestureRecognizer(authorTapGestureRecognizer)
        
        // Add tap gesture to commentsView
        let commentsTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showPostComments))
        CommentView.addGestureRecognizer(commentsTapGestureRecognizer)
    }
    
    override func layoutSubviews() { //should this be here?
        // Create player and player layer
        player = AVPlayer(url: postURL!)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = PlayerView.bounds
        PlayerView.layer.addSublayer(playerLayer!)
        
        // Add play arrow
        if !hasArrow {
            arrowLayer = CALayer()
            arrowLayer.frame = CGRect(x: UIScreen.main.bounds.width/2 - 16, y: PlayerView.bounds.height/2 - 16, width: 32, height: 32)
            arrowLayer.contents = UIImage(named: "Play")?.cgImage
            PlayerView.layer.addSublayer(arrowLayer)
            hasArrow = true
        }
        
        super.layoutSubviews()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        //Configure swipe view
        SwipeView.parentCell = self
        SwipeView.postID = postID
        
        UserManager.votes(forPost: postID, finished: { (votes) in
            self.SwipeView.currentVotes = votes
            self.SwipeView.reloadVotes()
        })
    }
    
    // MARK: - Playback
    @objc func togglePlayback() {
        if isPlaying {
            pauseVideo()
        } else {
            playVideo()
        }
    }
    
    func playVideo() {
        if !isPlaying {
            // Stop all other videos
            //parentController.stopAllVideos()
            
            // Enable looping
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem, queue: nil, using: { (_) in
                DispatchQueue.main.async {
                    self.player?.seek(to: kCMTimeZero)
                    self.player?.play()
                }
            })
            
            // Begin playback
            arrowLayer.isHidden = true
            player!.play()
            isPlaying = true
        }
    }
    
    public func pauseVideo() {
        arrowLayer.isHidden = false
        player?.pause()
        isPlaying = false
    }
    
    // MARK: - Handle Buttons
    @objc public func showUserProfile() {
        // Prepare selected user profile
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "Profile") as! NewProfileViewController
        userProfileVC.userID = authorID
        
        // Present user profile
        parentController.navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    @objc public func showPostComments() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let commentsVC = storyboard.instantiateViewController(withIdentifier: "Comments") as! CommentsViewController
        commentsVC.postID = postID
        parentController.navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    // MARK: - Toggle Fullscreen
    
    @objc func enterFullscreenDisplay() {
        let window = UIApplication.shared.keyWindow!
        
        let fullScreenView = FullscreenView(contentLayer: playerLayer!)
        fullScreenView.tag = 1
        fullScreenView.backgroundColor = UIColor.black
        
        window.addSubview(fullScreenView)
        fullScreenView.translatesAutoresizingMaskIntoConstraints = false
        fullScreenView.topAnchor.constraint(equalTo: window.topAnchor).isActive = true
        fullScreenView.leadingAnchor.constraint(equalTo: window.leadingAnchor).isActive = true
        fullScreenView.trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true
        fullScreenView.bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true
        
        // Add tap gesture to video player
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.togglePlayback))
        fullScreenView.addGestureRecognizer(tapGesture)
        
        // Add double tap gesture to video player
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(removeFullScreenView))
        doubleTapGesture.numberOfTapsRequired = 2
        fullScreenView.addGestureRecognizer(doubleTapGesture)
        tapGesture.require(toFail: doubleTapGesture)
        
        /*
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(removeFullScreenView))
        doubleTapGesture.numberOfTapsRequired = 2
        fullScreenView.addGestureRecognizer(doubleTapGesture)
        */
        
        playVideo()
        
        // Enable rotation
        (UIApplication.shared.delegate as! AppDelegate).isRotationAllowed = true
    }
    
    @objc func removeFullScreenView() {
        let window = UIApplication.shared.keyWindow!
        window.viewWithTag(1)?.removeFromSuperview()
        
        // This allows us to make changes to layers without implicit animations
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        playerLayer?.frame = PlayerView.bounds
        PlayerView.layer.addSublayer(playerLayer!)
        PlayerView.layer.addSublayer(arrowLayer)
        CATransaction.commit()
        
        // Disable rotation
        (UIApplication.shared.delegate as! AppDelegate).isRotationAllowed = false
    }
    
    func rotatePlayerLayer() {
        playerLayer?.frame = viewWithTag(1)!.bounds
    }
    
    override func prepareForReuse() {
        // Reset dynamic components
        hasArrow = false
        AuthorImageView.image = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player = nil
        
        super.prepareForReuse()
    }
}

class FeedViewController: UITableViewController {

    public var posts = [Post]()
    
    public var userID: String?
    public var rowToScrollTo: Int?
    private var hasScrolled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Load either posts from given user or default to main feed
        if userID != nil {
            PostManager.loadPosts(fromUser: userID!, finished: { (posts) in
                self.posts.append(contentsOf: posts)
                self.tableView.reloadData()
            })
            
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
        } else {
            PostManager.loadFeedPosts(finished: { (posts) in
                self.posts.append(contentsOf: posts)
                self.tableView.reloadData()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Style nav bar
        let bounds = self.navigationController!.navigationBar.bounds
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + 128)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Futura", size: 28.0)!, NSAttributedStringKey.foregroundColor: UIColor.white]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !hasScrolled {
            if let row = rowToScrollTo {
                if tableView.numberOfRows(inSection: 0) > 0 {
                    tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .middle, animated: false)
                    hasScrolled = true
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedViewCell
        let post = posts[indexPath.row]
        
        // Configure the cell
        cell.authorID = post.userID
        cell.postID = post.ID
        cell.postURL = post.url!
        cell.parentController = self
        
        // Set name label
        if post.userName != nil {
            cell.AuthorLabel.text = post.userName
        } else {
            let index = indexPath.row
            UserManager.name(forID: post.userID) { (name) in
                cell.AuthorLabel.text = name
                self.posts[index].userName = name
            }
        }
        
        // Set user image
        if post.downloadedUserImageView != nil {
            cell.AuthorImageView.image = post.downloadedUserImageView!.image
        } else {
            let index = indexPath.row
            UserManager.imageURL(forUserID: post.userID, result: { (photoURL) in
                if let url = photoURL {
                    cell.AuthorImageView.downloadedFrom(url: url)
                    self.posts[index].downloadedUserImageView = UIImageView()
                    self.posts[index].downloadedUserImageView!.downloadedFrom(url: url)
                } else {
                    cell.AuthorImageView.image = UIImage(named: "User Placeholder")
                    self.posts[index].downloadedUserImageView = UIImageView()
                    self.posts[index].downloadedUserImageView!.image = UIImage(named: "User Placeholder")
                }
            })
        }
        
        // Update post statistic labels and description
        cell.DescriptionTextView.text = post.description
        cell.VotesLabel.text = "\(post.votes)"
        cell.DateLabel.text = "\(post.postDate.toString(dateFormat: "MMM dd, YYYY"))"
        cell.CommentCountLabel.text = "\(post.commentCount)"
        cell.ShareCountLabel.text = "\(post.shareCount)"

        return cell
    }
    
    // MARK: - Handle rotation
    //private var isPortrait
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if tabBarController?.selectedIndex == 0 {
            for cell in tableView.visibleCells {
                if cell.viewWithTag(1) != nil {
                    (cell as! FeedViewCell).rotatePlayerLayer()
                }
            }
        }
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
