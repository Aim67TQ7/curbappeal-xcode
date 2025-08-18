import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject {
    
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        setupNotificationCategories()
    }
    
    private func setupNotificationCategories() {
        let viewAction = UNNotificationAction(
            identifier: "VIEW_PROPERTY",
            title: "View Property",
            options: [.foreground]
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Dismiss",
            options: [.destructive]
        )
        
        let saveAction = UNNotificationAction(
            identifier: "SAVE_PROPERTY",
            title: "Save for Later",
            options: []
        )
        
        let propertyCategory = UNNotificationCategory(
            identifier: "PROPERTY_ALERT",
            actions: [viewAction, saveAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        let priceChangeCategory = UNNotificationCategory(
            identifier: "PRICE_CHANGE",
            actions: [viewAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([propertyCategory, priceChangeCategory])
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .carPlay]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func sendLocationNotification(title: String, body: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "PROPERTY_ALERT"
        content.userInfo = ["property_id": identifier]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }
    
    func schedulePropertyReminder(property: Property, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Property Viewing Reminder"
        content.body = "Don't forget to view the property at \(property.address)"
        content.sound = .default
        content.categoryIdentifier = "PROPERTY_ALERT"
        content.userInfo = [
            "property_id": property.id,
            "address": property.address
        ]
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "reminder_\(property.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling reminder: \(error.localizedDescription)")
            }
        }
    }
    
    func sendPriceChangeNotification(property: Property, oldPrice: Double, newPrice: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Price Change Alert"
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        
        let oldPriceString = formatter.string(from: NSNumber(value: oldPrice)) ?? "$\(oldPrice)"
        let newPriceString = formatter.string(from: NSNumber(value: newPrice)) ?? "$\(newPrice)"
        
        let changePercent = ((newPrice - oldPrice) / oldPrice) * 100
        let changeDirection = newPrice < oldPrice ? "decreased" : "increased"
        
        content.body = "Property at \(property.address) has \(changeDirection) from \(oldPriceString) to \(newPriceString) (\(String(format: "%.1f", abs(changePercent)))%)"
        content.sound = .default
        content.categoryIdentifier = "PRICE_CHANGE"
        content.userInfo = [
            "property_id": property.id,
            "old_price": oldPrice,
            "new_price": newPrice
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "price_\(property.id)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending price change notification: \(error.localizedDescription)")
            }
        }
    }
    
    func sendNewPropertyNotification(property: Property) {
        let content = UNMutableNotificationContent()
        content.title = "New Property Available"
        content.body = "A new property matching your criteria is available at \(property.address)"
        content.sound = .default
        content.categoryIdentifier = "PROPERTY_ALERT"
        content.badge = 1
        content.userInfo = [
            "property_id": property.id,
            "address": property.address,
            "price": property.price
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "new_\(property.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending new property notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func handleRemoteNotification(userInfo: [AnyHashable: Any]) {
        guard let propertyId = userInfo["property_id"] as? String else { return }
        
        NotificationCenter.default.post(
            name: Notification.Name("OpenPropertyDetail"),
            object: nil,
            userInfo: ["property_id": propertyId]
        )
    }
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
    
    func updateBadgeCount(_ count: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        switch response.actionIdentifier {
        case "VIEW_PROPERTY":
            if let propertyId = userInfo["property_id"] as? String {
                NotificationCenter.default.post(
                    name: Notification.Name("OpenPropertyDetail"),
                    object: nil,
                    userInfo: ["property_id": propertyId]
                )
            }
            
        case "SAVE_PROPERTY":
            if let propertyId = userInfo["property_id"] as? String {
                NotificationCenter.default.post(
                    name: Notification.Name("SaveProperty"),
                    object: nil,
                    userInfo: ["property_id": propertyId]
                )
            }
            
        case UNNotificationDefaultActionIdentifier:
            if let propertyId = userInfo["property_id"] as? String {
                NotificationCenter.default.post(
                    name: Notification.Name("OpenPropertyDetail"),
                    object: nil,
                    userInfo: ["property_id": propertyId]
                )
            }
            
        default:
            break
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}