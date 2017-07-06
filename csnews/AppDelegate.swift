//
//  AppDelegate.swift
//  csnews
//
//  Created by Nikhil Gohil on 31/08/15.
//  Copyright (c) 2015 Nikhil Gohil. All rights reserved.
//

import UIKit
import Contentstack

enum LanguageType : Int {
    case english
    case hindi
}

let AccessToken = "blt0c4300391e033d4a59eb2857"
let APIKEY = "blt920bb7e90248f607"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let stack:Stack = Contentstack.stack(withAPIKey: APIKEY, accessToken: AccessToken, environmentName: "production")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        applyThemeToNavigationBar()
        
        return true
    }
    
    static func sharedAppDelegate() -> AppDelegate{
        return (UIApplication.shared.delegate as! AppDelegate)
    }
    
    static func sharedSite() -> Stack{
        return (UIApplication.shared.delegate as! AppDelegate).stack
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func applyThemeToNavigationBar(){
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        UINavigationBar.appearance().barTintColor = UIColor(hexString: "#E44B4E")
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
    }
    
}

