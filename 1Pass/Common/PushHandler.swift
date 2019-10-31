//
//  PushHandler.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class PushHandler:NSObject {
    
    public class func showTabbarBadgeCount(index:Int) {
       /* let df = UserDefaults.standard
        var count:Int = Utils.getInt(df.integer(forKey: Constant.pushCount))
        if (count <= 0) && (UIApplication.shared.applicationIconBadgeNumber == 0) {
            return
        }
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if let tabBarController = delegate.mainVC {
            if let tabItems = tabBarController.tabBar.items as NSArray! {
                // In this case we want to modify the badge number of the third tab:
                let tabItem = tabItems[index] as! UITabBarItem
                tabItem.badgeValue = "1+"
                UIApplication.shared.applicationIconBadgeNumber = 1
            }
        }*/
    }
    
    public class func setTabbarBadgeCount(index:Int) {
       /* let df = UserDefaults.standard
        var count:Int = Utils.getInt(df.integer(forKey: Constant.pushCount))
        count += 1
        df.set(count, forKey: Constant.pushCount)
        
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if let tabBarController = delegate.mainVC {
            if let tabItems = tabBarController.tabBar.items as NSArray! {
                // In this case we want to modify the badge number of the third tab:
                let tabItem = tabItems[index] as! UITabBarItem
                tabItem.badgeValue = "1+"
                UIApplication.shared.applicationIconBadgeNumber = 1
            }
        }*/
    }
    
    public class func increasePushBadgeCount() {
       /* let df = UserDefaults.standard
        var count:Int = Utils.getInt(df.integer(forKey: Constant.pushCount))
        count += 1
        df.set(count, forKey: Constant.pushCount)
        
    */
    }
    
    public class func clearTabbarBadgeCount(index:Int) {
        /*let df = UserDefaults.standard
        df.removeObject(forKey: Constant.pushCount)
        
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if let tabBarController = delegate.mainVC {
            if let tabItems = tabBarController.tabBar.items as NSArray! {
                // In this case we want to modify the badge number of the third tab:
                let tabItem = tabItems[index] as! UITabBarItem
                tabItem.badgeValue = nil
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }*/
    }
    
    public class func handlePushNotificationWhenAppActive(_ payload:[AnyHashable : Any]) {
        /*let aps:[String:Any] = payload["aps"] as! [String : Any]
        let alert:[String:String] = Utils.getDictionary(aps["alert"]) as! [String : String]
        let title:String = Utils.getString(alert["t`itle"])
        
        Utils.showAlert(title: "Thông báo từ SIM Thăng Long", message: title, dismiss: "OK", block: nil)
        */
 }
    
    public class func userDidTapOnPushNotification(_ payload:[AnyHashable : Any]) {
        /*let aps:[String:Any] = payload["aps"] as! [String : Any]
        let alert:[String:String] = Utils.getDictionary(aps["alert"]) as! [String : String]
        let title:String = Utils.getString(alert["title"])
        let notid = Utils.getString(payload["notid"])
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if let tabBarController = delegate.mainVC {
            tabBarController.selectedIndex = 3
            let navi3: BaseNavi = tabBarController.viewControllers![3] as! BaseNavi
            let notiVC:NotificationVC = navi3.viewControllers[0] as! NotificationVC
            
            let articleVC = ArticleVC(nibName: "ArticleVC", bundle: nil)
            articleVC.title = title
            articleVC.notiID = notid
            
            let nav:UINavigationController = notiVC.navigationController!
            nav.pushViewController(articleVC, animated: true)
        }
         */
    }
    
    public class func doBackgroundFetchPushNotification(_ userInfo: [AnyHashable : Any], _ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
//        let notid = Utils.getString(userInfo["notid"])
//        if !notid.isEmpty  {
//            ParseService.getPushNotificationWithID(notid){ (_ object: PFObject?, _ error: Error?) -> Void in
//                if object != nil {
//                    completionHandler(UIBackgroundFetchResult.newData)
//                } else {
//                    completionHandler(UIBackgroundFetchResult.noData)
//                }
//
//            }
//        }
        
    }
    
}

