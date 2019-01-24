//
//  AppDelegate.swift
//  Weibo
//
//  Created by 王 焕 on 16/3/18.
//  Copyright © 2016年 redoca. All rights reserved.
//

import UIKit

import SVProgressHUD

let SwitchRootViewControllerKey = "SwitchRootViewControllerKey"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // 加载数据库
        SQLiteManager.shareManager().openDB("weibo.db")
        
        // 注册切换主视图通
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.switchRootViewController(_:)), name: NSNotification.Name(rawValue: SwitchRootViewControllerKey), object: nil)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        window?.rootViewController = defaultController()
        window?.makeKeyAndVisible()

//        // App 整体样式设置
        setAppearance()
        
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     切换主视图
     */
    func switchRootViewController(_ notify: Notification) {
        if notify.object as! Bool {
            window!.rootViewController = MainViewController()
        } else {
            window!.rootViewController = WelcomeViewController()
        }
    }
    
    /**
     App 整体样式设置
     */
    private func setAppearance() {
        // 样式设置
        UINavigationBar.appearance().tintColor = UIColor.orange
        UITabBar.appearance().tintColor = UIColor.orange
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.setMinimumDismissTimeInterval(1.2)
    }
    
    /**
     判断进入视图
     
     - returns: 视图
     */
    private func defaultController() -> UIViewController {
        if UserAccount.userLogin() {
            return isNewUpdate() ? NewsFeatureViewController(): WelcomeViewController()
        } else {
            return MainViewController()
        }
    }
    
    /**
     判断版本更新
     
     - returns: 是否有更新
     */
    private func isNewUpdate() -> Bool{
        // 1.获取当前软件的版本号 --> info.plist
        let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        
        // 2.获取以前的软件版本号 --> 从本地文件中读取(以前自己存储的)
        let sandboxVersion =  UserDefaults.standard.object(forKey: "CFBundleShortVersionString") as? String ?? ""
        
        //        var temp = nil ?? "123"
        //        print(temp)
        
        print("current = \(currentVersion) sandbox = \(sandboxVersion)")
        
        // 3.比较当前版本号和以前版本号
        //   2.0                    1.0
        if currentVersion.compare(sandboxVersion) == ComparisonResult.orderedDescending
        {
            // 3.1如果当前>以前 --> 有新版本
            // 3.1.1存储当前最新的版本号
            // iOS7以后就不用调用同步方法了
            UserDefaults.standard.set(currentVersion, forKey: "CFBundleShortVersionString")
            return true
        }
        
        // 3.2如果当前< | ==  --> 没有新版本
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // 清除过期数据
        StatusDAO.cleanStatuses()
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


}

