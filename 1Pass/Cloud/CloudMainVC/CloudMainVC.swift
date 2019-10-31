//
//  CloudMainVC.swift
//  ViPass
//
//  Created by Ngo Lien on 5/9/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class CloudMainVC:UITabBarController, UITabBarControllerDelegate {
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Auto Lock App
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        (TimerApplication.shared as! TimerApplication).resetIdleTimer()
        NotificationCenter.default.addObserver(appDelegate,
                                               selector: #selector(AppDelegate.applicationDidTimeout(notification:)),
                                               name: .appTimeout,
                                               object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.createTabbar()
        self.delegate = self
    }
    
    private func createTabbar() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: AppColor.COLOR_TABBAR, NSAttributedStringKey.font : UIFont(name: "HelveticaNeue", size: 10) as Any], for: .normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: AppColor.COLOR_TABBAR_ACTIVE,NSAttributedStringKey.font : UIFont(name: "HelveticaNeue", size: 10) as Any], for: .selected)
        
        var homeVC:LocalHomeVC!
        if Utils.isPad() {
            homeVC = LocalHomeVC(nibName: "LocalHomePAD", bundle: nil)
        } else {
            homeVC = LocalHomeVC(nibName: "LocalHomeVC", bundle: nil)
        }
        
        var shortcutVC:ShortcutVC!
        if Utils.isPad() {
            shortcutVC = ShortcutVC(nibName: "ShortcutPAD", bundle: nil)
        } else {
            shortcutVC = ShortcutVC(nibName: "ShortcutVC", bundle: nil)
        }
        let settingVC = SettingsVC(nibName: "SettingsVC", bundle: nil)
        
        // Config Tabbar Item
        var icon = UIImage(named: "ic-items")
        icon = icon?.tint(AppColor.COLOR_TABBAR)
        var iconSelected = UIImage(named: "ic-items")
        iconSelected = iconSelected?.tint(AppColor.COLOR_TABBAR_ACTIVE)
        let homeItem = UITabBarItem(title: "HOME", image: icon, selectedImage: iconSelected)
        homeItem.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        
        icon = UIImage(named: "ic-recent")
        icon = icon?.tint(AppColor.COLOR_TABBAR)
        iconSelected = UIImage(named: "ic-recent")
        iconSelected = iconSelected?.tint(AppColor.COLOR_TABBAR_ACTIVE)
        let shortcutItem = UITabBarItem(title: "SHORTCUTS", image: icon, selectedImage: iconSelected)
        shortcutItem.imageInsets = UIEdgeInsetsMake(0, 0, 1, 0)
        
        icon = UIImage(named: "ic-settings")
        icon = icon?.tint(AppColor.COLOR_TABBAR)
        iconSelected = UIImage(named: "ic-settings")
        iconSelected = iconSelected?.tint(AppColor.COLOR_TABBAR_ACTIVE)
        let settingsItem = UITabBarItem(title: "SETTINGS", image: icon, selectedImage: iconSelected)
        settingsItem.imageInsets = UIEdgeInsetsMake(0, 0, 1, 0)
        
        homeVC.tabBarItem = homeItem
        shortcutVC.tabBarItem = shortcutItem
        settingVC.tabBarItem = settingsItem
        
        //        self.tabBar.backgroundColor = UIColor(hex: 0xe5e5e5)
        //     self.tabBar.barTintColor = AppColor.COLOR_TABBAR_ACTIVE
        //        self.tabBar.isTranslucent = false
        //        self.tabBar.shadowImage = UIImage()
        //        self.tabBar.backgroundImage = UIImage()
        
        
        // Embed VCs into Navigation VCs
        let navHome = UINavigationController(rootViewController: homeVC)
        let navCloud = UINavigationController(rootViewController: shortcutVC)
        let navSettings = UINavigationController(rootViewController: settingVC)
        
        self.viewControllers = [navHome, navCloud, navSettings]
    }
    
    // MARK: UITabBarControllerDelegate method
    internal func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //DDLog("Selected \(viewController.title!)")
    }
    
}
