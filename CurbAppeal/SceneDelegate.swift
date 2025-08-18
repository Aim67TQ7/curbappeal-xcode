import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let initialViewController = storyboard.instantiateInitialViewController() {
            window?.rootViewController = initialViewController
        }
        
        window?.makeKeyAndVisible()
        
        LocationManager.shared.startMonitoringSignificantLocationChanges()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        LocationManager.shared.updateLocation()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}