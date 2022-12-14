//
//  AudioMessage.swift
//  Xchat
//
//  Created by Beavean on 05.12.2022.
//

import Foundation
import MessageKit

final class AudioMessage: NSObject, AudioItem {

    var url: URL
    var duration: Float
    var size: CGSize

    init(duration: Float) {
        self.url = URL(fileURLWithPath: "")
        self.size = CGSize(width: 160, height: 35)
        self.duration = duration
    }
}
