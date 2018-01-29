//
//  PostManager.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 9/9/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore

public class PostManager {
    
    // MARK: - Load Posts
    
    /// Load most recent of all posts
    public static let MAX_POSTS_TO_LOAD = 100
    public static func loadRecentPosts(finished: @escaping ([Post]) -> Void) {
        let defaultStore = Firestore.firestore()

        defaultStore.collection("posts").limit(to: MAX_POSTS_TO_LOAD).getDocuments { (snapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                finished([])
            } else {
                var posts = [Post]()
                for document in snapshot!.documents {
                    let post = PostManager.createPostFromSnapshot(document)
                    
                    posts.append(post)
                }
                finished(posts)
            }
        }
    }
    
    ///Load posts from user for given user ID
    public static func loadPosts(fromUser userID: String, finished: @escaping ([Post]) -> Void) {
        let defaultStore = Firestore.firestore()
        var posts = [Post]()
        
        defaultStore.collection("users").document(userID).getDocument { (snapshot, err) in
            if err != nil {
                print(err.debugDescription)
                finished([])
            } else {
                let postIDs = snapshot?.data()!["posts"] as? [String] ?? [String]()
                
                var posts = [Post]()
                for postID in postIDs {
                    defaultStore.collection("posts").document(postID).getDocument(completion: { (snapshot, err) in
                        if err != nil {
                            print(err.debugDescription)
                        } else {
                            let post = PostManager.createPostFromSnapshot(snapshot!)
                            posts.append(post)
                        }
                    })
                    
                    if posts.count == postIDs.count {
                        finished(posts)
                    }
                }
            }
        }
        
        defaultStore.collection("users").document(userID).collection("posts").order(by: "timestamp").getDocuments(completion: { (snapshot, err) in
            if err != nil {
                print("Error loading user posts: \(err.debugDescription)")
                finished([])
            } else {
                for document in snapshot!.documents {
                    let post = PostManager.createPostFromSnapshot(document)
                    
                    posts.append(post)
                }
                finished(posts)
            }
        })
    }
    
    ///Load posts from followed users
    public static func loadFeedPosts(finished: @escaping ([Post]) -> Void) {
        UserManager.fetchFollowed { (followedUserIDs) in
            // Add self to list of user IDs to load
            var userIDs = followedUserIDs
            userIDs.append(Auth.auth().currentUser!.uid)
            
            var posts = [Post]()
            
            var usersProcessed = 0
            for userID in userIDs {
                PostManager.loadPosts(fromUser: userID, finished: { (userPosts) in
                    posts.append(contentsOf: userPosts)
                    
                    usersProcessed += 1
                    if usersProcessed == userIDs.count {
                        finished(posts)
                    }
                })
            }
        }
    }
    
