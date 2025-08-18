import UIKit
import UserNotifications
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let notificationManager = NotificationManager.shared
    let locationManager = LocationManager.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupAppearance()
        
        requestNotificationAuthorization()
        
        locationManager.requestLocationPermission()
        
        UIApplication.shared.registerForRemoteNotifications()
        
        return true
    }
    
    private func setupAppearance() {
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.86, alpha: 1.0)
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
        } else {
            UINavigationBar.appearance().barTintColor = UIColor(red: 0.2, green: 0.6, blue: 0.86, alpha: 1.0)
            UINavigationBar.appearance().tintColor = .white
            UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        }
        
        UINavigationBar.appearance().tintColor = .white
    }
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else if let error = error {
                print("Error requesting notifications permission: \(error.localizedDescription)")
            }
        }
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        notificationManager.handleRemoteNotification(userInfo: userInfo)
        completionHandler(.newData)
    }
}