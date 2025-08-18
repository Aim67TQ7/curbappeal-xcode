import UIKit
import MapKit
import MessageUI

class PropertyDetailViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var bedroomsLabel: UILabel!
    @IBOutlet weak var bathroomsLabel: UILabel!
    @IBOutlet weak var squareFeetLabel: UILabel!
    @IBOutlet weak var lotSizeLabel: UILabel!
    @IBOutlet weak var yearBuiltLabel: UILabel!
    @IBOutlet weak var propertyTypeLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var featuresStackView: UIStackView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var agentNameLabel: UILabel!
    @IBOutlet weak var agentPhoneButton: UIButton!
    @IBOutlet weak var agentEmailButton: UIButton!
    @IBOutlet weak var virtualTourButton: UIButton!
    @IBOutlet weak var scheduleViewingButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var property: Property!
    private let notificationManager = NotificationManager.shared
    private let locationManager = LocationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayPropertyDetails()
        setupMap()
        trackPropertyView()
    }
    
    private func setupUI() {
        title = "Property Details"
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(shareProperty)),
            UIBarButtonItem(image: UIImage(systemName: property.isFavorite ? "star.fill" : "star"), style: .plain, target: self, action: #selector(toggleFavorite))
        ]
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        imageCollectionView.collectionViewLayout = layout
        imageCollectionView.isPagingEnabled = true
        imageCollectionView.showsHorizontalScrollIndicator = false
        
        scheduleViewingButton.layer.cornerRadius = 8
        scheduleViewingButton.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.86, alpha: 1.0)
        scheduleViewingButton.setTitleColor(.white, for: .normal)
        
        virtualTourButton.layer.cornerRadius = 8
        virtualTourButton.layer.borderWidth = 1
        virtualTourButton.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    private func displayPropertyDetails() {
        priceLabel.text = property.formattedPrice
        addressLabel.text = property.address
        
        statusLabel.text = property.listingStatus.rawValue
        switch property.listingStatus {
        case .active:
            statusLabel.textColor = .systemGreen
        case .pending:
            statusLabel.textColor = .systemOrange
        case .sold:
            statusLabel.textColor = .systemRed
        case .comingSoon:
            statusLabel.textColor = .systemBlue
        case .offMarket:
            statusLabel.textColor = .systemGray
        }
        
        bedroomsLabel.text = "\(property.bedrooms) Bedrooms"
        bathroomsLabel.text = "\(property.bathroomDescription) Bathrooms"
        squareFeetLabel.text = property.formattedSquareFeet
        lotSizeLabel.text = "Lot: \(property.formattedLotSize)"
        yearBuiltLabel.text = "Built: \(property.yearBuilt)"
        propertyTypeLabel.text = property.propertyType.rawValue
        
        descriptionTextView.text = property.description
        
        featuresStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for feature in property.features {
            let featureView = createFeatureView(feature)
            featuresStackView.addArrangedSubview(featureView)
        }
        
        if let agentName = property.agentName {
            agentNameLabel.text = agentName
        } else {
            agentNameLabel.text = "No Agent Listed"
        }
        
        if let agentPhone = property.agentPhone {
            agentPhoneButton.setTitle(agentPhone, for: .normal)
            agentPhoneButton.isEnabled = true
        } else {
            agentPhoneButton.setTitle("No Phone", for: .normal)
            agentPhoneButton.isEnabled = false
        }
        
        if let agentEmail = property.agentEmail {
            agentEmailButton.setTitle(agentEmail, for: .normal)
            agentEmailButton.isEnabled = true
        } else {
            agentEmailButton.setTitle("No Email", for: .normal)
            agentEmailButton.isEnabled = false
        }
        
        virtualTourButton.isHidden = property.virtualTourURL == nil
        
        pageControl.numberOfPages = property.images.isEmpty ? 1 : property.images.count
        pageControl.currentPage = 0
    }
    
    private func createFeatureView(_ feature: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 6
        
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        imageView.tintColor = .systemGreen
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = feature
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(imageView)
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 36),
            
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            imageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20),
            
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        return containerView
    }
    
    private func setupMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = property.coordinate
        annotation.title = property.address
        mapView.addAnnotation(annotation)
        
        let region = MKCoordinateRegion(
            center: property.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        mapView.setRegion(region, animated: false)
        
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
    }
    
    private func trackPropertyView() {
        
        locationManager.createRegionForProperty(
            identifier: property.id,
            coordinate: property.coordinate,
            radius: 200
        )
    }
    
    @IBAction func callAgent(_ sender: UIButton) {
        guard let phone = property.agentPhone,
              let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "-", with: ""))") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func emailAgent(_ sender: UIButton) {
        guard let email = property.agentEmail else { return }
        
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients([email])
            mailComposer.setSubject("Inquiry about property at \(property.address)")
            mailComposer.setMessageBody("I am interested in the property at \(property.address) listed at \(property.formattedPrice).", isHTML: false)
            present(mailComposer, animated: true)
        } else if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func openVirtualTour(_ sender: UIButton) {
        guard let urlString = property.virtualTourURL,
              let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func scheduleViewing(_ sender: UIButton) {
        let alert = UIAlertController(title: "Schedule Viewing", message: "Select a date and time for your viewing", preferredStyle: .alert)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date()
        
        alert.setValue(datePicker, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Schedule", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.notificationManager.schedulePropertyReminder(property: self.property, date: datePicker.date)
            self.showConfirmation("Viewing scheduled for \(DateFormatter.localizedString(from: datePicker.date, dateStyle: .medium, timeStyle: .short))")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func shareProperty() {
        let text = """
        Check out this property!
        
        \(property.address)
        \(property.formattedPrice)
        \(property.bedrooms) bed, \(property.bathroomDescription) bath
        \(property.formattedSquareFeet)
        
        \(property.description)
        """
        
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItems?.first
        }
        
        present(activityVC, animated: true)
    }
    
    @objc private func toggleFavorite() {
        property = Property(
            id: property.id,
            address: property.address,
            price: property.price,
            bedrooms: property.bedrooms,
            bathrooms: property.bathrooms,
            squareFeet: property.squareFeet,
            lotSize: property.lotSize,
            yearBuilt: property.yearBuilt,
            propertyType: property.propertyType,
            listingStatus: property.listingStatus,
            description: property.description,
            features: property.features,
            images: property.images,
            latitude: property.latitude,
            longitude: property.longitude,
            listingDate: property.listingDate,
            lastUpdated: property.lastUpdated,
            agentName: property.agentName,
            agentPhone: property.agentPhone,
            agentEmail: property.agentEmail,
            virtualTourURL: property.virtualTourURL,
            neighborhood: property.neighborhood,
            school: property.school,
            isFavorite: !property.isFavorite,
            viewCount: property.viewCount
        )
        
        navigationItem.rightBarButtonItems?[1].image = UIImage(systemName: property.isFavorite ? "star.fill" : "star")
        
        showConfirmation(property.isFavorite ? "Added to favorites" : "Removed from favorites")
    }
    
    private func showConfirmation(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }
}

extension PropertyDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return property.images.isEmpty ? 1 : property.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        
        if let imageView = cell.viewWithTag(100) as? UIImageView {
            imageView.image = UIImage(systemName: "house.fill")
            imageView.tintColor = .systemGray3
            imageView.contentMode = .scaleAspectFit
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == imageCollectionView {
            let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
            pageControl.currentPage = page
        }
    }
}

extension PropertyDetailViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}