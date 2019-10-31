//
//  TeamSettingsVC.swift
//  ViPass
//
//  Created by Ngo Lien on 5/10/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit

class TeamSettingsVC: BaseVC {
    @IBOutlet weak var tbView:UITableView!
    @IBOutlet weak var vBar:UIView!
    @IBOutlet weak var lbTitle:UILabel!
    
    var vMemberAction:MemberActionView!
    var vAddMember:AddMemberView!
    
    var currentUser = Global.shared.currentUser
    var team:Team!
    var members:[Member] = [Member]()
    let kMemberCell = "MemberCell"
    let kAddMemberCell = "AddMemberCell"
    let kSwitchToCell = "SwitchToCell"
    let kDeleteTeamCell = "DeleteTeamCell"
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default //.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tbView.register(UINib(nibName: kAddMemberCell, bundle: nil), forCellReuseIdentifier: kAddMemberCell)
        self.tbView.register(UINib(nibName: kMemberCell, bundle: nil), forCellReuseIdentifier: kMemberCell)
        self.tbView.register(UINib(nibName: kSwitchToCell, bundle: nil), forCellReuseIdentifier: kSwitchToCell)
        self.tbView.register(UINib(nibName: kDeleteTeamCell, bundle: nil), forCellReuseIdentifier: kDeleteTeamCell)
        
        //self.tbView.backgroundColor = UIColor.red
        
        self.adjustGUI()
        self.loadData()
    }
    
    // MARK: Load Data
    private func loadData() {
        var member = Member()
        member.team = self.team
        member.username = "NgoLien2412"
        member.canEdit = true
        self.members.append(member)

        member = Member()
        member.team = self.team
        member.username = "demen_duky"
        member.canEdit = false
        self.members.append(member)
        
        member = Member()
        member.team = self.team
        member.username = "alexngo2412@gmail.com"
        member.canEdit = true
        self.members.append(member)
        
        member = Member()
        member.team = self.team
        member.username = "canh_hoa_bay"
        member.canEdit = false
        self.members.append(member)
        
        member = Member()
        member.team = self.team
        member.username = "Superman-Xmen"
        member.canEdit = true
        self.members.append(member)
        
        member = Member()
        member.team = self.team
        member.username = "con_duong_thanh_cong"
        member.canEdit = false
        self.members.append(member)
     
        member = Member()
        member.team = self.team
        member.username = "do_what_you_love"
        member.canEdit = true
        self.members.append(member)
        
        self.tbView.reloadData()
    }
    
    // MARK: Adjust GUI
    private func adjustGUI() {
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
    }
    
    private func adjustOnPhone6Plus() {
        // Do nothing
    }
    
    private func adjustOnPhone5S() {
        self.lbTitle.font = UIFont.boldSystemFont(ofSize: 27)
        self.vBar.moveUp(distance: 20)
    }
    
    
    // MARK: Private methods
    @objc private func showCloudMainVC() {
        let mainVC = CloudMainVC()
       
        UIView.transition(from: (self.tabBarController?.view)!, to: mainVC.view, duration: 1, options: UIViewAnimationOptions.transitionFlipFromRight, completion: {(_) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = mainVC
            appDelegate.window?.makeKeyAndVisible()
        })
    }
    
    private func leaveTeam() {
        // Ask user before deleting
        let confirm = ConfirmView.getFromNib(title: "Are you sure you want to leave the team \"\(self.team.name!)\"?", confirm: "Leave", cancel: "Cancel")
        confirm.confirmAction = {
            DispatchQueue.main.async { [unowned self] in
                /*NotificationCenter.default.post(name: .Delete_Record, object: nil, userInfo: [Keys.index: self.index])
                 
                 self.view.endEditing(true)
                 self.navigationController?.popViewController(animated: false)*/
            }
        }
        
        confirm.cancelAction = {} // Do nothing
        confirm.show()
    }
    
    private func deleteTeam() {
        // Ask user before deleting
        let confirm = ConfirmView.getFromNib(title: "Are you sure you want to delete the team \"\(self.team.name!)\"?", confirm: "Delete", cancel: "Cancel")
        confirm.confirmAction = {
            DispatchQueue.main.async { [unowned self] in
                /*NotificationCenter.default.post(name: .Delete_Record, object: nil, userInfo: [Keys.index: self.index])
                 
                 self.view.endEditing(true)
                 self.navigationController?.popViewController(animated: false)*/
            }
        }
        confirm.cancelAction = {} // Do nothing
        confirm.show()
    }
    
}

extension TeamSettingsVC:UITableViewDelegate, UITableViewDataSource {
    // MARK: TableViewDataSource _ Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return self.members.count + 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let cell:UITableViewCell!
        let defaultCellColor = UIColor(hex:0xF4F4F4)
        
        switch section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: kSwitchToCell, for: indexPath) as! SwitchToCell
            cell.backgroundColor = defaultCellColor
        case 1:
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: kAddMemberCell, for: indexPath) as! AddMemberCell
                cell.backgroundColor = UIColor.white
                if self.currentUser?.username != self.team.adminID {
                    // Current User is NOT Admin (NOT created this team)
                    cell.selectionStyle = .none
                    (cell as! AddMemberCell).iconAdd.isHidden = true
                    (cell as! AddMemberCell).lbTitle.text = "List of Members"
                    (cell as! AddMemberCell).lbTitle.textColor = UIColor.black
                    (cell as! AddMemberCell).lbTitle.font = UIFont.boldSystemFont(ofSize: 18)
                }
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: kMemberCell, for: indexPath) as! MemberCell
                cell.backgroundColor = defaultCellColor
                let member = self.members[indexPath.row-1]
                (cell as! MemberCell).lbName.text = member.username
                if self.currentUser?.username != self.team.adminID {
                    // Current User is NOT Admin (NOT created this team)
                    cell.selectionStyle = .none
                }
            }
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: kDeleteTeamCell, for: indexPath) as! DeleteTeamCell
            cell.backgroundColor = defaultCellColor
            if self.currentUser?.username != self.team.adminID {
                // Current User is NOT Admin (NOT created this team)
                (cell as! DeleteTeamCell).lbTitle.text = "Leave Team"
            }
        }
        
        //cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        switch section {
        case 0:
            tableView.deselectRow(at: indexPath, animated: true)
            self.showCloudMainVC()
        case 1:
            if self.currentUser?.username != self.team.adminID {
                // Current User is NOT Admin (NOT created this team)
                tableView.deselectRow(at: indexPath, animated: false)
                return // Do nothing
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            if indexPath.row == 0 {
                // Add Member
                self.vAddMember = AddMemberView.getFromNib()
                self.vAddMember.show()
            } else {
                // For Team Admin does action on Member
                let member = self.members[indexPath.row - 1] // row 0 is Add Member
                self.vMemberAction = MemberActionView.getFromNib()
                self.vMemberAction.settingVC = self
                self.vMemberAction.configureViewData(member)
                self.vMemberAction.show()
            }
        default:
            tableView.deselectRow(at: indexPath, animated: true)
            if self.currentUser?.username != self.team.adminID {
                // Current User is NOT Admin (NOT created this team)
                self.leaveTeam()
            } else {
                self.deleteTeam()
            }
            
        }
        

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
//        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//            return 64.0
//        }
    
    //    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    //        //return ["A", "E", "G", "K", "N", "O", "Q", "Z"]
    //        return self.indexTitles
    //    }
}

