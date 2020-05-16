//
//  Post.swift
//  Insta
//
//  Created by user169878 on 5/13/20.
//  Copyright © 2020 Algopedia. All rights reserved.
//

import Foundation
import UIKit

class Post{
    var caption: String
    var photo: UIImage
    
    init(captionText: String, photo: UIImage)
    {
        caption = captionText
        self.photo = photo
    }
}