    /*
    public static var lastPostLoaded: Int = 0
    public static func DEPRECATEDloadRecentPosts(finished: @escaping ([Post]) -> Void) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        var posts = [Post]()
        
        let recentPostsQuery = ref.child("posts").queryOrdered(byChild: "timestamp").queryLimited(toFirst: 100)
        recentPostsQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            self.lastPostLoaded += 4
            
            for child in snapshot.children {
                if let postInfo = (child as! DataSnapshot).value as? [String: AnyObject] {
                    let post = Post()
                    /*
                    post.ID = (child as! DataSnapshot).key
                    post.userID = (postInfo["user"] as? String)!
                    post.userName = (postInfo["userName"] as? String)!
                    post.postDate = DB.dateFromString((postInfo["date"] as? String)!, dateFormat: "yyyy/MM/dd hh:mm:ss")
                    post.description = (postInfo["description"] as! String)
                    post.url = URL(string: (postInfo["videoURL"] as! String))
                    post.commentCount = postInfo["commentCount"] as! Int
                    post.shareCount = postInfo["shareCount"] as! Int
                    post.votes = postInfo["votes"] as! Int
                    
                    posts.append(post)
 */
                }
            }
            finished(posts)
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
 */
    
    public static func updateVotes(forPostID postID: String, currentUserVotes: Int, newVotes: Int) {
        let defaultStore = Firestore.firestore()
        
        // Update user votes on post
        defaultStore.collection("users").document(Auth.auth().currentUser!.uid).collection("castVotes").document(postID).setData(["votes" : currentUserVotes + newVotes])
        
        // Update post's total vote count
        let postRef = defaultStore.collection("posts").document(postID)
        defaultStore.runTransaction({ (transaction, errorPointer) -> Any? in
            let doc: DocumentSnapshot
            do {
                try doc = transaction.getDocument(postRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            if var voteCount = doc.data()!["votes"] as! Int? {
                voteCount += 1
                transaction.updateData(["votes" : voteCount], forDocument: postRef)
                return voteCount
            } else {
                return nil
            }
            
        }) { (newVoteCount, err) in
            if err != nil {
                print(err.debugDescription)
            }
        }
    }
    
    // MARK: - Upload Posts
    
    // Taken from https://samkirkiles.svbtle.com/swift-using-avassetwriter-to-compress-video-files-for-network-transfer
    public  static func compressFile(urlToCompress: URL, outputURL: URL, completion: @escaping (URL)->Void) {
        let asset = AVAsset(url: urlToCompress);
        let bitrate: NSNumber = NSNumber(value: 2000000)
        let resolutionWidth: Int = 1280
        let resolutionHeight: Int = 960
        
        var reader: AVAssetReader
        var audioFinished = false
        var videoFinished = false
        
        do {
            reader = try AVAssetReader(asset: asset)
        } catch {
            fatalError("Unable to initialize AVAssetReader")
        }
        
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first!
        let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first!
        
        let videoReaderSettings: [String : Any] = [kCVPixelBufferPixelFormatTypeKey as String!:kCVPixelFormatType_32ARGB ]
        
        // ADJUST BIT RATE OF VIDEO HERE
        let videoSettings: [String : Any] = [
            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey : bitrate],
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill,
            AVVideoHeightKey: resolutionHeight,
            AVVideoWidthKey: resolutionWidth
        ]
        
        let assetReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
        let assetReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
        
        if reader.canAdd(assetReaderVideoOutput) {
            reader.add(assetReaderVideoOutput)
        } else {
            fatalError("Couldn't add video output reader")
        }
        
        if reader.canAdd(assetReaderAudioOutput){
            reader.add(assetReaderAudioOutput)
        }else{
            fatalError("Couldn't add audio output reader")
        }
        
        let audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)
        let videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
        videoInput.transform = videoTrack.preferredTransform
        //we need to add samples to the video input
        
        let videoInputQueue = DispatchQueue(label: "videoQueue")
        let audioInputQueue = DispatchQueue(label: "audioQueue")
        var writer: AVAssetWriter
        
        do {
            writer = try AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mov)
        } catch {
            fatalError("Unable to create requested asset writer")
        }
        
        writer.shouldOptimizeForNetworkUse = true
        writer.add(videoInput)
        writer.add(audioInput)
        
        writer.startWriting()
        reader.startReading()
        writer.startSession(atSourceTime: kCMTimeZero)
        
        let closeWriter:() -> Void = {
            if (audioFinished && videoFinished){
                writer.finishWriting(completionHandler: {
                    PostManager.checkFileSize(sizeUrl: (writer.outputURL), message: "The file size of the compressed file is: ")
                    
                    completion((writer.outputURL))
                })
                
                reader.cancelReading()
            }
        }
        
        audioInput.requestMediaDataWhenReady(on: audioInputQueue) {
            while(audioInput.isReadyForMoreMediaData){
                let sample = assetReaderAudioOutput.copyNextSampleBuffer()
                if (sample != nil) {
                    audioInput.append(sample!)
                }else{
                    audioInput.markAsFinished()
                    DispatchQueue.main.async {
                        audioFinished = true
                        closeWriter()
                    }
                    break;
                }
            }
        }
        
        videoInput.requestMediaDataWhenReady(on: videoInputQueue) {
            //request data here
            
            while(videoInput.isReadyForMoreMediaData){
                let sample = assetReaderVideoOutput.copyNextSampleBuffer()
                if (sample != nil){
                    videoInput.append(sample!)
                } else {
                    videoInput.markAsFinished()
                    DispatchQueue.main.async {
                        videoFinished = true
                        closeWriter()
                    }
                    break;
                }
            }
            
        }
    }
    
    public static func checkFileSize(sizeUrl: URL, message:String){
        let data = NSData(contentsOf: sizeUrl)!
        print(message, (Double(data.length) / 1048576.0), " mb")
    }
    
    ///Compress and upload post to Firestore
    public static func uploadPost(videoURL: URL, description: String) {
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!)
        let outputURL = documentsPath.appendingPathComponent("Compressed_Video.mp4")
        
        checkFileSize(sizeUrl: videoURL, message: "The file size of the original video: ")
        
        compressFile(urlToCompress: videoURL, outputURL: outputURL!) { (finalURL) in
            let defaultStore = Firestore.firestore()
            let doc = defaultStore.collection("posts").document()
            
            // Prepare video upload to Storage
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let videosRef = storageRef.child("videos/\(doc.documentID)")
            
            // Upload the file as "<postID>.mp4:"
            videosRef.putFile(from: finalURL, metadata: nil) { metadata, error in
                if let error = error {
                    print("error: " + error.localizedDescription)
                } else {
                    // Submit post
                    let user = Auth.auth().currentUser!
                    let downloadURL = metadata!.downloadURL()
                    let postDate = Date(timeIntervalSinceNow: 0).toString(dateFormat: "yyyy/MM/dd hh:mm:ss")
                    let timestamp = NSDate().timeIntervalSince1970 * 1000
                    
                    let postData: [String : Any] = ["user" : user.uid,
                                                    "userName" : user.displayName!,
                                                    "description" : description,
                                                    "videoURL" : downloadURL!.absoluteString,
                                                    "date" : postDate,
                                                    "votes" : 0,
                                                    "commentCount" : 0,
                                                    "shareCount" : 0,
                                                    "timestamp" : timestamp]
                    
                    doc.setData(postData) { err in
                        if let err = err {
                            print("Error - Unable to create new post: \(err.localizedDescription)")
                        }
                    }
                    
                    // Add post ID to user post collection
                    defaultStore.collection("users").document(user.uid).getDocument(completion: { (snapshot, err) in
                        if err != nil {
                            print(err.debugDescription)
                        } else {
                            var postIDs = snapshot!.data()!["posts"] as? [String] ?? [String]()
                            postIDs.append(doc.documentID)
                            
                            defaultStore.collection("users").document(user.uid).updateData(["posts" : postIDs])
                        }
                    })
                    
                    /* Store duplicate post under user
                    defaultStore.collection("users").document(user.uid).collection("posts").addDocument(data: postData) { err in
                        if let err = err {
                            print("Error - Unable to add new post under user: \(err.localizedDescription)")
                        }
                    }
                     */
                }
                
                try! FileManager.default.removeItem(at: finalURL)
            }
        }
    }
    
    //MARK: - Comments
    public static func postComment(_ comment: Comment, onPostID postID: String) {
        let defaultStore = Firestore.firestore()
        
        defaultStore.collection("posts").document(postID).collection("comments").addDocument(data: ["user" : comment.userID,
                                                                                                    "body" : comment.body,
                                                                                                    "timestamp" : comment.timestamp])
        
        let postRef = defaultStore.collection("posts").document(postID)
        defaultStore.runTransaction({ (transaction, errorPointer) -> Any? in
            let doc: DocumentSnapshot
            do {
                try doc = transaction.getDocument(postRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            if var commentCount = doc.data()!["commentCount"] as! Int? {
                commentCount += 1
                transaction.updateData(["commentCount" : commentCount], forDocument: postRef)
                return commentCount
            } else {
                return nil
            }
            
        }) { (comment, err) in
            if err != nil {
                print(err.debugDescription)
            }
        }
    }
    
    public static var commentListener: ListenerRegistration?
    public static func listenForComments(inPost postID: String, updated: @escaping ([Comment]) -> Void) {
        let defaultStore = Firestore.firestore()
        
        commentListener = defaultStore.collection("posts").document(postID).collection("comments").addSnapshotListener { (snapshot, err) in
            if err != nil {
                print(err.debugDescription)
            } else {
                var comments = [Comment]()
                snapshot?.documentChanges.forEach({ (change) in
                    if (change.type == .added) {
                        let data = change.document.data()
                        let comment = Comment()
                        
                        comment.userID = data["user"] as! String
                        comment.body = data["body"] as! String
                        comment.timestamp = data["timestamp"] as! Date
                        
                        comments.append(comment)
                    }
                    
                    if (change.type == .modified) {
                        print("Message modified")
                    }
                    if (change.type == .removed) {
                        print("Message deleted")
                    }
                })
                
                updated(comments)
            }
        }
    }
    
    public static func stopListeningForComments() {
        commentListener?.remove()
    }
    
    
    
    /*
    //TODO: DELETE
    public static func DEPRECATEDuploadPost(videoURL: URL, description: String) {
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!)
        let outputURL = documentsPath.appendingPathComponent("Compressed_Video.mp4")
        
        checkFileSize(sizeUrl: videoURL, message: "The file size of the original video: ")
        
        compressFile(urlToCompress: videoURL, outputURL: outputURL!) { (finalURL) in
            // Prepare post upload to Database
            var dbRef: DatabaseReference!
            dbRef = Database.database().reference()
            let postKey = dbRef.child("posts").childByAutoId().key
            
            // Prepare video upload to Storage
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let videosRef = storageRef.child("videos/\(postKey)")
            
            // Upload the file as "<postID>.mp4:"
            videosRef.putFile(from: finalURL, metadata: nil) { metadata, error in
                if let error = error {
                    print("error: " + error.localizedDescription)
                } else {
                    // Submit post
                    let user = Auth.auth().currentUser!
                    let downloadURL = metadata!.downloadURL()
                    let postDate = Date(timeIntervalSinceNow: 0).toString(dateFormat: "yyyy/MM/dd hh:mm:ss")
                    
                    // Create reverse timestamp for easy ordered retrieval
                    let timestamp = -(NSDate().timeIntervalSince1970 * 1000)
                    
                    let post = ["user" : user.uid,
                                "userName" : user.displayName!,
                                "description" : description,
                                "videoURL" : downloadURL!.absoluteString,
                                "date" : postDate,
                                "votes" : 0,
                                "commentCount" : 0,
                                "shareCount" : 0,
                                "timestamp" : timestamp] as [String : Any]
                    let childUpdates = ["/posts/\(postKey)" : post,
                                        "/users/\(Auth.auth().currentUser!.uid)/posts/\(postKey)" : post]
                    dbRef.updateChildValues(childUpdates)
                }
                
                try! FileManager.default.removeItem(at: finalURL)
            }
        }
    }
    
    //TODO: DELETE
    public static func DEPRECATEDloadPosts(fromUser userId: String, completion: @escaping ([Post]) -> Void) {
        let ref = Database.database().reference()
        let userRef = ref.child("users/\(userId)")
        
        var posts = [Post]()
        
        let userPostsQuery = (userRef.child("posts").queryOrdered(byChild: "timestamp"))
        userPostsQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                if let postInfo = (child as! DataSnapshot).value as? [String: AnyObject] {
                    let post = Post()
                    
                    post.ID = (child as! DataSnapshot).key
                    post.userID = (postInfo["user"] as? String)!
                    post.userName = (postInfo["userName"] as? String)!
                    post.postDate = (postInfo["date"] as? String)?.toDate(withFormat: "yyyy/MM/dd hh:mm:ss")
                    post.description = (postInfo["description"] as! String)
                    post.url = URL(string: (postInfo["videoURL"] as! String))
                    post.commentCount = postInfo["commentCount"] as! Int
                    post.shareCount = postInfo["shareCount"] as! Int
                    post.votes = postInfo["votes"] as! Int
                    
                    posts.append(post)
                }
            }
            completion(posts)
            
        }) { (error) in
            print(error.localizedDescription)
            completion([Post]())
        }
    }
    */
    
    // MARK: - Convenience
    private static func createPostFromSnapshot(_ snapshot: DocumentSnapshot) -> Post {
        let postInfo = snapshot.data()
        let post = Post()
        
        post.ID = snapshot.documentID
        post.userID = (postInfo!["user"] as? String)!
        post.userName = (postInfo!["userName"] as? String)!
        post.postDate = (postInfo!["date"] as? String)?.toDate(withFormat: "yyyy/MM/dd hh:mm:ss")
        post.description = (postInfo!["description"] as! String)
        post.url = URL(string: (postInfo!["videoURL"] as! String))
        post.commentCount = postInfo!["commentCount"] as! Int
        post.shareCount = postInfo!["shareCount"] as! Int
        post.votes = postInfo!["votes"] as! Int
        
        return post
    }
    
    // MARK: - Thumbnail Generator
    
    public static func generateThumbnail(forVideoURL url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.maximumSize = CGSize(width: 256, height: 256)
        assetImageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        time = CMTimeMake(1, 60)
        
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            
            return UIImage.init(cgImage: imageRef)
        } catch {
            print("Unable to generate requested thumbnail")
            return nil
        }
    }
}
