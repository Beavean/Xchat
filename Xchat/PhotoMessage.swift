//
//  PhotoMessage.swift
//  Xchat
//
//  Created by Beavean on 01.12.2022.
//

import Foundation
import MessageKit

final class PhotoMessage: NSObject, MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(path: String) {
        self.url = URL(fileURLWithPath: path)
        self.placeholderImage = UIImage(systemName: "person.fill")!
        self.size = CGSize(width: 240, height: 240)
    }
}
