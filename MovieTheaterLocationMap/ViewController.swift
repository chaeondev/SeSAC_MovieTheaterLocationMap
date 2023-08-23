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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        view.backgroundColor = .white
        
        
        
        checkDeviceLocationAuthorization()
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
}
