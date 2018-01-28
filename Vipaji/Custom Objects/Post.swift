//
//  Post.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 9/9/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import Foundation
import UIKit

public class Post {
    public var ID: String!
    public var userID: String!
    public var description: String!
    public var url: URL?
    public var shareUrl: String!
    public var commentIds: [String] = [String]()
    public var commentCount: Int = 0
    public var shareCount: Int = 0
    public var votes: Int = 0
    public var postDate: Date!
    
    public var userName: String?
    public var downloadedUserImageView: UIImageView?
    public var generatedThumbnailImage: UIImage?
    //public var previewImage: UIImage?
}
