//
//  TeamMainVC.swift
//  ViPass
//
//  Created by Ngo Lien on 5/9/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class TeamMainVC:UITabBarController, UITabBarControllerDelegate {
    
    var team:Team!
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.createTabbar()
        self.delegate = self
    }
    
    private func createTabbar() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: AppColor.COLOR_TABBAR, NSAttributedStringKey.font : UIFont(name: "HelveticaNeue", size: 13) as Any], for: .normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: AppColor.COLOR_TABBAR_ACTIVE,NSAttributedStringKey.font : UIFont(name: "HelveticaNeue", size: 13) as Any], for: .selected)
        
        var teamsVC:LocalHomeVC!
        if Utils.isPad() {
            teamsVC = LocalHomeVC(nibName: "LocalHomePAD", bundle: nil)
        } else {
            teamsVC = LocalHomeVC(nibName: "LocalHomeVC", bundle: nil)
        }
        let settingVC = TeamSettingsVC(nibName: "TeamSettingsVC", bundle: nil)
        settingVC.team = self.team
        
        // Config Tabbar Item
        var icon = UIImage(named: "ic-team")
        icon = icon?.tint(AppColor.COLOR_TABBAR)
        var iconSelected = UIImage(named: "ic-team")
        iconSelected = iconSelected?.tint(AppColor.COLOR_TABBAR_ACTIVE)
        let teamsItem = UITabBarItem(title: self.team.name, image: icon, selectedImage: iconSelected)
        teamsItem.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        
        icon = UIImage(named: "ic-settings")
        icon = icon?.tint(AppColor.COLOR_TABBAR)
        iconSelected = UIImage(named: "ic-settings")
        iconSelected = iconSelected?.tint(AppColor.COLOR_TABBAR_ACTIVE)
        let settingsItem = UITabBarItem(title: "Settings", image: icon, selectedImage: iconSelected)
        settingsItem.imageInsets = UIEdgeInsetsMake(0, 0, 1, 0)
        
        teamsVC.tabBarItem = teamsItem
        settingVC.tabBarItem = settingsItem
        
        //        self.tabBar.backgroundColor = UIColor(hex: 0xe5e5e5)
        //     self.tabBar.barTintColor = AppColor.COLOR_TABBAR_ACTIVE
        //        self.tabBar.isTranslucent = false
        //        self.tabBar.shadowImage = UIImage()
        //        self.tabBar.backgroundImage = UIImage()
        
        
        // Embed VCs into Navigation VCs
        let navTeam = UINavigationController(rootViewController: teamsVC)
        let navSettings = UINavigationController(rootViewController: settingVC)
        
        self.viewControllers = [navTeam, navSettings]
    }
    
    // MARK: UITabBarControllerDelegate method
    internal func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //DDLog("Selected \(viewController.title!)")
    }
    
}
