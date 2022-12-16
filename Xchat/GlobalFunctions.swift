//
//  GlobalFunctions.swift
//  Xchat
//
//  Created by Beavean on 12.11.2022.
//

import UIKit
import AVFoundation

func fileNameFrom(fileUrl: String) -> String {
    guard let name = ((fileUrl.components(separatedBy: "_").last)?.components(separatedBy: "?").first)?.components(separatedBy: ".").first else { return "" }
    return name
}

func timeElapsed(_ date: Date) -> String {
    let seconds = Date().timeIntervalSince(date)
    var elapsed = ""
    if seconds < 60 {
        elapsed = "Just now"
    } else if seconds < 60 * 60 {
        let minutes = Int(seconds / 60)
        let minutesText = minutes > 1 ? "mins" : "min"
        elapsed = "\(minutes) " + minutesText
    } else if seconds < 24 * 60 * 60 {
        let hours = Int(seconds / (60 * 60))
        let hourText = hours > 1 ? "hours" : "hour"
        elapsed = "\(hours) " + hourText
    } else {
        elapsed = date.longDate()
    }
    return elapsed
}

func videoThumbnail(video: URL) -> UIImage {
    let asset = AVURLAsset(url: video, options: nil)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1000)
    var actualTime = CMTime.zero
    var image: CGImage?
    do {
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    } catch let error as NSError {
        print("DEBUG: Error making thumbnail ", error.localizedDescription)
    }
    if let image {
        return UIImage(cgImage: image)
    } else {
        return UIImage(systemName: "photo")!
    }
}

func removeCurrentUserFrom(userIds: [String]) -> [String] {
    var allIds = userIds
    for id in allIds where id == User.currentId {
        allIds.remove(at: allIds.firstIndex(of: id)!)
    }
    return allIds
}
