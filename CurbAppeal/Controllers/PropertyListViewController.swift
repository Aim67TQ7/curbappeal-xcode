import UIKit
import CoreLocation

class PropertyListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    var properties: [Property] = []
    private var filteredProperties: [Property] = []
    private let locationManager = LocationManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        filteredProperties = properties
        sortProperties()
    }
    
    private func setupUI() {
        title = "Properties"
        
        sortSegmentedControl.removeAllSegments()
        sortSegmentedControl.insertSegment(withTitle: "Price", at: 0, animated: false)
        sortSegmentedControl.insertSegment(withTitle: "Distance", at: 1, animated: false)
        sortSegmentedControl.insertSegment(withTitle: "Newest", at: 2, animated: false)
        sortSegmentedControl.selectedSegmentIndex = 0
        sortSegmentedControl.addTarget(self, action: #selector(sortChanged), for: .valueChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.horizontal.3.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(showFilterOptions)
        )
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PropertyTableViewCell.self, forCellReuseIdentifier: "PropertyCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
    }
    
    @objc private func sortChanged() {
        sortProperties()
    }
    
    private func sortProperties() {
        switch sortSegmentedControl.selectedSegmentIndex {
        case 0:
            filteredProperties.sort { $0.price < $1.price }
        case 1:
            if let currentLocation = locationManager.lastKnownLocation {
                filteredProperties.sort {
                    let distance1 = $0.location.distance(from: currentLocation)
                    let distance2 = $1.location.distance(from: currentLocation)
                    return distance1 < distance2
                }
            }
        case 2:
            filteredProperties.sort { $0.listingDate > $1.listingDate }
        default:
            break
        }
        
        tableView.reloadData()
    }
    
    @objc private func showFilterOptions() {
        let alert = UIAlertController(title: "Filter Properties", message: nil, preferredStyle: .actionSheet)
        
        for propertyType in Property.PropertyType.allCases {
            alert.addAction(UIAlertAction(title: propertyType.rawValue, style: .default) { [weak self] _ in
                self?.filterByType(propertyType)
            })
        }
        
        alert.addAction(UIAlertAction(title: "Show All", style: .default) { [weak self] _ in
            self?.filteredProperties = self?.properties ?? []
            self?.sortProperties()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    private func filterByType(_ type: Property.PropertyType) {
        filteredProperties = properties.filter { $0.propertyType == type }
        sortProperties()
    }
}

extension PropertyListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProperties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PropertyCell") as? PropertyTableViewCell ?? PropertyTableViewCell(style: .default, reuseIdentifier: "PropertyCell")
        
        let property = filteredProperties[indexPath.row]
        cell.configure(with: property, currentLocation: locationManager.lastKnownLocation)
        
        return cell
    }
}

extension PropertyListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let property = filteredProperties[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "PropertyDetailViewController") as? PropertyDetailViewController {
            detailVC.property = property
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let property = filteredProperties[indexPath.row]
        
        let favoriteAction = UIContextualAction(style: .normal, title: property.isFavorite ? "Unfavorite" : "Favorite") { [weak self] _, _, completion in
            
            completion(true)
        }
        favoriteAction.backgroundColor = property.isFavorite ? .systemGray : .systemYellow
        favoriteAction.image = UIImage(systemName: property.isFavorite ? "star.slash" : "star.fill")
        
        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let property = filteredProperties[indexPath.row]
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { [weak self] _, _, completion in
            self?.shareProperty(property)
            completion(true)
        }
        shareAction.backgroundColor = .systemBlue
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        
        return UISwipeActionsConfiguration(actions: [shareAction])
    }
    
    private func shareProperty(_ property: Property) {
        let text = """
        Check out this property!
        
        \(property.address)
        \(property.formattedPrice)
        \(property.bedrooms) bed, \(property.bathroomDescription) bath
        \(property.formattedSquareFeet)
        """
        
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        
        present(activityVC, animated: true)
    }
}

class PropertyTableViewCell: UITableViewCell {
    
    private let propertyImageView = UIImageView()
    private let priceLabel = UILabel()
    private let addressLabel = UILabel()
    private let detailsLabel = UILabel()
    private let distanceLabel = UILabel()
    private let statusBadge = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        propertyImageView.translatesAutoresizingMaskIntoConstraints = false
        propertyImageView.contentMode = .scaleAspectFill
        propertyImageView.clipsToBounds = true
        propertyImageView.layer.cornerRadius = 8
        propertyImageView.backgroundColor = .systemGray5
        
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = .systemFont(ofSize: 18, weight: .bold)
        priceLabel.textColor = .label
        
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.font = .systemFont(ofSize: 14, weight: .medium)
        addressLabel.textColor = .secondaryLabel
        addressLabel.numberOfLines = 2
        
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = .systemFont(ofSize: 13)
        detailsLabel.textColor = .tertiaryLabel
        
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.font = .systemFont(ofSize: 12)
        distanceLabel.textColor = .systemBlue
        
        statusBadge.translatesAutoresizingMaskIntoConstraints = false
        statusBadge.font = .systemFont(ofSize: 11, weight: .semibold)
        statusBadge.textColor = .white
        statusBadge.backgroundColor = .systemGreen
        statusBadge.layer.cornerRadius = 4
        statusBadge.clipsToBounds = true
        statusBadge.textAlignment = .center
        
        contentView.addSubview(propertyImageView)
        contentView.addSubview(priceLabel)
        contentView.addSubview(addressLabel)
        contentView.addSubview(detailsLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(statusBadge)
        
        NSLayoutConstraint.activate([
            propertyImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            propertyImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            propertyImageView.widthAnchor.constraint(equalToConstant: 100),
            propertyImageView.heightAnchor.constraint(equalToConstant: 80),
            
            priceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            priceLabel.leadingAnchor.constraint(equalTo: propertyImageView.trailingAnchor, constant: 12),
            priceLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusBadge.leadingAnchor, constant: -8),
            
            statusBadge.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            statusBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            statusBadge.heightAnchor.constraint(equalToConstant: 20),
            
            addressLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            addressLabel.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            detailsLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 4),
            detailsLabel.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
            detailsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            distanceLabel.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: 4),
            distanceLabel.leadingAnchor.constraint(equalTo: priceLabel.leadingAnchor),
            distanceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with property: Property, currentLocation: CLLocation?) {
        priceLabel.text = property.formattedPrice
        addressLabel.text = property.address
        detailsLabel.text = "\(property.bedrooms) bed, \(property.bathroomDescription) bath • \(property.formattedSquareFeet)"
        
        statusBadge.text = property.listingStatus.rawValue
        switch property.listingStatus {
        case .active:
            statusBadge.backgroundColor = .systemGreen
        case .pending:
            statusBadge.backgroundColor = .systemOrange
        case .sold:
            statusBadge.backgroundColor = .systemRed
        case .comingSoon:
            statusBadge.backgroundColor = .systemBlue
        case .offMarket:
            statusBadge.backgroundColor = .systemGray
        }
        
        if let currentLocation = currentLocation {
            let distance = property.location.distance(from: currentLocation) / 1609.34
            distanceLabel.text = String(format: "%.1f miles away", distance)
        } else {
            distanceLabel.text = ""
        }
        
        propertyImageView.image = UIImage(systemName: "house.fill")
        propertyImageView.tintColor = .systemGray3
    }
}