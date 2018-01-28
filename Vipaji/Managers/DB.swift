//
//  DB.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 9/9/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

public class DB {
    
    static var ref: DatabaseReference = Database.database().reference()
    

    /*
    //old realtime database versions
    public static func DEPRECATEDaddUser(_ user: User) {
        // Init DB object
        let ref = Database.database().reference()
        
        // Add new user with defaults
        let newUser = ["uid": user.uid,
                       "name": user.displayName!,
                       "bio": "I'm either a little shy or a little forgetful - I haven't written my bio!",
                           "fanCount": 0,
                           "postCount": 0] as [String : Any]
        let childUpdates = ["/users/\(user.uid)": newUser]
        ref.updateChildValues(childUpdates)
    }
    
    public static func DEPRECATEDupdateUser(userID: String, userInfo: UserProfile) {
        // Prepare DB to upload user image
        var dbRef: DatabaseReference!
        dbRef = Database.database().reference()
        
        // Prepare Storage to upload user image
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let userPhotosRef = storageRef.child("userPhotos/\(userID)")
        
        // If user image is supplied, upload it and update DB record
        if let photoData = userInfo.photoData {
            _ = userPhotosRef.putData(userInfo.photoData!, metadata: nil) { metadata, error in
                if let error = error {
                    print("error: " + error.localizedDescription)
                } else {
                    let downloadURL = metadata!.downloadURL()
                    
                    let updatedUser = ["name": userInfo.name,
                                       "bio": userInfo.bio,
                                       "photoDataURL": downloadURL!.absoluteString] as [String : Any]
                    
                    let childUpdates = ["/users/\(userID)": updatedUser]
                    dbRef.updateChildValues(childUpdates)
                }
            }
        } else { // Update DB record
            let updatedUser = ["name": userInfo.name,
                               "bio": userInfo.bio] as [String : Any]
            
            let childUpdates = ["/users/\(userID)": updatedUser]
            dbRef.updateChildValues(childUpdates)
        }
    }
    
    public static func DEPRECATEDfindUserInfo(userID: String, completion: @escaping (UserProfile?) -> Void) {
        // Init DB object
        let ref = Database.database().reference()
        
        // Find user
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            let userInfo = UserProfile()
            
            // Get user info
            let user = snapshot.value as? NSDictionary
            userInfo.uid = userID
            userInfo.name = user?["name"] as? String ?? ""
            userInfo.bio = user?["bio"] as? String ?? ""
            
            if let url = user?["photoDataURL"] as? String {
                userInfo.photoDataURL = URL(string: url)
            }
            
            userInfo.fanCount = user?["fanCount"] as? Int ?? 0
            userInfo.postCount = user?["postCount"] as? Int ?? 0
            
            completion(userInfo)
        }) { (error) in
            print(error.localizedDescription)
            completion(nil)
        }
    }
    
    //todo: this function can be improved; there's no need to take snapshot of whole post
    public static func DEPRECATEDupdateVotes(postID: String, currentVotes: Int, newVotes: Int) {
        // Init DB object
        let ref = Database.database().reference()
        
        // Update user votes in DB
        let userRef = ref.child("users/\(Auth.auth().currentUser!.uid)/votes")
        userRef.child(postID).setValue(currentVotes + newVotes)
        
        // Update post votes in DB
        let postRef = ref.child("posts/\(postID)")
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject] {
                // Update vote count
                post["votes"] = (post["votes"] as! Int) + newVotes as AnyObject
                
                // Set value and report transaction success
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    public static func DEPRECATEDuserVotes(forPost postID: String, completion: @escaping ((Int) -> Void)) {
        // Init DB object
        let ref = Database.database().reference()
        let currentVotesRef = ref.child("users/\(Auth.auth().currentUser!.uid)/votes/\(postID)")
        
        // Return current vote count, default to 0
        currentVotesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                completion(snapshot.value as! Int)
            } else {
                completion(0)
            }
        })
    }
    */
    
    /*
    public static func DEPRECATEDpostComment(forPost postID: String, comment: Comment) {
        // Init DB object
        let ref = Database.database().reference()
        let commentsRef = ref.child("posts/\(postID)/comments")
        
        // Generate unique comment key
        let commentKey = commentsRef.childByAutoId().key
        
        // Set comment data
        var newComment = ["user": comment.userID,
                        "userName": comment.userName,
                        "body": comment.body,
                        "postDate": comment.timestamp.toString(dateFormat: "yyyy/MM/dd hh:mm:ss")] as [String : Any]
        
        // Upload comment to DB
        let update = ["/\(commentKey)": newComment]
        commentsRef.updateChildValues(update)
        
        //DB.incrementCommentCount(postID: postID, currentVotes: 0, newVotes: 1)
    }
 */
    
    public static func incrementCommentCount(postID: String) {
        // Init DB object
        let ref = Database.database().reference()
        
        // Update post comment count in DB
        let postRef = ref.child("posts/\(postID)/commentCount")
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if let commentCount = currentData.value as? Int {
                currentData.value = commentCount + 1
                return TransactionResult.success(withValue: currentData)
            }
            
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    public static var commentListenerHandle: UInt?
    
    public static func listenForComments(forPost postID: String, completion: @escaping (([Comment]?) -> Void)) {
        // Init DB object
        let ref = Database.database().reference()
        let commentsRef = ref.child("posts/\(postID)/comments")
        
        // Make request for post comments
        commentListenerHandle = commentsRef.observe(.value, with: { (snapshot) in
            // Creat new comments collection
            var comments = [Comment]()
            
            // Populate comments from retrieved info
            for commentSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                let commentInfo = commentSnapshot.value as? [String : Any]
                let comment = Comment()
                
                comment.userID = commentInfo?["user"] as! String
                //comment.userName = commentInfo?["userName"] as! String
                comment.body = commentInfo?["body"] as! String
                comment.timestamp = (commentInfo?["postDate"] as! String).toDate(withFormat: "yyyy/MM/dd hh:mm:ss")

                comments.append(comment)
            }
            completion(comments)
        }) { (error) in
            print(error.localizedDescription)
            completion(nil)
        }
    }
    
    public static func stopListeningForComments() {
        let ref = Database.database().reference()
        ref.removeObserver(withHandle: commentListenerHandle!)
    }
    
    
    
    //CONVENIENCE
    /*
    public static func toDate(_ string: String, dateFormat format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: string)!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        return calendar.date(from: components)!
    }
 */
}
