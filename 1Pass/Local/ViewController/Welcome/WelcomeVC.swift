//
//  WelcomeVC.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class WelcomeVC:BaseVC, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var scrollView2:UIScrollView!
    @IBOutlet weak var iconArrowDown:UIImageView!
    @IBOutlet weak var logo:UIImageView!
    @IBOutlet weak var vHorizontalContent:UIView!
    @IBOutlet weak var vMainLogo:UIView!
    @IBOutlet weak var lbMainTitle:UILabel!
    @IBOutlet weak var btnLearnMore:UIButton!
    @IBOutlet weak var btnGetStarted:UIButton!
    @IBOutlet weak var lbSetup:UILabel!
    @IBOutlet weak var vLearnMore:UIView!
    @IBOutlet weak var page1:UIView!
    @IBOutlet weak var page2:UIView!
    @IBOutlet weak var page3:UIView!
    @IBOutlet weak var page4:UIView!
    @IBOutlet weak var lbInfoPage1:UILabel!
    @IBOutlet weak var vDots1:UIPageControl!
    @IBOutlet weak var vDots2:UIPageControl!
    @IBOutlet weak var vDots3:UIPageControl!
    @IBOutlet weak var vDots4:UIPageControl!
    @IBOutlet weak var vStatusBar:UIView!
    
    @IBOutlet weak var lbUse1Password:UILabel!
    @IBOutlet weak var lbInfo:UILabel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default //.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .default
        self.scrollView.delegate = self
        self.iconArrowDown.image = self.iconArrowDown.image?.tint(AppColor.COLOR_NAVI)
        self.adjustGUI()
        
    }
    
    // MARK: Private func
    func adjustGUI() {
        let screenSize = UIScreen.main.bounds.size
        var frame = self.scrollView2.frame
        frame.origin.y = self.scrollView.frame.size.height
        self.scrollView2.frame = frame
        
        frame = self.vHorizontalContent.frame
        frame.size.width = screenSize.width*4
        frame.size.height = self.scrollView2.frame.size.height
        self.vHorizontalContent.frame = frame
        
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: (screenSize.height - 44)*2)
        
        self.scrollView.contentOffset = CGPoint(x: 0.0, y: 20.0)
        
        self.scrollView2.contentSize = CGSize(width: screenSize.width*4, height: self.scrollView2.frame.size.height)
        
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            //self.adjustOnPhone6()
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            self.adjustOnPhone6Plus()
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.adjustOnPhone5S()
        } else if UIDevice.current.screenType == .iPhoneX {
            self.adjustOnPhoneX()
        } else if Utils.isPad() { // iPad
            self.adjustOnPad()
        }
    }
    
    private func adjustOnPad() {
        // do nothing
    }
    
    private func adjustOnPhone6Plus() {
        self.lbMainTitle.font = UIFont.boldSystemFont(ofSize: 30)
        self.lbInfo.font = UIFont.systemFont(ofSize: 23)
        self.lbMainTitle.moveDown(distance: 30)
        
        let screenSize = UIScreen.main.bounds.size
        var frame = self.lbInfo.frame
        frame.size.width += 30
        frame.size.height += 30
        frame.origin.y += 30
        frame.origin.x = (screenSize.width - frame.size.width)/2.0
        self.lbInfo.frame = frame
        
        frame = self.logo.frame
        frame.size.width += 30
        frame.size.height += 30
        frame.origin.x = (screenSize.width - frame.size.width)/2.0
        self.logo.frame = frame
    }
    
    private func adjustOnPhoneX() {
        self.vStatusBar.increaseHeight(value: 24)
        var frame = self.btnGetStarted.frame
        frame.size.height *= 2.0
        frame.origin.y -= 44.0
        self.btnGetStarted.frame = frame
        self.btnGetStarted.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 30, 0)
        self.btnGetStarted.contentHorizontalAlignment = .center
        
        self.vMainLogo.moveDown(distance: 30)
        
        self.vLearnMore.moveUp(distance: 74)
        self.lbSetup.moveUp(distance: 64)
        
        // Page 1
        var title = self.page1.viewWithTag(111)
        title?.moveDown(distance: 64)
        
        var icon = self.page1.viewWithTag(222)
        icon?.moveDown(distance: 64)
        
        var info = self.page1.viewWithTag(333)
        info?.moveDown(distance: 64)
        
        self.vDots1.moveUp(distance: 70)
        
        // Page 2
        title = self.page2.viewWithTag(111)
        title?.moveDown(distance: 64)
        
        icon = self.page2.viewWithTag(222)
        icon?.moveDown(distance: 64)
        
        info = self.page2.viewWithTag(333)
        info?.moveDown(distance: 64)
        
        self.vDots2.moveUp(distance: 70)
        
        // Page 3
        title = self.page3.viewWithTag(111)
        title?.moveDown(distance: 64)
        
        icon = self.page3.viewWithTag(222)
        icon?.moveDown(distance: 64)
        
        info = self.page3.viewWithTag(333)
        info?.moveDown(distance: 64)
        
        self.vDots3.moveUp(distance: 70)
        
        // Page 4
        title = self.page4.viewWithTag(111)
        title?.moveDown(distance: 64)
        
        icon = self.page4.viewWithTag(222)
        icon?.moveDown(distance: 64)
        
        info = self.page4.viewWithTag(333)
        info?.moveDown(distance: 64)
        
        self.vDots4.moveUp(distance: 70)
    }
    
    private func adjustOnPhone5S() {
        let screenSize = UIScreen.main.bounds.size
        self.lbMainTitle.font = UIFont.boldSystemFont(ofSize: 23)
        self.btnLearnMore.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        self.lbSetup.font = UIFont.systemFont(ofSize: 15.0)
        self.iconArrowDown?.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        var frame = self.iconArrowDown.frame
        frame.origin.y -= 5
        self.iconArrowDown.frame = frame
        
        frame = self.lbSetup.frame
        frame.origin.y += 5
        self.lbSetup.frame = frame
        frame = self.vLearnMore.frame
        frame.origin.y += 40.0
        self.vLearnMore.frame = frame
        self.lbInfo.font = UIFont.systemFont(ofSize: 18)
        self.lbInfo.moveUp(distance: 10)
        frame = self.lbMainTitle.frame
        frame.size.width += 50
        frame.origin.y -= 10
        frame.origin.x = (screenSize.width - frame.size.width)/2.0
        self.lbMainTitle.frame = frame
        self.vMainLogo.moveUp(distance: 15)
        
        // Page 1
        var title = self.page1.viewWithTag(111)
        (title as! UILabel).font = UIFont.boldSystemFont(ofSize: 25)
        title?.moveUp(distance: 30)
        
        var icon = self.page1.viewWithTag(222)
        icon?.moveUp(distance: 20)
        
        var info = self.page1.viewWithTag(333)
        info?.moveUp(distance: 45)
        
        self.vDots1.moveDown(distance: 44)
        
        // Page 2
        title = self.page2.viewWithTag(111)
        (title as! UILabel).font = UIFont.boldSystemFont(ofSize: 25)
        title?.moveUp(distance: 30)
        
        icon = self.page2.viewWithTag(222)
        icon?.moveUp(distance: 20)
        
        info = self.page2.viewWithTag(333)
        info?.moveUp(distance: 45)
        
        self.vDots2.moveDown(distance: 44)
        self.lbUse1Password.text = "1 password to unlock all secrets"
        
        // Page 3
        title = self.page3.viewWithTag(111)
        (title as! UILabel).font = UIFont.boldSystemFont(ofSize: 25)
        title?.moveUp(distance: 30)
        
        icon = self.page3.viewWithTag(222)
        icon?.moveUp(distance: 20)
        
        info = self.page3.viewWithTag(333)
        info?.moveUp(distance: 45)
        
        self.vDots3.moveDown(distance: 44)
        
        // Page 4
        title = self.page4.viewWithTag(111)
        (title as! UILabel).font = UIFont.boldSystemFont(ofSize: 25)
        title?.moveUp(distance: 30)
        
        icon = self.page4.viewWithTag(222)
        icon?.moveUp(distance: 20)
        
        info = self.page4.viewWithTag(333)
        info?.moveUp(distance: 45)
        
        self.vDots4.moveDown(distance: 44)
    }
    
    // MARK: IBAction
    @IBAction func ibaLearnMore(sender:UIButton) {
        self.scrollView.scrollToVerticalPage(page: 1, animated: true)
        Timer.scheduledTimer(timeInterval: 0.3,
                             target: self,
                             selector: #selector(changeStatusBarWhiteContent),
                             userInfo: nil,
                             repeats: false)
        
    }
    
    @IBAction func ibaGetStarted(sender:UIButton) {
        var vc:GetStartedVC?
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            vc = GetStartedVC(nibName: "GetStartedVC", bundle: nil)
        case .pad:
            vc = GetStartedVC(nibName: "GetStartedPAD", bundle: nil)
        default: break;
        }
        let nav = UINavigationController(rootViewController: vc!)
        nav.isNavigationBarHidden = true
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc func changeStatusBarWhiteContent() {
        UIApplication.shared.statusBarStyle = .lightContent
        self.scrollView.isScrollEnabled = false
    }
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView)  {
        //self.vStatusBar.backgroundColor = UIColor.clear
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            let currentPage = scrollView.currentPage
            // Do something with your page update
            DDLog("scrollViewDidEndDragging: \(currentPage)")
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = scrollView.currentPage
        // Do something with your page update
        DDLog("scrollViewDidEndDecelerating: \(currentPage)")
        
        if(currentPage == 1) {
            UIApplication.shared.statusBarStyle = .lightContent
            self.scrollView.isScrollEnabled = false
            self.vStatusBar.backgroundColor = UIColor.clear
        } else {
            UIApplication.shared.statusBarStyle = .default
            self.scrollView.isScrollEnabled = true
            self.vStatusBar.backgroundColor = UIColor.white
        }
        
    }
    
}

extension UIScrollView {
    func scrollToHorizontalPage(page: Int, animated: Bool) {
        var frame: CGRect = self.frame
        frame.origin.x = frame.size.width * CGFloat(page);
        frame.origin.y = 0;
        self.scrollRectToVisible(frame, animated: animated)
    }
    
    func scrollToVerticalPage(page: Int, animated: Bool) {
        var frame: CGRect = self.frame
        frame.origin.y = frame.size.height * CGFloat(page);
        frame.origin.x = 0;
        self.scrollRectToVisible(frame, animated: animated)
    }
    
    var currentPage: Int {
        return Int((self.contentOffset.y + (0.5*self.frame.size.height))/self.frame.height)
    }
}
