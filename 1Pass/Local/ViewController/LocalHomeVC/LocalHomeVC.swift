//
//  LocalHomeVC.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

// iPhone
let CellFourFields = "RecordFourFields"
let CellThreeFields = "RecordThreeFields"
let CellTwoFields = "RecordTwoFields"
let CellOneField = "RecordOneField"

// iPad
let CellThreeRowsID = "CellThreeRows"
let CellTwoRowsID = "CellTwoRows"
let CellOneRowID = "CellOneRow"

let headerHeight:CGFloat = 64.0

class LocalHomeVC: BaseVC, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var vSearch:UIView!
    @IBOutlet weak var tbView:UITableView!
    @IBOutlet weak var iconAdd:UIImageView!
    @IBOutlet weak var iconSearch:UIImageView!
    @IBOutlet weak var lbSearch:UILabel!
    @IBOutlet weak var formSearch:UIView!
    @IBOutlet weak var vAdd:UIView!
    @IBOutlet weak var vDefault:UIView!
    @IBOutlet weak var btnCreateNewRecord:UIButton!
    @IBOutlet weak var lbDefault:UILabel!
    @IBOutlet weak var vDefaultText:UIView!
    
    var sectionedData: [String: [Record]] = [:]
    var sortedKeys:[String] = []
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default //.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.vDefault.isHidden = true
        self.adjustGUI()
        self.iconAdd.image = self.iconAdd.image?.tint(AppColor.COLOR_TABBAR_ACTIVE)
        self.showLoading()
        self.addObservers()
        
        
        if Utils.currentSyncMethod() == SyncMethod.vipass {
            self.checkIfSubscriptionExpired()
        }
        
        guard Global.shared.currentUser != nil else {
            return
        }
        
        // Load data
        self.reloadData()
        
        self.hideLoading()
        
        if Utils.currentSyncMethod() == SyncMethod.vipass {
            // Refresh Expiry Date from server
            InappPurchase.refreshServerExpiredAt() 
        }
        
        // Sync in background for upload local changes
        SyncRecords.syncWithServer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // self.tbView.reloadData()
    }
    
    private func checkIfSubscriptionExpired() {
        // Check if Premium expired or not
        let accountType = InappPurchase.getAccountType()
        let expiryDate = InappPurchase.getLocalExpiredAt()
        let now = Date()
        
        if expiryDate > now {
            // Fetch the latest server changes
            SyncRecords.downloadServerChanges()
        } else {
            // Alert user to Go Premium
            var alert = "Your 30-days Free Trial has expired. Go Premium now to continue using advanced features like backup and syncing the data across devices."
            if accountType == AccountType.premium.rawValue {
                alert = "ViPass Premium has expired. Go Premium now to continue using advanced features like backup and syncing the data across devices."
            }
            self.askUserToGoPremium(alert)
        }
    }
    
    private func askUserToGoPremium(_ alert:String) {
        let confirm = ConfirmView.getFromNib(title: alert, confirm: "Go Premium", cancel: "Cancel")
        confirm.confirmAction = {[unowned self] in
            var premiumVC:PremiumVC!
            if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
                // iPhone 5S
                premiumVC = PremiumVC(nibName: "Premium5S", bundle: nil)
            } else if Utils.isPad() {
                // iPad
                premiumVC = PremiumVC(nibName: "PremiumPAD", bundle: nil)
            } else {
                premiumVC = PremiumVC(nibName: "PremiumVC", bundle: nil)
            }
            premiumVC.hidesBottomBarWhenPushed = true
            premiumVC.fromSettings = true
            self.navigationController?.pushViewController(premiumVC, animated: true)
        }
        
        confirm.cancelAction = {} // Do nothing
        confirm.show()
    }
    
    // MARK: Handle Notifications for add, update, delete, change
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(deleteRecord(noti:)), name: .Delete_Record, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateRecord(noti:)), name: .Update_Record, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(addRecord(noti:)), name: .Add_Record, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadRecords(noti:)), name: .Change_Record, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetGUI(noti:)), name: .Change_Password, object: nil)
    }
    
    @objc func addRecord(noti:Notification) {
        self.perform(#selector(reloadData), with: nil, afterDelay: 0.1)
    }
    
    @objc func updateRecord(noti:Notification) {
        self.perform(#selector(reloadData), with: nil, afterDelay: 0.1)
    }
    
    @objc func deleteRecord(noti:Notification) {
        self.perform(#selector(reloadData), with: nil, afterDelay: 0.1)
    }
    
    @objc func reloadRecords(noti:Notification) {
        self.perform(#selector(reloadData), with: nil, afterDelay: 0.1)
    }
    
    @objc func resetGUI(noti:Notification) {
        self.navigationController?.popToRootViewController(animated: false)
        self.reloadData()
    }
    
    
    
    // MARK: IBAction
    @IBAction func ibaSearchTouchDown() {
        self.formSearch.backgroundColor = UIColor(hex: 0xdcdcdc)
    }
    
    @IBAction func ibaSearch() {
        self.formSearch.backgroundColor = UIColor(hex: 0xdcdcdc)
        UIView.animate(withDuration: 0.5, delay: 0.0, options:[], animations:{ [unowned self] in
            self.formSearch.backgroundColor = UIColor(hex: 0xF4F4F4)
            }, completion: { [unowned self] (finished: Bool) in
                self.formSearch.backgroundColor = UIColor(hex: 0xF4F4F4)
        })
        
        let searchVC = LocalSearchVC(nibName: "LocalSearchVC", bundle: nil)
        self.navigationController?.pushViewController(searchVC, animated: false)
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey:nil)
    }
    
    @IBAction func ibaAdd() {
        let newRecordVC = LocalNewRecordVC(nibName: "LocalNewRecordVC", bundle: nil)
        self.navigationController?.pushViewController(newRecordVC, animated: true)
    }
    
    @IBAction func ibaCreateNewRecord(button:UIButton!) {
        self.defaultButtonTouchUp(button)
        let newRecordVC = LocalNewRecordVC(nibName: "LocalNewRecordVC", bundle: nil)
        self.navigationController?.pushViewController(newRecordVC, animated: true)
    }
    
    // MARK: TableViewDataSource _ Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        //return self.sections.count
        return self.sortedKeys.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.sections[section].count
        let key = self.sortedKeys[section]
        return (self.sectionedData[key])!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //let record = self.sections[indexPath.section][indexPath.row]
        let key = self.sortedKeys[indexPath.section]
        let record = (self.sectionedData[key])![indexPath.row]
        let totalField = Utils.getTotalField(record:record)
        
        if Utils.isPad() {
            switch totalField {
            case 1,2,3:
                return 132 // CellOneRow
            case 4,5,6:
                return 191 // CellTwoRows
            default:
                return 250 // CellThreeRows
            }
        } else {
            switch totalField {
            case 1:
                return 112
            case 2:
                return 156
            case 3:
                return 200
            default:
                return 244
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:RecordBaseCell
        //let record = self.sections[indexPath.section][indexPath.row]
        let key = self.sortedKeys[indexPath.section]
        let record = (self.sectionedData[key])![indexPath.row]
        let totalField = Utils.getTotalField(record:record)
        
        if Utils.isPad() {
            switch totalField {
            case 1,2,3:
                cell = tableView.dequeueReusableCell(withIdentifier: CellOneRowID, for: indexPath) as! RecordBaseCell
            case 4,5,6:
                cell = tableView.dequeueReusableCell(withIdentifier: CellTwoRowsID, for: indexPath) as! RecordBaseCell
            default:
                cell = tableView.dequeueReusableCell(withIdentifier: CellThreeRowsID, for: indexPath) as! RecordBaseCell
            }
        } else {
            switch totalField {
            case 1:
                cell = tableView.dequeueReusableCell(withIdentifier: CellOneField, for: indexPath) as! RecordBaseCell
            case 2:
                cell = tableView.dequeueReusableCell(withIdentifier: CellTwoFields, for: indexPath) as! RecordBaseCell
            case 3:
                cell = tableView.dequeueReusableCell(withIdentifier: CellThreeFields, for: indexPath) as! RecordBaseCell
            default:
                cell = tableView.dequeueReusableCell(withIdentifier: CellFourFields, for: indexPath) as! RecordBaseCell
            }
        }
        
        cell.selectionStyle = .none
        cell.configureCellData(record)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editVC = LocalEditRecordVC(nibName: "LocalEditRecordVC", bundle: nil)
        //let rootRecord = self.sections[indexPath.section][indexPath.row]
        let key = self.sortedKeys[indexPath.section]
        let rootRecord = (self.sectionedData[key])![indexPath.row]
        editVC.record = rootRecord.copy() as! Record
        editVC.index = indexPath
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //let record = self.sections[section][0]
        let screenSize = UIScreen.main.bounds.size
        let lbHeader = UILabel(frame: CGRect(x: 16, y: headerHeight-44.0, width: screenSize.width-16, height: 44.0))
        lbHeader.font = UIFont.boldSystemFont(ofSize: 30.0)
        //lbHeader.text = record.title.firstCharacter.capitalized
        lbHeader.text = self.sortedKeys[section].capitalized
        let vHeader = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height:headerHeight))
        vHeader.addSubview(lbHeader)
        
        return vHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        //return ["A", "E", "G", "K", "N", "O", "Q", "Z"]
        return self.sortedKeys
    }
    
    // MARK: Private functions
    private func adjustGUI() {
        // Search
        self.vSearch.layer.cornerRadius = Constant.Button_Corner_Radius
        self.btnCreateNewRecord.layer.cornerRadius = Constant.Button_Corner_Radius
        
        // Table Cell
        if Utils.isPad() {
            self.tbView.register(UINib(nibName: CellThreeRowsID, bundle: nil), forCellReuseIdentifier: CellThreeRowsID)
            self.tbView.register(UINib(nibName: CellTwoRowsID, bundle: nil), forCellReuseIdentifier: CellTwoRowsID)
            self.tbView.register(UINib(nibName: CellOneRowID, bundle: nil), forCellReuseIdentifier: CellOneRowID)
        } else {
            self.tbView.register(UINib(nibName: CellFourFields, bundle: nil), forCellReuseIdentifier: CellFourFields)
            self.tbView.register(UINib(nibName: CellThreeFields, bundle: nil), forCellReuseIdentifier: CellThreeFields)
            self.tbView.register(UINib(nibName: CellTwoFields, bundle: nil), forCellReuseIdentifier: CellTwoFields)
            self.tbView.register(UINib(nibName: CellOneField, bundle: nil), forCellReuseIdentifier: CellOneField)
        }
        
        
        // Adjust GUI on different screen sizes
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            // self.adjustOnPhone6()
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            self.adjustOnPhone6Plus()
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.adjustOnPhone5S()
        } else if UIDevice.current.screenType == .iPhoneX {
            self.adjustOnPhoneX()
        } else if Utils.isPad() {
            self.adjustOnPad()
        }
    }
    
    private func adjustOnPad() {
        
    }
    
    private func adjustOnPhone5S() {
        self.iconSearch.moveLeft(distance: 5)
        self.lbSearch.moveRight(distance: 5)
        self.lbDefault.font = UIFont.systemFont(ofSize: 27)
    }
    
    private func adjustOnPhone6Plus() {
        self.iconSearch.moveRight(distance: 10)
        self.lbDefault.font = UIFont.systemFont(ofSize: 29)
    }
    
    private func adjustOnPhoneX() {
        self.vSearch.increaseHeight(value: 81)
        self.formSearch.moveDown(distance: 24)
        self.vAdd.moveDown(distance: 24)
        self.tbView.moveDown(distance: 24)
        self.tbView.decreaseHeight(value: 24)
        var frame = self.vDefault.frame
        frame.origin.y = self.vSearch.frame.size.height
        self.vDefault.frame = frame
        self.vDefaultText.moveUp(distance: 90)
        self.btnCreateNewRecord.moveUp(distance: 120)
        
    }
    
    @objc func reloadData() {
       // DispatchQueue.main.async { [unowned self] in
            let records = AppDB.getAllRecords()
            if( (records != nil) && !(records?.isEmpty)! ) {
                self.categorizeRecords(data: records!)
            } else {
                self.vDefault.isHidden = false
            }
            
            if self.sortedKeys.count > 0 {
                self.vDefault.isHidden = true
            } else {
                self.vDefault.isHidden = false
            }
            
            self.tbView.reloadData()
       // }
    }
    
    private func categorizeRecords(data:Results<Record>) {
        self.sectionedData = [String: [Record]]()
        self.sortedKeys = [String]()
        data.forEach {
            guard $0.isDeleted == 0 else {
                return
            }
            
            guard let firstLetter = $0.title.firstCharacter,
               ((firstLetter >= "A") && (firstLetter <= "Z")) ||
                    ((firstLetter >= "a") && (firstLetter <= "z")) else {
                        sectionedData["#"] = (sectionedData["#"] ?? []) + [$0]
                        return
            }
            let firstLetterStr = firstLetter.uppercased()
            sectionedData[firstLetterStr] = (sectionedData[firstLetterStr] ?? []) + [$0]
        }
        
        //let sortedData = sectionedData.sorted(by: { $0.key < $1.key })
        self.sortedKeys = sectionedData.keys.sorted()
    }
    
}


