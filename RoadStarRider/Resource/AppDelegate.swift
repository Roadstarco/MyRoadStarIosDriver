//
//  AppDelegate.swift
//  RoadStarRider
//
//  Created by Faizan Ali  on 2020/9/7.
//  Copyright © 2020 Faizan Ali . All rights reserved.
//

import UIKit
import SideMenu
import GoogleMaps
import Firebase
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var redirect : RedirectHelper!
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        FirebaseApp.configure()
        if #available(iOS 13, *) {
            //It will start from SceneDelegate
            
        } else {
            
            let frame = UIScreen.main.bounds
            self.window = UIWindow(frame: frame)
            redirect = RedirectHelper(window: window)
            redirect.determineRoutes()
        }
        
//        GMSServices.provideAPIKey("AIzaSyB_Ze9iBEnviyL0fdVtYD3T3xEHjjWoWzo")
//        GMSServices.provideAPIKey("AIzaSyA5l_TkMB4GUvCJx_lNcgz23CjFjdYwmc8")
        GMSServices.provideAPIKey("AIzaSyCO--TQ_iF9WC2_Gv7KgjasEmnEoxwbF-E")
        
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        // Override point for customization after application launch.
        return true
    }
    
    func setRootController(controller: UIViewController){
        window = window ?? UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = controller
        window!.makeKeyAndVisible()
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

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.hexString
        UserDefaults.standard.saveDeviceToken(token: deviceTokenString)
        
        print(deviceTokenString)
    }

}


extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
