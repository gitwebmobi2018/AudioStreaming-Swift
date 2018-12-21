//
//  AppDelegate.swift
//  Jammin92
//
//  Created by gitwebmobi on 10/15/17.
//  Copyright © 2017 gitwebmobi All rights reserved.
//

import UIKit
import AVFoundation

enum PlayStatus {
    case play
    case pause
    case stop
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var player: AVPlayer!
    
    var isInitialLoad:Bool = true

    var audioUrlStr:String = "http://s2.stationplaylist.com:7030/listen.aac.m3u"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        isInitialLoad = true
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //let navBar:UINavigationController = appDelegate.window?.rootViewController as! UINavigationController
        let navBar:DrawerController = appDelegate.window?.rootViewController as! DrawerController

        if let placerVC:PlayerViewController = navBar.centerViewController as? PlayerViewController {
            let url = URL.init(string:audioUrlStr)
            placerVC.player = AVPlayer(url:url!)
            placerVC.player.play()
            //placerVC.player.pause()
            //placerVC.playState = .play
            placerVC.player.addObserver(placerVC, forKeyPath: "status", options: [NSKeyValueObservingOptions.new], context: nil)
            placerVC.player.currentItem?.addObserver(placerVC, forKeyPath: "timedMetadata", options: [], context: nil)
            ///DL
            //placerVC.postTimerUpdate()
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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


extension UINavigationController {
    var rootViewController : UIViewController? {
        return viewControllers.first
    }
}


extension AppDelegate{
    
    func initializePlay() {
       
        let url = URL.init(string: audioUrlStr)
        player = AVPlayer(url:url!)
        player.play()
        self.player.addObserver(self, forKeyPath: "status", options: [NSKeyValueObservingOptions.new], context: nil)        
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }

    func updateTimer()  {
        NotificationCenter.default.post(name: Notification.Name("UpdateTimer"), object: nil)
    }
    
    func postStateChange(_ state: PlayState){
        
        let dict = ["State":state] as NSDictionary
        NotificationCenter.default.post(name: Notification.Name("ChangePlayState"), object: dict)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timedMetadata" {
            let data: AVPlayerItem = object as! AVPlayerItem
            guard let datai:[AVMetadataItem] = data.timedMetadata else {
                return
            }
        }
        else if keyPath == "status"{
            if (self.player.status == .readyToPlay) {
                print("Ready to play")
                
               // self.playState = .play
               // self.postStateChange(PlayState.play)
            }
        }
    }
}

