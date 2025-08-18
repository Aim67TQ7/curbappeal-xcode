import UIKit
import MapKit
import CoreLocation

class HomeViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    private var properties: [Property] = []
    private var annotations: [MKAnnotation] = []
    private let locationManager = LocationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMap()
        setupNotifications()
        loadProperties()
        requestLocationUpdates()
    }
    
    private func setupUI() {
        title = "CurbAppeal"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        searchBar.delegate = self
        searchBar.placeholder = "Search address, city, or ZIP"
        
        filterButton.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        filterButton.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        
        listButton.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        listButton.addTarget(self, action: #selector(showListView), for: .touchUpInside)
        
        currentLocationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        currentLocationButton.addTarget(self, action: #selector(centerOnCurrentLocation), for: .touchUpInside)
        currentLocationButton.layer.cornerRadius = 25
        currentLocationButton.backgroundColor = .systemBackground
        currentLocationButton.layer.shadowColor = UIColor.black.cgColor
        currentLocationButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        currentLocationButton.layer.shadowOpacity = 0.3
        currentLocationButton.layer.shadowRadius = 4
    }
    
    private func setupMap() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        
        let initialLocation = CLLocation(latitude: 37.7749, longitude: -122.4194)
        centerMapOnLocation(location: initialLocation, radius: 5000)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(locationDidUpdate(_:)),
            name: Notification.Name("LocationDidUpdate"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(openPropertyDetail(_:)),
            name: Notification.Name("OpenPropertyDetail"),
            object: nil
        )
    }
    
    private func loadProperties() {
        properties = Property.mockProperties()
        addPropertiesToMap()
    }
    
    private func addPropertiesToMap() {
        mapView.removeAnnotations(annotations)
        annotations.removeAll()
        
        for property in properties {
            let annotation = PropertyAnnotation(property: property)
            annotations.append(annotation)
            mapView.addAnnotation(annotation)
        }
    }
    
    private func centerMapOnLocation(location: CLLocation, radius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radius * 2,
            longitudinalMeters: radius * 2
        )
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func requestLocationUpdates() {
        locationManager.setLocationUpdateHandler { [weak self] location in
            self?.updateUserLocation(location)
        }
        locationManager.startUpdatingLocation()
    }
    
    private func updateUserLocation(_ location: CLLocation) {
        
    }
    
    @objc private func filterTapped() {
        let alert = UIAlertController(title: "Filter Properties", message: "Select your criteria", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Price: Low to High", style: .default) { [weak self] _ in
            self?.properties.sort { $0.price < $1.price }
            self?.addPropertiesToMap()
        })
        
        alert.addAction(UIAlertAction(title: "Price: High to Low", style: .default) { [weak self] _ in
            self?.properties.sort { $0.price > $1.price }
            self?.addPropertiesToMap()
        })
        
        alert.addAction(UIAlertAction(title: "Newest First", style: .default) { [weak self] _ in
            self?.properties.sort { $0.listingDate > $1.listingDate }
            self?.addPropertiesToMap()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = filterButton
            popover.sourceRect = filterButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    @objc private func showListView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let listVC = storyboard.instantiateViewController(withIdentifier: "PropertyListViewController") as? PropertyListViewController {
            listVC.properties = properties
            navigationController?.pushViewController(listVC, animated: true)
        }
    }
    
    @objc private func centerOnCurrentLocation() {
        if let location = locationManager.lastKnownLocation {
            centerMapOnLocation(location: location, radius: 2000)
        } else {
            let alert = UIAlertController(
                title: "Location Not Available",
                message: "Please enable location services to use this feature.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    @objc private func locationDidUpdate(_ notification: Notification) {
        if let location = notification.userInfo?["location"] as? CLLocation {
            updateUserLocation(location)
        }
    }
    
    @objc private func openPropertyDetail(_ notification: Notification) {
        if let propertyId = notification.userInfo?["property_id"] as? String,
           let property = properties.first(where: { $0.id == propertyId }) {
            showPropertyDetail(property)
        }
    }
    
    private func showPropertyDetail(_ property: Property) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "PropertyDetailViewController") as? PropertyDetailViewController {
            detailVC.property = property
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchText) { [weak self] placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first,
               let location = placemark.location {
                self?.centerMapOnLocation(location: location, radius: 2000)
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
}

extension HomeViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        guard let propertyAnnotation = annotation as? PropertyAnnotation else {
            return nil
        }
        
        let identifier = "PropertyAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.markerTintColor = propertyAnnotation.property.listingStatus == .active ? .systemGreen : .systemGray
        annotationView?.glyphText = "$"
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let propertyAnnotation = view.annotation as? PropertyAnnotation else { return }
        showPropertyDetail(propertyAnnotation.property)
    }
}

class PropertyAnnotation: NSObject, MKAnnotation {
    let property: Property
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    
    init(property: Property) {
        self.property = property
        self.coordinate = property.coordinate
        self.title = property.formattedPrice
        self.subtitle = "\(property.bedrooms) bed, \(property.bathroomDescription) bath • \(property.formattedSquareFeet)"
        super.init()
    }
}