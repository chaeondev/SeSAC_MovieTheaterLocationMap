//
//  ViewController.swift
//  MovieTheaterLocationMap
//
//  Created by ChaewonMac on 2023/08/23.
//

import UIKit
import CoreLocation
import MapKit
import SnapKit

class ViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    
    let mapView = MKMapView()
    let locationButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "location"), for: .normal)
        view.tintColor = .black
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        return view
    }()
    let filterButton = {
        let view = UIButton()
        view.setTitle("Theater Filter", for: .normal)
        view.setTitleColor(UIColor.blue, for: .normal)
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.topMargin.equalTo(30)
            make.bottom.equalToSuperview()
        }
        
        view.addSubview(locationButton)
        locationButton.addTarget(self, action: #selector(locationButtonClicked), for: .touchUpInside)
        locationButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(120)
            make.trailing.equalToSuperview().inset(30)
            make.size.equalTo(35)
        }
        
        view.addSubview(filterButton)
        filterButton.addTarget(self, action: #selector(filterButtonClicked), for: .touchUpInside)
        filterButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(30)
        }
        
        locationManager.delegate = self
        
        checkDeviceLocationAuthorization()
        setAnnotation(type: .all)
        
    }
    
    @objc func locationButtonClicked() {
        if self.locationManager.authorizationStatus == .denied {
            showRequestLocationServiceAlert()
        }
    }
    
    @objc func filterButtonClicked() {
        showTheaterOptionsAlert()
    }
    
    func setRegionAndAnnotation(center: CLLocationCoordinate2D, title: String) {
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
    
    func setAnnotation(type: annotationType) {
        
        switch type {
            
        case .all:
            mapView.removeAnnotations(mapView.annotations)
            var annotationList: [MKAnnotation] = []
            for theater in TheaterList().mapAnnotations {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: theater.latitude, longitude: theater.longitude)
                annotationList.append(annotation)
            }
            mapView.addAnnotations(annotationList)
        case .lotte:
            mapView.removeAnnotations(mapView.annotations)
            var annotationList: [MKAnnotation] = []
            for theater in TheaterList().mapAnnotations {
                if theater.type == "롯데시네마" {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: theater.latitude, longitude: theater.longitude)
                    annotationList.append(annotation)
                }
            }
            mapView.addAnnotations(annotationList)
        case .mega:
            mapView.removeAnnotations(mapView.annotations)
            var annotationList: [MKAnnotation] = []
            for theater in TheaterList().mapAnnotations {
                if theater.type == "메가박스" {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: theater.latitude, longitude: theater.longitude)
                    annotationList.append(annotation)
                }
            }
            mapView.addAnnotations(annotationList)
        case .cgv:
            mapView.removeAnnotations(mapView.annotations)
            var annotationList: [MKAnnotation] = []
            for theater in TheaterList().mapAnnotations {
                if theater.type == "CGV" {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: theater.latitude, longitude: theater.longitude)
                    annotationList.append(annotation)
                }
            }
            mapView.addAnnotations(annotationList)
        }
        
    }

    func checkDeviceLocationAuthorization() {

        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {

                let authorization: CLAuthorizationStatus

                if #available(iOS 14.0, *) {
                    authorization = self.locationManager.authorizationStatus
                } else {
                    authorization = CLLocationManager.authorizationStatus()
                }

                DispatchQueue.main.async {
                    self.checkCurrentLocationAuthorization(status: authorization)
                }

            } else {
                self.showLocationDeniedAlert()
            }
        }

    }

    func checkCurrentLocationAuthorization(status: CLAuthorizationStatus) {

        switch status {
        case .notDetermined:
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
            let center = CLLocationCoordinate2D(latitude: 37.517829, longitude: 126.886270)
            setRegionAndAnnotation(center: center, title: "청년취업사관학교")
        case .authorizedAlways:
            print("authorizedAlways")
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            locationManager.startUpdatingLocation()
            
        @unknown default:
            print("default")
        }

    }

    
    
}

extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let currentCoordinate = locations.last?.coordinate {
            setRegionAndAnnotation(center: currentCoordinate, title: "내 위치")
        }

    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkDeviceLocationAuthorization()
    }
}

extension ViewController {

    func showLocationDeniedAlert() {

        let alert = UIAlertController(title: "위치 정보 이용", message: "위치 서비스가 꺼져있어서 위치 권한 요청을 못합니다.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)

        present(alert, animated: true)
    }

    func showRequestLocationServiceAlert() {
      let requestLocationServiceAlert = UIAlertController(title: "위치정보 이용", message: "위치 서비스를 사용할 수 없습니다. 기기의 '설정>개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
      let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
          if let appSetting = URL(string: UIApplication.openSettingsURLString) {
              UIApplication.shared.open(appSetting)
          }
      }
      let cancel = UIAlertAction(title: "취소", style: .default)
      requestLocationServiceAlert.addAction(cancel)
      requestLocationServiceAlert.addAction(goSetting)

      present(requestLocationServiceAlert, animated: true, completion: nil)
    }
    
    func showTheaterOptionsAlert() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let mega = UIAlertAction(title: "메가박스", style: .default) { _ in
            self.setAnnotation(type: .mega)
        }
        let lotte = UIAlertAction(title: "롯데시네마", style: .default) { _ in
            self.setAnnotation(type: .lotte)
        }
        let cgv = UIAlertAction(title: "CGV", style: .default) { _ in
            self.setAnnotation(type: .cgv)
        }
        let all = UIAlertAction(title: "전체보기", style: .default) { _ in
            self.setAnnotation(type: .all)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(mega)
        alert.addAction(lotte)
        alert.addAction(cgv)
        alert.addAction(all)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}
