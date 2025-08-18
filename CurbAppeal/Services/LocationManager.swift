import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject {
    
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    private var locationUpdateHandler: ((CLLocation) -> Void)?
    private var authorizationHandler: ((CLAuthorizationStatus) -> Void)?
    
    var lastKnownLocation: CLLocation? {
        return currentLocation
    }
    
    private override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.showsBackgroundLocationIndicator = true
    }
    
    func requestLocationPermission() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            showLocationPermissionAlert()
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func startMonitoringSignificantLocationChanges() {
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitoringSignificantLocationChanges() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func updateLocation() {
        locationManager.requestLocation()
    }
    
    func setLocationUpdateHandler(_ handler: @escaping (CLLocation) -> Void) {
        self.locationUpdateHandler = handler
    }
    
    func setAuthorizationHandler(_ handler: @escaping (CLAuthorizationStatus) -> Void) {
        self.authorizationHandler = handler
    }
    
    func createRegionForProperty(identifier: String, coordinate: CLLocationCoordinate2D, radius: CLLocationDistance = 100) {
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            let region = CLCircularRegion(center: coordinate,
                                         radius: radius,
                                         identifier: identifier)
            region.notifyOnEntry = true
            region.notifyOnExit = true
            
            locationManager.startMonitoring(for: region)
        }
    }
    
    func stopMonitoringRegion(identifier: String) {
        for region in locationManager.monitoredRegions {
            if region.identifier == identifier {
                locationManager.stopMonitoring(for: region)
                break
            }
        }
    }
    
    func getDistanceFromLocation(_ location: CLLocation) -> CLLocationDistance? {
        guard let currentLocation = currentLocation else { return nil }
        return currentLocation.distance(from: location)
    }
    
    private func showLocationPermissionAlert() {
        DispatchQueue.main.async {
            if let topController = UIApplication.shared.windows.first?.rootViewController {
                let alert = UIAlertController(
                    title: "Location Access Required",
                    message: "CurbAppeal needs access to your location to show nearby properties and send relevant notifications. Please enable location access in Settings.",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                })
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                topController.present(alert, animated: true)
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        locationUpdateHandler?(location)
        
        NotificationCenter.default.post(
            name: Notification.Name("LocationDidUpdate"),
            object: nil,
            userInfo: ["location": location]
        )
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                showLocationPermissionAlert()
            case .locationUnknown:
                print("Location is currently unknown, but Core Location will keep trying")
            default:
                print("Location error: \(clError.localizedDescription)")
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        authorizationHandler?(status)
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingLocation()
        case .denied, .restricted:
            stopUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let circularRegion = region as? CLCircularRegion {
            NotificationManager.shared.sendLocationNotification(
                title: "Property Nearby",
                body: "You're near a property you've shown interest in!",
                identifier: circularRegion.identifier
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited region: \(region.identifier)")
    }
}