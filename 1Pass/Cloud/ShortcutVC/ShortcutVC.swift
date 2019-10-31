//
//  ShortcutVC.swift
//  1Pass
//
//  Created by Ngo Lien on 8/18/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import UIKit

class ShortcutVC: BaseVC {
    @IBOutlet weak var lbTitle:UILabel!
    @IBOutlet weak var lbDefault:UILabel!
    @IBOutlet weak var vDefault:UIView!
    @IBOutlet weak var tbView:UITableView!
    
    var recordsList:[Record] = [Record]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default //.lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.adjustGUI()
        self.registerNibs()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadShortcutData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private methods
    private func registerNibs() {
        // Register Nibs Cell
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
    }
    
    private func loadShortcutData() {
        let recordIDs:[String] = Utils.getRecordsFromShortcut()
        if recordIDs.count > 0 {
            if let records = AppDB.getRecords(ids: recordIDs)   {
                var results = [Record]()
                for record in records.reversed() {
                    let copy = record.copy() as! Record
                    results.append(copy)
                }
                self.recordsList = results
            }
        } else {
            self.recordsList = [Record]()
        }

        if self.recordsList.isEmpty {
            self.tbView.isHidden = true
            self.vDefault.isHidden = false
        } else {
            self.tbView.isHidden = false
            self.vDefault.isHidden = true
        }
        self.tbView.reloadData()
        self.tbView.setContentOffset(.zero, animated: false)
    }
    
    private func adjustGUI() {
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            // self.adjustOnPhone7()
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            // self.adjustOnPhone7Plus()
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            self.adjustOnPhone5S()
        } else if UIDevice.current.screenType == .iPhoneX {
            self.adjustOnPhoneX()
        } else if Utils.isPad() {
           // self.adjustOnPad()
        }
    }

    func adjustOnPhone5S() {
        self.lbTitle.font = UIFont.boldSystemFont(ofSize: 27)
        self.lbDefault.font = UIFont.systemFont(ofSize: 18)
        self.lbDefault.moveUp(distance: 50)
    }
    
    func adjustOnPhoneX() {
        var frame = self.vDefault.frame
        frame.origin.y += 30
        frame.size.height -= 30
        self.vDefault.frame = frame
        self.tbView.frame = frame
        self.lbDefault.moveDown(distance: 30)
        self.lbTitle.moveDown(distance: 30)
    }
}

extension ShortcutVC:UITableViewDelegate, UITableViewDataSource {
    // MARK: TableViewDataSource _ Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordsList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let record = self.recordsList[indexPath.row]
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
        let record = self.recordsList[indexPath.row]
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
        self.view.endEditing(true)
        let editVC = LocalEditRecordVC(nibName: "LocalEditRecordVC", bundle: nil)
        editVC.fromSearch = true
        let rootRecord = self.recordsList[indexPath.row]
        editVC.record = rootRecord.copy() as! Record
        editVC.index = indexPath
        self.navigationController?.pushViewController(editVC, animated: true)
    }
}
