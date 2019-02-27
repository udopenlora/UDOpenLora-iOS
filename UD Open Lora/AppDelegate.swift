//
//  AppDelegate.swift
//  UD Open Lora
//
//  Created by Khoa Bao on 1/7/19.
//  Copyright © 2019 Khoa Bao. All rights reserved.
//

import UIKit
import Firebase
import AI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        let homeVC = HomeViewController()
        let homeNavigation = UINavigationController(rootViewController: homeVC)
        window?.rootViewController = homeNavigation
        FirebaseApp.configure()
        AI.configure("d9e821efef224183955f13b24017f6ff")
        return true
    }
}

