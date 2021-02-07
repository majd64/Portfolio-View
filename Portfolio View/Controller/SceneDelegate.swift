//
//  SceneDelegate.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-06-23.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let defaults = UserDefaults.standard


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
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
        CoinHandler.globalRefresh()
        session()
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func session(){
        guard let deviceId = defaults.string(forKey: "deviceId") else{
            return
        }
        let url = URL(string: "\(K.api)/session/\(deviceId)")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let today = Date()
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .full
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: today)
        let minutes = calendar.component(.minute, from: today)
        let date = "\(formatter1.string(from: today)). \(hour):\(minutes)"
    
        let parameters: [String: Any] = [
            "deviceToken": defaults.string(forKey: "deviceToken") ?? "",
            "lastSession": date,
            "premium": defaults.bool(forKey: "premium"),
            "preferredCurrency": defaults.string(forKey: "preferredCurrency") ?? "",
            "volatilityAlerts": defaults.bool(forKey: "volatilityAlertsEnabled") ? 1 : 0
        ]
        request.httpBody = parameters.percentEncoded()

        let task = URLSession.shared.dataTask(with: request) { data, response, error in}
        task.resume()
    }
}

