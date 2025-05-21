//
//  AppDelegate.swift
//  OrderApp
//
//  Created by Stefano Casafranca on 5/3/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Step 10: Creating a new URL Cache before any network requests are made. Now whenever you make requests for images from the server, the data will be placed automatically into this large cache
        
        let temporaryDirectory = NSTemporaryDirectory()
        let urlCache = URLCache(memoryCapacity: 25_000_000, diskCapacity: 50_000_000, diskPath: temporaryDirectory)
        URLCache.shared = urlCache
        
        //This was before anything
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

