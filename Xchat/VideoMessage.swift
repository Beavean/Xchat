//
//  VideoMessage.swift
//  Xchat
//
//  Created by Beavean on 01.12.2022.
//

import Foundation
import MessageKit

class VideoMessage: NSObject, MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(url: URL?) {
        self.url = url
        self.placeholderImage = UIImage(systemName: "video.square")!
        self.size = CGSize(width: 240, height: 240)
    }
}
