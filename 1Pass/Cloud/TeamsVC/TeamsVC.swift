//
//  TeamsVC.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class TeamsVC: BaseVC {
    @IBOutlet weak var tbView:UITableView!
    @IBOutlet weak var vDefault:UIView!
    @IBOutlet weak var vBar:UIView!
    @IBOutlet weak var vAdd:UIView!
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var btnGetStarted:UIButton!
    @IBOutlet weak var iconAdd:UIImageView!
    @IBOutlet weak var vDefaultForm:UIView!
    
    var vAddTeam:AddTeamView!
    
    //var mainVC:TeamMainVC!
    
    var colors4Cell = [UIColor.white, UIColor(hex:0xf7f7f7), UIColor(hex:0xf4f4f4), UIColor(hex:0xf0f0f0), UIColor(hex:0xE9E9E9)]
    var teams:[Team] = [Team]()
    let kTeamCell = "TeamCell"
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default //.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbView.register(UINib(nibName: kTeamCell, bundle: nil), forCellReuseIdentifier: kTeamCell)
        
        //self.tbView.backgroundColor = UIColor.red

        self.adjustGUI()
        self.loadData()
    }
    
    @IBAction func ibaCreateNewTeam(sender:UIButton!) {
        self.vAddTeam = AddTeamView.getFromNib()
        self.vAddTeam.show()
    }
    
    @IBAction func ibaGetStarted(sender:UIButton!) {
        self.defaultButtonTouchUp(sender)
    }
    
    // MARK: Load Data
    private func loadData() {
        var team = Team()
        team.name = "Family"
        team.adminID = "admin"
        self.teams.append(team)
        
        team = Team()
        team.name = "Startup"
        team.adminID = "xxx"
        self.teams.append(team)
        
        team = Team()
        team.name = "ViPass"
        team.adminID = "avcs"
        self.teams.append(team)
        
        team = Team()
        team.name = "Admin Portal"
        team.adminID = "sssss"
        self.teams.append(team)
        
        team = Team()
        team.name = "Startup"
        team.adminID = "avcs"
        self.teams.append(team)
        
        team = Team()
        team.name = "ViPass"
        team.adminID = "avcs"
        self.teams.append(team)
        
        team = Team()
        team.name = "Admin Portal"
        team.adminID = "avcs"
        self.teams.append(team)
        
        team = Team()
        team.name = "Startup"
        team.adminID = "avcs"
        self.teams.append(team)
        
        team = Team()
        team.name = "ViPass"
        team.adminID = "avcs"
        self.teams.append(team)
        
        team = Team()
        team.name = "Admin Portal"
        team.adminID = "avcs"
        self.teams.append(team)
        
        self.tbView.reloadData()
        self.vDefault.isHidden = true
        self.view.bringSubview(toFront: self.tbView)
    }
    
    // MARK: Adjust GUI
    private func adjustGUI() {
        self.btnGetStarted.layer.cornerRadius = Constant.Button_Corner_Radius
        self.iconAdd.image = self.iconAdd.image?.tint(AppColor.COLOR_TABBAR_ACTIVE)
        
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            // self.adjustOnPhone6()
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            self.adjustOnPhone6Plus()
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.adjustOnPhone5S()
        } else if UIDevice.current.screenType == .iPhoneX {
            self.adjustOnPhoneX()
        } else if UIDevice.current.screenType == .iPhone4_4S {
            //self.adjustOnPhone4S()
        }
    }
    
    private func adjustOnPhoneX() {
        self.vBar.increaseHeight(value: 20)
        self.tbView.moveDown(distance: 20)
        self.tbView.increaseHeight(value: -20)
        self.vDefault.moveDown(distance: 20)
        self.vDefault.increaseHeight(value: -20)
    }
    
    private func adjustOnPhone6Plus() {
        // Do nothing
    }
    
    private func adjustOnPhone5S() {
        self.lbTitle.font = UIFont.boldSystemFont(ofSize: 27)
        self.vBar.moveUp(distance: 20)
        self.vDefaultForm.moveUp(distance: 40)
    }
    
}

extension TeamsVC:UITableViewDelegate, UITableViewDataSource {
    // MARK: TableViewDataSource _ Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.teams.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kTeamCell, for: indexPath) as! TeamCell
        let team = self.teams[indexPath.row]

        //cell.selectionStyle = .none
        cell.configureCellData(team)
       // cell.vContent.backgroundColor = colors4Cell[indexPath.row % colors4Cell.count];
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainVC = TeamMainVC()
        mainVC.team = self.teams[indexPath.row]
        
        UIView.transition(from: (self.tabBarController?.view)!, to: mainVC.view, duration: 1, options: UIViewAnimationOptions.transitionFlipFromRight, completion: {(_) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = mainVC
            appDelegate.window?.makeKeyAndVisible()
        })
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let record = self.sections[section][0]
//
//        let screenSize = UIScreen.main.bounds.size
//        let lbHeader = UILabel(frame: CGRect(x: 16, y: headerHeight-44.0, width: screenSize.width-16, height: 44.0))
//        lbHeader.font = UIFont.boldSystemFont(ofSize: 30.0)
//        lbHeader.text = record.title.firstCharacter.capitalized
//        let vHeader = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height:headerHeight))
//        vHeader.addSubview(lbHeader)
//
//        return vHeader
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return headerHeight
//    }
    
//    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        //return ["A", "E", "G", "K", "N", "O", "Q", "Z"]
//        return self.indexTitles
//    }
}
