//
//  MapAnnotation.swift
//  Xchat
//
//  Created by Beavean on 03.12.2022.
//

import Foundation
import MapKit

final class MapAnnotation: NSObject, MKAnnotation {

    let title: String?
    let coordinate: CLLocationCoordinate2D

    init(title: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
