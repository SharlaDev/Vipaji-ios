//
//  ProfilePostsViewController.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 9/9/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import UIKit

class ProfilePostViewCell: UICollectionViewCell {
    @IBOutlet weak var ImageThumbnail: UIImageView!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class ProfilePostsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var userID: String!
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Empty posts
        posts = [Post]()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postThumbnailCell", for: indexPath) as! ProfilePostViewCell
    
        let post = posts[indexPath.row]
        
        // Configure the cell
        if post.generatedThumbnailImage != nil {
            cell.ImageThumbnail.image = post.generatedThumbnailImage
        } else {
            let index = indexPath.row
            DispatchQueue.global(qos: .background).async {
                
                // Generate thumbnail
                self.posts[index].generatedThumbnailImage = PostManager.generateThumbnail(forVideoURL: post.url!)
                
                // Go back to the main thread to update the UI
                DispatchQueue.main.async {
                    cell.ImageThumbnail.image = post.generatedThumbnailImage
                    cell.ActivityIndicator.stopAnimating()
                }
            }
        }
    
        //cell.layer.borderWidth = 1
        //cell.layer.borderColor = UIColor.white.cgColor
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postsVC = storyboard?.instantiateViewController(withIdentifier: "Feed") as! FeedViewController
        postsVC.userID = userID
        postsVC.rowToScrollTo = indexPath.row
        navigationController?.pushViewController(postsVC, animated: true)
    }
    
    
    // MARK: Collection Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let height = UIScreen.main.bounds.width / 3 - 2
        
        return CGSize(width: height, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3.0
    }
    
    // MARK: - Load posts
    public func loadPosts() {
        PostManager.loadPosts(fromUser: userID, finished: { (posts) in
            self.posts = posts
            self.collectionView?.reloadData()
        })
    }
}
