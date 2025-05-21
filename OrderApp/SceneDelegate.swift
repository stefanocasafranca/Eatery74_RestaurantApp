//
//  SceneDelegate.swift
//  OrderApp
//
//  Created by Stefano Casafranca on 5/3/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // This is a reference to the second tab bar item (Order tab).
    // It's used to display a badge with the current number of menu items in the order.
    var orderTabBarItem: UITabBarItem!

    @objc func updateOrderBadge() {
        /*Before: orderTabBarItem.badgeValue = String(MenuController.shared.order.menuItems.count) */
        switch MenuController.shared.order.menuItems.count {
            case 0:
            orderTabBarItem.badgeValue = nil
        case let count: orderTabBarItem.badgeValue = String(count)
        }
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        // Subscribe to order update notifications to refresh the badge when items are added/removed.
        NotificationCenter.default.addObserver(self, selector: #selector(updateOrderBadge), name: MenuController.orderUpdatedNotification, object: nil)

        // Grab the Order tab (second tab) from the Tab Bar Controller to update its badge later.
        orderTabBarItem = (window?.rootViewController as? UITabBarController)?.viewControllers?[1].tabBarItem

        
        // Initialize OrderHistory to load any saved orders
        _ = OrderHistory.shared
        
        
        guard let _ = (scene as? UIWindowScene) else { return }
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

