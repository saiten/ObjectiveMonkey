//
//  AppDelegate.swift
//  ObjectiveMonkeySample
//
//  Created by saiten on 2016/12/20.
//

import UIKit
import ObjectiveMonkey

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // local file patch
        let url = Bundle.main.url(forResource: "patch", withExtension: "js")!
        let script = try! String(contentsOf: url)
        ObjectiveMonkey.default().patch(from: script)
        
        // remote file patch
        //ObjectiveMonkey.default().patch(from: URL(string: "https://saiten.co/test/patch.js")!)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }


}

