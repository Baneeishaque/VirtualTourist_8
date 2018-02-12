//
//  AppDelegate.swift
//  VirtualTourist_8
//
//  Created by Michelle Grover on 2/10/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let stack = CoreDataStack(modelName: "Model")!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //                do {
        //                    try stack.dropAllData()
        //                } catch {
        //                    print("Error on delete:\(error.localizedDescription)")
        //                }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        do {
            try stack.saveContext()
        } catch {
            print("Error while saving.")
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        do {
            try stack.saveContext()
        } catch {
            print("Error while saving.")
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

