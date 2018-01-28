//
//  UserProfile.swift
//  Vipaji
//
//  Created by Andres Gutierrez on 9/13/17.
//  Copyright © 2017 AndresGutierrez. All rights reserved.
//

import Foundation
import UIKit

public class UserProfile {
    var uid: String = "" //todo: consider removing if unecessary
    var name: String = ""
    var bio: String = ""
    var photoData: Data?
    var photoDataURL: URL?
    var fanCount: Int = 0
    var postCount: Int = 0
}
