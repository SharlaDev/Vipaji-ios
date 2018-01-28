//
//  UserManager.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 10/21/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class UserManager {
    
    // MARK: - User Info
    
    ///Create and upload a new user to Cloud Firestore
    public static func createUser(_ user: User) {
        let defaultStore = Firestore.firestore()
        
        defaultStore.collection("users").document(user.uid).setData([
            "name" : user.displayName,
            "bio" : "I'm either a little shy or a little forgetful - I haven't written my bio!",
            "fanCount" : 0,
            "postCount" : 0,
            "conversations" : [String]()
        ]) { err in
            if let err = err {
                print("Error - Unable to create new user: \(err)")
            }
        }
    }
    
    ///Fetch saved user info from Cloud Firestore
    public static func userInfo(forUserID userID: String, completion: @escaping (UserProfile?) -> Void) {
        let defaultStore = Firestore.firestore()
        
        defaultStore.collection("users").document(userID).getDocument { (document, error) in
            if let document = document {
                let info = document.data()
                let userInfo = UserProfile()
                
                userInfo.uid = userID
                userInfo.name = info["name"] as! String
                userInfo.bio = info["bio"] as! String
                userInfo.fanCount = info["fanCount"] as! Int
                userInfo.postCount = info["postCount"] as! Int
                if let url = info["photoDataURL"] as? String {
                    userInfo.photoDataURL = URL(string: url)!
                }
                
                completion(userInfo)
            } else {
                print("Error - Document for user profile does not exist")
                completion(nil)
            }
        }
    }
    
    ///Update user info on Cloud Firestore
    public static func updateUserInfo(userID: String, userInfo: UserProfile) {
        let defaultStore = Firestore.firestore()
        
        // Prepare Storage to upload user image
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let userPhotosRef = storageRef.child("userPhotos/\(userID)")
        
        // If user image is supplied, upload it and update DB record
        if let photoData = userInfo.photoData {
            userPhotosRef.putData(userInfo.photoData!, metadata: nil) { metadata, error in
                if let error = error {
                    print("error: " + error.localizedDescription)
                } else {
                    let downloadURL = metadata!.downloadURL()
                    
                    defaultStore.collection("users").document(userInfo.uid).setData([
                        "name": userInfo.name,
                        "bio": userInfo.bio,
                        "photoDataURL": downloadURL!.absoluteString
                    ], options: SetOptions.merge()) { err in
                        if let err = err {
                            print("Error - Unable to update user info: \(err)")
                        }
                    }
                }
            }
        } else { // Update DB record without image
            defaultStore.collection("users").document(userInfo.uid).setData([
                "name": userInfo.name,
                "bio": userInfo.bio
            ], options: SetOptions.merge()) { err in
                if let err = err {
                    print("Error - Unable to update user info: \(err)")
                }
            }
        }
    }
    
    /// Retrieve URL to current image for given user ID
    public static func imageURL(forUserID userID: String, result: @escaping (URL?) -> Void) {
        let defaultStore = Firestore.firestore()
        
        defaultStore.collection("users").document(userID).getDocument { (snapshot, err) in
            if err != nil {
                print(err.debugDescription)
                result(nil)
            } else {
                if let photoURL = snapshot?.data()["photoDataURL"] as! String? {
                    let url = URL(string: photoURL)
                    result(url)
                } else {
                    result(nil)
                }
            }
        }
    }
    
    // Mark: - Following
    
    ///Update Firestore to show current user following given user
    public static func follow(userWithID userID: String) {
        let defaultStore = Firestore.firestore()
        let currentUserID = Auth.auth().currentUser!.uid
        
        defaultStore.collection("users").document(currentUserID).collection("following").document(userID).setData(["followedOn" : Date()])
        
        let userRef = defaultStore.collection("users").document(userID)
        defaultStore.runTransaction({ (transaction, errorPointer) -> Any? in
            let doc: DocumentSnapshot
            do {
                try doc = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            if var fanCount = doc.data()["fanCount"] as? Int {
                fanCount += 1
                transaction.updateData(["fanCount" : fanCount], forDocument: userRef)
                return fanCount
            } else {
                return nil
            }
        }) { (newFanCount, err) in
            if err != nil {
                print(err.debugDescription)
            }
        }
    }
    
    ///Delete Firestore records of user following user with given ID
    public static func unfollow(userWithID userID: String) {
        let defaultStore = Firestore.firestore()
        let currentUserID = Auth.auth().currentUser!.uid
        
        defaultStore.collection("users").document(currentUserID).collection("following").document(userID).delete()
        
        let userRef = defaultStore.collection("users").document(userID)
        defaultStore.runTransaction({ (transaction, errorPointer) -> Any? in
            let doc: DocumentSnapshot
            do {
                try doc = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            if var fanCount = doc.data()["fanCount"] as? Int {
                fanCount -= 1
                transaction.updateData(["fanCount" : fanCount], forDocument: userRef)
                return fanCount
            } else {
                return nil
            }
        }) { (newFanCount, err) in
            if err != nil {
                print(err.debugDescription)
            }
        }
    }
    
    ///Query Firestore following status of given user
    public static func isFollowing(userWithID userID: String, finished: @escaping (Bool) -> Void)  {
        let defaultStore = Firestore.firestore()
        let currentUserID = Auth.auth().currentUser!.uid
        
        defaultStore.collection("users").document(currentUserID).collection("following").document(userID).getDocument { (snapshot, err) in
            if err != nil {
                print(err.debugDescription)
                finished(false)
            } else {
                finished(snapshot!.exists)
            }
        }
    }
    
    ///Fetch userIDs of all users current user follows
    public static func fetchFollowed(finished: @escaping ([String]) -> Void) {
        let defaultStore = Firestore.firestore()
        let userID = Auth.auth().currentUser!.uid
        
        defaultStore.collection("users").document(userID).collection("following").getDocuments { (snapshot, err) in
            if err != nil {
                print(err.debugDescription)
                finished([])
            } else {
                var followedUserIDs = [String]()
                for doc in snapshot!.documents {
                    followedUserIDs.append(doc.documentID)
                }
                finished(followedUserIDs)
            }
        }
    }
    
    // MARK: - Votes on posts
    
    ///Fetch user's existing votes for given post
    public static func votes(forPost postID: String, finished: @escaping (Int) -> Void) {
        let defaultStore = Firestore.firestore()
        
        defaultStore.collection("users").document(Auth.auth().currentUser!.uid).collection("castVotes").document(postID).getDocument { (snapshot, err) in
            if err != nil {
                print(err.debugDescription)
                finished(0) //fail gracefully
            } else {
                if snapshot!.exists {
                    finished(snapshot?.data()["votes"] as! Int)
                } else {
                    finished(0)
                }
            }
        }
    }
    
    
    /*
     //BELOW ARE OLD FUNCTIONS USING REALTIMEDB (Old Backend)
    public static func DEPRECATEDimageURL(forUserID userID: String, completion: @escaping (URL?) -> Void) {
        let ref = Database.database().reference()
        
        ref.child("users").child("\(userID)/photoDataURL").observeSingleEvent(of: .value, with: { (snapshot) in
            if !(snapshot.value is NSNull) {
                let photoURL = URL(string: snapshot.value as! String)
                completion(photoURL)
            } else {
                completion(nil)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
     
    public static func DEPRECATEDfollow(userWithID userID: String) {
        let ref = Database.database().reference()
        let currentUserID = Auth.auth().currentUser!.uid
        
        // Add user to following
        ref.child("users/\(currentUserID)/following/\(userID)").setValue(true)
        
        // Update user's fan count
        let userRef = ref.child("users/\(userID)/fanCount")
        userRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if let fanCount = currentData.value as? Int {
                currentData.value = fanCount + 1
                return TransactionResult.success(withValue: currentData)
            } else {
                currentData.value = 1
            }
            
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    public static func DEPRECATEDunfollow(userWithID userID: String) {
        let ref = Database.database().reference()
        let currentUserID = Auth.auth().currentUser!.uid
        
        // Add user to following
        ref.child("users/\(currentUserID)/following/\(userID)").removeValue()
        
        // Update user's fan count
        let userRef = ref.child("users/\(userID)/fanCount")
        userRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if let fanCount = currentData.value as? Int {
                currentData.value = fanCount - 1
                return TransactionResult.success(withValue: currentData)
            }
            
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    public static func DEPRECATEDisFollowing(userWithID userID: String, finished: @escaping (Bool) -> Void)  {
        let ref = Database.database().reference()
        let currentUserID = Auth.auth().currentUser!.uid
        let userRef = ref.child("users/\(currentUserID)/following/\(userID)")
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                finished(false)
            } else {
                finished(true)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    public static func DEPRECATEDfetchFollowed(finished: @escaping ([String]) -> Void) {
        let ref = Database.database().reference()
        let currentUserID = Auth.auth().currentUser!.uid
        let followingRef = ref.child("users/\(currentUserID)/following")
        
        followingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            var userIDs = [String]()
            for child in snapshot.children {
                userIDs.append((child as! DataSnapshot).key)
            }
            
            finished(userIDs)
        })
    }
 */
    
    // Mark: - Ranking
    
    public static func rankedUsers(finished: @escaping ([String]) -> Void) {
        let defaultStore = Firestore.firestore()
        
        defaultStore.collection("rankings").document("global").getDocument { (snapshot, err) in
            if err != nil {
                print(err.debugDescription)
                finished([])
            } else {
                var userIDs = [String]()
                
                let data = snapshot!.data()
                for i in 1..<51 {
                    if let userID = data["\(i)"] as? String {
                        userIDs.append(userID)
                    }
                }
                
                finished(userIDs)
            }
        }
    }
    
    /*
    //TODO: delete and replace with functioning firestore version
    public static func fetchTopRankedUsers(finished: @escaping ([UserProfile]) -> Void) {
        var userProfiles = [UserProfile]()
        
        let ref = Database.database().reference()
        //todo: get ranked
        
        for _ in 0..<50 {
            let profile = UserProfile()
            profile.name = "Rowen Gray"
            profile.uid = "92VdHo9SdTW5gHFFVwTRlt9lc9G3"
            profile.photoDataURL = URL(string: "https://firebasestorage.googleapis.com/v0/b/vipaji-9ae4f.appspot.com/o/userPhotos%2F92VdHo9SdTW5gHFFVwTRlt9lc9G3?alt=media&token=ec492b7b-3075-4f52-aace-d75eb4450d66")
            
            userProfiles.append(profile)
        }
        
        finished(userProfiles)
    }
 */
    
    // MARK: - Convenience functions
    
    ///Query Firestore for name assigned to user ID
    public static func name(forID userID: String, finished: @escaping (String) -> Void) {
        let defaultStore = Firestore.firestore()
        
        defaultStore.collection("users").document(userID).getDocument { (snapshot, err) in
            if err != nil {
                print(err.debugDescription)
            } else {
                let name = snapshot?.data()["name"] as! String
                finished(name)
            }
        }
    }
}
