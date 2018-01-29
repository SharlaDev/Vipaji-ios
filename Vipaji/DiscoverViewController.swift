//
//  DiscoverViewController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 11/16/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit
//import ComplimentaryGradientView
import AVFoundation
import XLPagerTabStrip

class DiscoverCell: UITableViewCell {
    
    @IBOutlet weak var AuthorView: UIStackView!
    @IBOutlet weak var AuthorImageView: UIImageView!
    @IBOutlet weak var AuthorNameLabel: UILabel!
    @IBOutlet weak var PlayerView: UIView!
    @IBOutlet weak var SwipeView: SwipeRateView!
    
    public var isDisplayed: Bool = false
    public var post: Post!
    public var parentController: DiscoverViewController!
    
    var videoView: UIView!
    var hasGestures: Bool = false
    
    private var isSetup: Bool = false
    private var isPlaying: Bool = false
    private var isFullscreen: Bool = false
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var initialPlayerFrame: CGRect!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure views //todo: delete this but we'll need this textview code later
        //DescriptionTextView.textContainerInset = .zero
        //DescriptionTextView.contentInset = UIEdgeInsetsMake(0, -5, 0, -5)
        
        // Add tap gesture recognizers
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.enterFullscreenDisplay))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.togglePlaying))
        //tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        
        PlayerView.addGestureRecognizer(tapGestureRecognizer)
        PlayerView.addGestureRecognizer(doubleTapGestureRecognizer)
        
        let authorTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showAuthorProfile))
        AuthorView.addGestureRecognizer(authorTapGestureRecognizer)
    }
    
    override func layoutSubviews() {
        // Run initial setup once
        if !isSetup {
            videoView = UIView(frame: PlayerView.bounds)
            videoView.clipsToBounds = true
            PlayerView.addSubview(videoView)
            PlayerView.clipsToBounds = true
            
            isSetup = true
        }
        
        /*
        // Set basic info
        AuthorNameLabel.text = post.userName
        if post.userImage == nil {
            UserManager.imageURL(forUserID: post.userID) { (url) in
                if url != nil {
                    let tmp = UIImageView()
                    tmp.downloadedFrom(url: url!)
                    self.AuthorImageView = tmp
                    self.post.userImage = tmp.image
                }
            }
        } else {
            self.AuthorImageView.image = post.userImage
        }
 */
        
        initialPlayerFrame = PlayerView.frame
        
        super.layoutSubviews()
    }
    
    // Mark: - Playback
    override func didMoveToWindow() {
        // Create player and player layer
        player = /* AVPlayer(url: URL(string: "http://techslides.com/demos/sample-videos/small.mp4")!) // */ AVPlayer(url: post.url!)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.frame = PlayerView.bounds
        PlayerView.layer.addSublayer(playerLayer!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loopPlayer), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        
        //Configure swipe view
        SwipeView.postID = post.ID
        
        UserManager.votes(forPost: post.ID, finished: { (votes) in
            self.SwipeView.currentVotes = votes
            self.SwipeView.reloadVotes()
        })
    }
    
    @objc func loopPlayer() {
        player?.seek(to: kCMTimeZero)
        player?.play()
    }
    
    public func play() {
        player?.play()
        isPlaying = true
    }
    
    public func stopPlaying() {
        player?.pause()
        isPlaying = false
    }
    
    @objc func togglePlaying() {
        if isPlaying {
            player?.pause()
            isPlaying = false
            
            //todo: show play button
        } else {
            player?.play()
            isPlaying = true
        }
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
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(removeFullScreenView))
        doubleTapGesture.numberOfTapsRequired = 2
        fullScreenView.addGestureRecognizer(doubleTapGesture)
        
        if !isPlaying {
            play()
        }
        
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
        //PlayerView.layer.addSublayer(arrowLayer)
        CATransaction.commit()
        
        // Disable rotation
        (UIApplication.shared.delegate as! AppDelegate).isRotationAllowed = false
    }
    
    func rotatePlayerLayer() {
        playerLayer?.frame = viewWithTag(1)!.bounds
    }
    
    // Mark: - Action Buttons
    @IBAction func PresentComments(_ sender: UIButton) {
        let commentsVC = parentController.storyboard?.instantiateViewController(withIdentifier: "Comments") as! CommentsViewController
        commentsVC.postID = post.ID
        
        parentController.navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    @objc func showAuthorProfile() {
        let profileVC = parentController.storyboard?.instantiateViewController(withIdentifier: "Profile") as! NewProfileViewController
        profileVC.userID = post.userID
        parentController.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    override func prepareForReuse() {
        // Reset dynamic components
        AuthorImageView.image = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player = nil
        
        super.prepareForReuse()
    }
}

// Mark: -
class DiscoverViewController: UITableViewController, IndicatorInfoProvider, UITextFieldDelegate {
    
    //@IBOutlet weak var HeaderView: UIView!
    //@IBOutlet weak var SearchField: UIStyledTextField!
    
    public var posts = [Post]()
    public var isLocal: Bool = false
    
    public var currentCell = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Load posts
        PostManager.loadRecentPosts(finished: { (posts) in
            self.posts.append(contentsOf: posts)
            self.tableView.reloadData()
            self.updatePlaying()
        })
        
        
        // Style nav bar
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 20.0)!, NSAttributedStringKey.foregroundColor: UIColor.white]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return (isLocal) ? IndicatorInfo(title: "Local") : IndicatorInfo(title: "Global")
    }
    
    func loadMorePosts() {
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverCell", for: indexPath) as! DiscoverCell
        let post = posts[indexPath.section]
        
        // Configure the cell
        cell.parentController = self
        cell.post = post
        
        // Set name label
        if post.userName != nil {
            cell.AuthorNameLabel.text = post.userName
        } else {
            let index = indexPath.row
            UserManager.name(forID: post.userID) { (name) in
                cell.AuthorNameLabel.text = name
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

        return cell
    }
    
    // Mark: - Spacing
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    // Mark: - Search Field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Mark: - Playback
    public func updatePlaying() {
        // Stop any playing surrounding cells
        if currentCell > 0 {
            (tableView.cellForRow(at: IndexPath(row: 0, section: currentCell - 1)) as? DiscoverCell)?.stopPlaying()
        }
        
        if currentCell + 1 < posts.count {
            (tableView.cellForRow(at: IndexPath(row: 0, section: currentCell + 1)) as? DiscoverCell)?.stopPlaying()
        }
        
        // Start playing visible cell
        (tableView.cellForRow(at: IndexPath(row: 0, section: currentCell)) as? DiscoverCell)?.play()
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
