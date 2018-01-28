//
//  ConversationManager.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 1/6/18.
//  Copyright © 2018 AndresGutierrez. All rights reserved.
//

import Foundation
import Firebase

public class ConversationManager {
    
    ///Helper function to fetch IDs of all of user's conversations.
    public static func fetchConversationIDs(forUser userID: String, finished: @escaping ([String]) -> Void) {
        let defaultStore = Firestore.firestore()
        
        defaultStore.collection("users").document(userID).getDocument { (snapshot, err) in
            if err != nil {
                print(err.debugDescription)
                finished([])
            }
            if snapshot!.exists {
                if let convIDs = snapshot?.data()["conversations"] as! [String]? {
                    finished(convIDs)
                } else {
                    finished([])
                }
            }
        }
    }
    
    ///Fetch and format conversations with messages.
    //private static let MESSAGES_LIMIT: Int = 200
    public static func fetchConversations(forUser userID: String, finished: @escaping ([Conversation]) -> Void) {
        fetchConversationIDs(forUser: userID) { (IDs) in
            var conversations = [Conversation]()
            
            for ID in IDs {
                let conv = Conversation()
                conv.ID = ID
                
                let defaultStore = Firestore.firestore()
                
                //Get last sent message for preview and for configuring conversation details
                defaultStore.collection("conversations").document(ID).collection("Messages").order(by: "timestamp", descending: true).limit(to: 1).getDocuments(completion: { (snapshot, err) in
                    if err != nil {
                        print(err.debugDescription)
                    } else {
                        let doc = snapshot!.documents.first
                        if let data = doc?.data() {
                            let m = Message()
                            
                            m.ID = doc!.documentID
                            m.message = data["message"] as! String
                            m.senderID = data["sender"] as! String
                            m.recipientID = data["recipient"] as! String
                            m.timestamp = data["timestamp"] as! Date
                            
                            conv.messages.append(m)
                        }
                        
                        conv.userIDs.append(conv.messages[0].senderID)
                        conv.userIDs.append(conv.messages[0].recipientID)
                        
                        conversations.append(conv)
                        
                        if conversations.count == IDs.count {
                            finished(conversations)
                        }
                    }
                })
            }
        }
    }
    
    ///Add new message to conversation in Firestore.
    public static func sendMessage(_ message: Message, inConveration convID: String, isNewConversation: Bool = false) {
        let defaultStore = Firestore.firestore()
        
        defaultStore.collection("conversations").document(convID).collection("Messages").document(message.ID).setData(
            ["message" : message.message,
            "timestamp" : message.timestamp,
            "sender" : message.senderID,
            "recipient" : message.recipientID])
        
        if isNewConversation {
            defaultStore.collection("users").document(message.senderID).getDocument { (snapshot, _) in
                var convIDs = snapshot?.data()["conversationsWith"] as! [String]
                convIDs.append(message.recipientID)
                defaultStore.collection("users").document(message.senderID).updateData(["conversationsWith" : (convIDs as [NSString])])
            }
            
            defaultStore.collection("users").document(message.recipientID).getDocument { (snapshot, _) in
                var convIDs = snapshot?.data()["conversationsWith"] as! [String]
                convIDs.append(message.senderID)
                defaultStore.collection("users").document(message.recipientID).updateData(["conversationsWith" : (convIDs as [NSString])])
            }
        }
    }
    
    //TODO/READ ME: THERE'S NO NEED FOR THIS FUNCTION, JUST MAKE CONVERSATION IDs BE THE THE FIRST ID + THE SECOND ID AND THEN SEARCH FOR THE ID LIKE THAT. THERE'S NO NEED FOR ALL OF THIS COMPLICATION
    
    ///Check if conversation with given user exists
    public static func doesConversationExist(withUser userID: String) {
        let defaultStore = Firestore.firestore()
        let currentUserID = Auth.auth().currentUser!.uid
        
        /*
        listOfConversations { (conversationIDs) in
            for conversationID in conversationIDs {
                defaultStore.collection("conversations").document(conversationID).getDocument(completion: { (snapshot, err) in
                    if err != nil {
                        print("error: \(err.debugDescription)")
                    } else {
                        if let data = snapshot?.data() {
                            //if data[""].filter { $0 }
                        }
                    }
                })
            }
        }
 */
        
        /*
        defaultStore.collection("users").document(currentUserID).getDocument { (snapshot, err) in
            if err != nil {
                print("error: \(err.debugDescription)")
            } else {
                //let data
            }
        }
 */
    }
    
    public static func conversationExists(withUserID: String, finished: @escaping ([String]) -> Void) {
        let userID = Auth.auth().currentUser!.uid
        let defaultStore = Firestore.firestore()
        
        defaultStore.collection("users").document(userID).getDocument { (snapshot, err) in
            if err != nil {
                print("error: \(err.debugDescription)")
            } else {
                if let conversationIDs = snapshot?.data()["conversations"] as? [String] {
                    //if conversationIDs.contains(")
                } else {
                    finished([])
                }
                
            }
        }
    }
    
    public static func enableListener(forConversation convID: String, updated: @escaping ([Message]) -> Void) {
        let defaultStore = Firestore.firestore()
        
        defaultStore.collection("conversations").document(convID).collection("Messages").addSnapshotListener { (snapshot, err) in
            if err != nil {
                print(err.debugDescription)
            } else {
                var messages = [Message]()
                snapshot?.documentChanges.forEach({ (change) in
                    if (change.type == .added) {
                        let data = change.document.data()
                        let m = Message()
                        
                        m.ID = change.document.documentID
                        m.message = data["message"] as! String
                        m.senderID = data["sender"] as! String
                        m.recipientID = data["recipient"] as! String
                        m.timestamp = data["timestamp"] as! Date
                        
                        messages.append(m)
                    }
                    
                    if (change.type == .modified) {
                        print("Message modified")
                    }
                    if (change.type == .removed) {
                        print("Message deleted")
                    }
                })
                
                updated(messages)
            }
        }
    }
    
    //public static func
    
}
