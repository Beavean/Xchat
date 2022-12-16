//
//  LocationMessage.swift
//  Xchat
//
//  Created by Beavean on 02.12.2022.
//

import Foundation
import CoreLocation
import MessageKit

final class LocationMessage: NSObject, LocationItem {

    var location: CLLocation
    var size: CGSize

    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
}
