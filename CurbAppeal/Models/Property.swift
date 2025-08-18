import Foundation
import CoreLocation

struct Property: Codable {
    let id: String
    let address: String
    let price: Double
    let bedrooms: Int
    let bathrooms: Double
    let squareFeet: Int
    let lotSize: Double
    let yearBuilt: Int
    let propertyType: PropertyType
    let listingStatus: ListingStatus
    let description: String
    let features: [String]
    let images: [String]
    let latitude: Double
    let longitude: Double
    let listingDate: Date
    let lastUpdated: Date
    let agentName: String?
    let agentPhone: String?
    let agentEmail: String?
    let virtualTourURL: String?
    let neighborhood: String?
    let school: String?
    let isFavorite: Bool
    let viewCount: Int
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
    }
    
    var bathroomDescription: String {
        if bathrooms == Double(Int(bathrooms)) {
            return "\(Int(bathrooms))"
        } else {
            return String(format: "%.1f", bathrooms)
        }
    }
    
    var formattedSquareFeet: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return "\(formatter.string(from: NSNumber(value: squareFeet)) ?? "\(squareFeet)") sq ft"
    }
    
    var formattedLotSize: String {
        return String(format: "%.2f acres", lotSize)
    }
    
    enum PropertyType: String, Codable, CaseIterable {
        case singleFamily = "Single Family"
        case condo = "Condo"
        case townhouse = "Townhouse"
        case multiFamily = "Multi-Family"
        case land = "Land"
        case commercial = "Commercial"
    }
    
    enum ListingStatus: String, Codable, CaseIterable {
        case active = "Active"
        case pending = "Pending"
        case sold = "Sold"
        case offMarket = "Off Market"
        case comingSoon = "Coming Soon"
    }
}

extension Property {
    
    static func mockProperties() -> [Property] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return [
            Property(
                id: UUID().uuidString,
                address: "123 Main Street, San Francisco, CA 94102",
                price: 1250000,
                bedrooms: 3,
                bathrooms: 2.5,
                squareFeet: 2200,
                lotSize: 0.15,
                yearBuilt: 2015,
                propertyType: .singleFamily,
                listingStatus: .active,
                description: "Beautiful modern home with stunning city views",
                features: ["Hardwood Floors", "Granite Countertops", "Smart Home", "Solar Panels"],
                images: ["house1", "house2", "house3"],
                latitude: 37.7749,
                longitude: -122.4194,
                listingDate: formatter.date(from: "2024-01-15") ?? Date(),
                lastUpdated: Date(),
                agentName: "John Smith",
                agentPhone: "(415) 555-0123",
                agentEmail: "john.smith@realestate.com",
                virtualTourURL: "https://example.com/tour/123",
                neighborhood: "SOMA",
                school: "Lincoln Elementary",
                isFavorite: false,
                viewCount: 0
            ),
            Property(
                id: UUID().uuidString,
                address: "456 Oak Avenue, San Francisco, CA 94110",
                price: 899000,
                bedrooms: 2,
                bathrooms: 2,
                squareFeet: 1500,
                lotSize: 0.10,
                yearBuilt: 2008,
                propertyType: .condo,
                listingStatus: .active,
                description: "Spacious condo in prime location with modern amenities",
                features: ["Gym", "Concierge", "Parking", "Rooftop Deck"],
                images: ["condo1", "condo2"],
                latitude: 37.7599,
                longitude: -122.4148,
                listingDate: formatter.date(from: "2024-02-01") ?? Date(),
                lastUpdated: Date(),
                agentName: "Jane Doe",
                agentPhone: "(415) 555-0456",
                agentEmail: "jane.doe@realestate.com",
                virtualTourURL: nil,
                neighborhood: "Mission District",
                school: "Mission High School",
                isFavorite: true,
                viewCount: 15
            )
        ]
    }
}