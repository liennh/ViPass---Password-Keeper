//
//  LocalSearchVC.swift
//  ViPass
//
//  Created by Ngo Lien on 5/1/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class LocalSearchVC:BaseVC, UITextFieldDelegate {
    @IBOutlet weak var iconX:UIImageView!
    @IBOutlet weak var tfSearch:UITextField!
    @IBOutlet weak var tbView:UITableView!
    @IBOutlet weak var vSearch:UIView!
    var records = [Record]()
    var timer: Timer? // used for autocomplete
    private var keyboardHeight:CGFloat = 0.0
    
    deinit {
        if self.timer != nil {
            self.timer?.invalidate()  // Cancel any previous timer
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default //.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.tfSearch.becomeFirstResponder()
        self.tbView.isHidden = true
        self.adjustGUI()
    }

    @IBAction func ibaClear() {
        self.tfSearch.text = nil
        self.records = [Record]()
        self.tbView.reloadData()
        self.tbView.isHidden = true
        self.tfSearch.becomeFirstResponder()
    }
    
    @IBAction func ibaClose() {
        self.navigationController?.popViewController(animated: false)
    }
    
    func search() {
        if self.timer != nil {
            self.timer?.invalidate()  // Cancel any previous timer
        }
        self.performSearch()
    }
    
    @objc func performSearch() {
        let words = RecordIndex.searchableWords(string: self.tfSearch.text!)
        RecordIndex.recordsFor(searchable: words) { [unowned self](records, error) in
            if records != nil {
                self.records = records!
            } else {
                self.records = [Record]()
            }
            self.tbView.reloadData()
            self.tbView.isHidden = false
        }
    }
    
    // MARK: UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if self.timer != nil {
            self.timer?.invalidate()  // Cancel any previous timer
        }
        
        // If the textField contains at least 3 characters…
        let currentText = textField.text ?? ""
        if (currentText as NSString).replacingCharacters(in: range, with: string).count > 0 {
            // …schedule a timer for 0.5 seconds
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(performSearch), userInfo: nil, repeats: false)
        } else {
            //self.records = [Record]()
           // self.tbView.reloadData()
            self.tbView.isHidden = true
        }
        
        return true
    }

    // called when clear button pressed. return NO to ignore (no notifications)
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.ibaClear()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        timer?.invalidate()  // Cancel any previous timer
        self.search()
        return false
    }
    
    // MARK: Private methods
    private func adjustGUI() {
        self.iconX.image = self.iconX.image?.tint(AppColor.COLOR_TABBAR_ACTIVE)
        
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
        
        // Adjust GUI on different screen sizes
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            // self.adjustOnPhone6()
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            //self.adjustOnPhone6Plus()
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
           // self.adjustOnPhone5S()
        } else if UIDevice.current.screenType == .iPhoneX {
            self.adjustOnPhoneX()
        } else if UIDevice.current.screenType == .iPhone4_4S {
            //self.adjustOnPhone4S()
        }
    }
    
    private func adjustOnPhoneX() {
        self.vSearch.increaseHeight(value: 15)
       // self.formSearch.moveDown(distance: 24)
        //self.vAdd.moveDown(distance: 24)
        self.tbView.moveDown(distance: 15)
        self.tbView.decreaseHeight(value: 15)
    }
    
    // MARK: Keyboard
    @objc func keyboardWillShow(noti: NSNotification) {
        let userInfo:NSDictionary = noti.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        self.keyboardHeight = keyboardRectangle.height
        // do whatever you want with this keyboard height
        let screenSize = UIScreen.main.bounds.size
        var frame = self.tbView.frame
        frame.size.height = screenSize.height - self.keyboardHeight - frame.origin.y
        self.tbView.frame = frame
    }
    
    @objc func keyboardWillHide(noti: NSNotification) {
        let screenSize = UIScreen.main.bounds.size
        var frame = self.tbView.frame
        frame.size.height = screenSize.height - frame.origin.y
        self.tbView.frame = frame
    }
}

extension LocalSearchVC:UITableViewDelegate, UITableViewDataSource {
    // MARK: TableViewDataSource _ Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.records.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let record = self.records[indexPath.row]
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
        let record = self.records[indexPath.row]
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
        let rootRecord = self.records[indexPath.row]
        editVC.record = rootRecord.copy() as! Record
        editVC.index = indexPath
        self.navigationController?.pushViewController(editVC, animated: true)
    }
}
