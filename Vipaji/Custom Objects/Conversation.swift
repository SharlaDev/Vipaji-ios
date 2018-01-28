//
//  Conversation.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 1/6/18.
//  Copyright © 2018 AndresGutierrez. All rights reserved.
//

import Foundation
import UIKit

public class Message {
    public var ID: String!
    public var message: String!
    public var timestamp: Date!
    public var senderID: String!
    public var recipientID: String!
}

public class Conversation {
    public var ID: String!
    public var userIDs: [String] = [String]()
    public var messages: [Message] = [Message]()
    
    public var otherUserName: String?
    public var downloadedUserImageView: UIImageView!
}
