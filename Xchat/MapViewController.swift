//
//  MapViewController.swift
//  Xchat
//
//  Created by Beavean on 03.12.2022.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    // MARK: - Properties

    var location: CLLocation?
    var mapView: MKMapView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTitle()
        configureMapView()
        configureLeftBarButton()
    }

    // MARK: - Configurations

    private func configureMapView() {
        mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        mapView.showsUserLocation = true
        if let location {
            mapView.setCenter(location.coordinate, animated: false)
            mapView.addAnnotation(MapAnnotation(title: "Shared location", coordinate: location.coordinate))
        }
        view.addSubview(mapView)
    }

    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))
    }

    private func configureTitle() {
        self.title = "Map View"
    }

    // MARK: - Actions

    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}
