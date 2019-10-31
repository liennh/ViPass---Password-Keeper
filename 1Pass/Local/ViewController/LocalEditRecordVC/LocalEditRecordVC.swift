//
//  LocalEditRecordVC.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class LocalEditRecordVC:BaseVC, UITextFieldDelegate {
    @IBOutlet weak var iconX:UIImageView!
    @IBOutlet weak var tfTitle:UITextField!
    @IBOutlet weak var tbView:UITableView!
    @IBOutlet weak var vSearch:UIView!
    @IBOutlet weak var iconDeleteRecord:UIImageView!
    @IBOutlet weak var btnSave:UIButton!
    //var indexTitles:[String] = [String]()
    var record:Record!
    var index:IndexPath!
    var canSave = true
    var shouldValidate = false
    var fromSearch = false
    var validFields = [Field]()
    var vHeader:EnterTagsView = EnterTagsView.getFromNib()
    var vFooter:AddNewField = AddNewField.getFromNib()
    var backupRecord:Record! // used to removeFromIndexInBackground if title and tag are updated
    var isDirty:Bool = false
    
    private let kEditFieldCell = "EditFieldCell"
    private let kEnterTagsView = "EnterTagsView"
    private let headerHeight:CGFloat = 64.0
    
    private var keyboardHeight:CGFloat = 0.0
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default //.lightContent
    }
    
    func initValidFields(record:Record) {
        self.validFields = [Field]()
        for field in record.fields {
            if field.isDeleted == 0 {
                self.validFields.append(field)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.vHeader.record = self.record
        //self.tfTitle.becomeFirstResponder()
        self.adjustGUI()
        self.hideKeyboardWhenTappedAround()
        self.combineDataToGUI()
        self.backupRecord = self.record.copy() as! Record
        self.initValidFields(record:self.record)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Add New Field. Sent from footer view of tbView
        NotificationCenter.default.addObserver(self, selector: #selector(addNewField(noti:)), name: .Add_New_Field, object: nil)
        // Delete a field. Sent from EditFieldCell
        NotificationCenter.default.addObserver(self, selector: #selector(deleteField(noti:)), name: .Delete_Field, object: nil)
    }
    
    @IBAction func ibaSave() {
        self.view.endEditing(true)
        //self.defaultButtonTouchUp(sender)
        self.canSave = true // Start with true. If any field is invalid, make false.
        self.shouldValidate = true
        guard self.validateInputForm() else {
            return
        }
        
        // Remove empty field
        let recordCopy:Record = self.removeEmptyFields(record: self.record)
        self.initValidFields(record: recordCopy)
       // self.tbView.reloadData()
        guard self.validFields.count > 0 else {
            let alert = AlertView.getFromNib(title: "Record must have at least 1 field.")
            alert.show()
            return
        }
        
        self.checkIfAnyChangesMade(updatedRecord:recordCopy)
        if recordCopy.isDirty {
            // Add record to shortcut
            Utils.addRecordToShortcut(recordID: self.record.id)
            
            // Save to local database
            self.doSave(dirtyRecord: recordCopy)
        }
    }
    
    private func doSave(dirtyRecord:Record) {
        let shouldRemoveIndex = (self.backupRecord.title != dirtyRecord.title) ||
            (self.backupRecord.tags != dirtyRecord.tags)
        let recordCopy2 = dirtyRecord.copy() as! Record
        let recordCopy3 = self.backupRecord.copy() as! Record
        let recordCopy4 = dirtyRecord.copy() as! Record
        AppDB.updateInBackground(record: recordCopy2) {[unowned self](status, error) in
            guard error == nil else {
                Utils.showError(title: "Error Occurred", message: error)
                return
            }
            if shouldRemoveIndex {
                RecordIndex.removeFromIndexInBackground(record: recordCopy3) { (status, error) in
                    if error != nil {
                        Utils.showError(title: "Error Occurred", message: error)
                    }
                    RecordIndex.addToIndexInBackground(record: recordCopy4) { (status, error) in
                        if error != nil {
                            Utils.showError(title: "Error Occurred", message: error)
                        }
                    }
                }
            }
            
            // Save to server here or activating sync with server
            SyncRecords.syncWithServer()
            
            if self.fromSearch {
                NotificationCenter.default.post(name: .Change_Record, object: nil, userInfo: nil)
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                NotificationCenter.default.post(name: .Update_Record, object: nil, userInfo: nil)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func removeEmptyFields(record:Record!) -> Record {
        let recordCopy = record.copy() as! Record
        let listFields = List<Field>()
        for field in recordCopy.fields {
            if field.isDeleted != 0 {
                listFields.append(field)
                continue
            }
            // get valid data fields. Including fields synced and not synced
            if !field.name.isEmpty && !field.value.isEmpty {
                listFields.append(field)
            }
            
            if field.isSynced && field.name.isEmpty && field.value.isEmpty {
                self.resetField(field, record: self.backupRecord)
                field.isDeleted = -1 // deleted locally
                listFields.append(field)
            }
            
        }
        recordCopy.fields.removeAll()
        recordCopy.fields.append(objectsIn: listFields)
        return recordCopy
    }
    
    private func markDirty(record:Record) {
        self.isDirty = true
        record.isDirty = true
        record.updatedAt = Date()
    }
    
    private func checkIf(field:Field, appearsIn list:List<Field>) -> (Bool, Field?) {
        for item in list {
            if field.id == item.id {
                return (true, item)
            }
        }// for
        
        return (false, nil)
    }
    
    private func checkIfAnyChangesMade(updatedRecord:Record) {
        // check title
        if self.backupRecord.title != updatedRecord.title {
            self.markDirty(record:updatedRecord)
            updatedRecord.titleUpdatedAt = updatedRecord.updatedAt
        }
        // check tags
        if self.backupRecord.tags != updatedRecord.tags {
            self.markDirty(record:updatedRecord)
            updatedRecord.tagsUpdatedAt = updatedRecord.updatedAt
        }
        
        // check detail of fields
        for field in updatedRecord.fields {
            if field.isDeleted == 0 {
                let (found, matchField) = self.checkIf(field:field, appearsIn:self.backupRecord.fields)
                if !found {
                    // it's a new field
                    self.markDirty(record:updatedRecord)
                    field.nameUpdatedAt = updatedRecord.updatedAt
                    field.valueUpdatedAt = updatedRecord.updatedAt
                } else {
                    // check name changes
                    if field.name != matchField?.name {
                        self.markDirty(record:updatedRecord)
                        field.nameUpdatedAt = updatedRecord.updatedAt
                    }
                    // check value changes
                    if field.value != matchField?.value {
                        self.markDirty(record:updatedRecord)
                        field.valueUpdatedAt = updatedRecord.updatedAt
                    }
                }
            } else if field.isDeleted == -1 {// deleted locally
                self.markDirty(record:updatedRecord)
            }

        }// for
        
    }
    
    @IBAction func ibaClose() {
        self.view.endEditing(true)
        // Check if user made any changes
        let recordCopy = self.record.copy() as! Record
        self.checkIfAnyChangesMade(updatedRecord:recordCopy)
        if self.isDirty {
            // Show confirm Save or Close
            let confirm = ConfirmView.getFromNib(title: "Do you want to save changes?", confirm: "Save", cancel: "Cancel")
            
            confirm.confirmAction = {[unowned self] in
                self.ibaSave()
            }
            
            confirm.cancelAction = { [unowned self] in
                self.navigationController?.popViewController(animated: true)
            }
            confirm.show()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func ibaDeleteRecord() {
        self.view.endEditing(true)
        // Ask user before deleting
        let confirm = ConfirmView.getFromNib(title: "Are you sure you want to delete this record?", confirm: "Delete", cancel: "Cancel")
        confirm.confirmAction = {
            // Remove record from shortcut
            Utils.removeRecordFromShortcut(recordID: self.record.id)
            
            if self.record.isSynced {
                self.deleteSyncedRecord()
            } else {
                self.deleteNotSyncedRecord()
            }
        }
        
        confirm.cancelAction = {} // Do nothing
        confirm.show()
    }
    
    private func deleteSyncedRecord() {
        let copy = self.backupRecord.copy() as! Record
        copy.isDeleted = -1 // deleted locally
        copy.isDirty = true
        copy.updatedAt = Date()
        AppDB.updateInBackground(record: copy) {[unowned self](status, error) in
            guard error == nil else {
                Utils.showError(title: "Error Occurred", message: error)
                return
            }
            RecordIndex.removeFromIndexInBackground(record: self.backupRecord) { (status, error) in
                if error != nil {
                    Utils.showError(title: "Error Occurred", message: error)
                }
                if self.fromSearch {
                    NotificationCenter.default.post(name: .Change_Record, object: nil, userInfo: nil)
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    NotificationCenter.default.post(name: .Delete_Record, object: nil, userInfo: nil)
                    self.navigationController?.popViewController(animated: false)
                }
            }
            
            // Activate sync with server
            SyncRecords.syncWithServer()
        }
    }
    
    private func deleteNotSyncedRecord() {
        AppDB.deleteInBackground(record: self.record) { [unowned self](status, error) in
            guard error == nil else {
                Utils.showError(title: "Error Occurred", message: error)
                return
            }
            RecordIndex.removeFromIndexInBackground(record: self.backupRecord) { (status, error) in
                if error != nil {
                    Utils.showError(title: "Error Occurred", message: error)
                }
                if self.fromSearch {
                    NotificationCenter.default.post(name: .Change_Record, object: nil, userInfo: nil)
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    NotificationCenter.default.post(name: .Delete_Record, object: nil, userInfo: nil)
                    self.navigationController?.popViewController(animated: false)
                }
            }
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        //self.loadData()
        return false
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        self.record.title = textField.text
        self.removeRed(textField: textField)
    }
    
    // MARK: Private methods
    private func adjustGUI() {
        self.iconX.image = self.iconX.image?.tint(UIColor.black)
        self.iconDeleteRecord.image = self.iconDeleteRecord.image?.tint(UIColor.black)
        
        // Register Nibs Cell
        self.tbView.register(UINib(nibName: kEditFieldCell, bundle: nil), forCellReuseIdentifier: kEditFieldCell)
        
        
        // Adjust GUI on different screen sizes
        if UIDevice.current.screenType == .iPhones_6_6s_7_8 {
            // self.adjustOnPhone6()
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            //self.adjustOnPhone6Plus()
        } else if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            // self.adjustOnPhone5S()
        } else if UIDevice.current.screenType == .iPhoneX {
            self.adjustOnPhoneX()
        } else if Utils.isPad() {
            self.adjustOnPad()
        }
    }
    
    private func adjustOnPad() {
        var frame = self.tbView.frame
        frame.size.width = 600
        frame.origin.x = (self.view.frame.size.width - frame.size.width)/2.0
        self.tbView.frame = frame
        self.tfTitle.font = UIFont.boldSystemFont(ofSize: 28)
        frame = self.tfTitle.frame
        frame.origin.x = self.tbView.frame.origin.x
        frame.size.width = self.tbView.frame.size.width
        self.tfTitle.frame = frame
        //self.view.backgroundColor = UIColor(hexString: "F7F7F7")
        self.btnSave.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
    }
    
    private func adjustOnPhoneX() {
        self.vSearch.increaseHeight(value: 15)
        // self.formSearch.moveDown(distance: 24)
        //self.vAdd.moveDown(distance: 24)
        self.tbView.moveDown(distance: 15)
        self.tbView.decreaseHeight(value: 15)
    }
    
    func combineDataToGUI() {
        self.tfTitle.text = self.record.title
    }
    
    // MARK: Validate Input Form
    
    private func makeRed(textField:UITextField) {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.red.cgColor
    }
    
    private func removeRed(textField:UITextField) {
        textField.layer.borderWidth = 0
        // textField.layer.borderColor = UIColor.red.cgColor
    }
    
    private func validateInputForm() -> Bool {
        self.tfTitle.text = self.tfTitle.text?.trim()
        self.record.title = self.tfTitle.text
        
        if self.record.title.isEmpty {
            self.makeRed(textField: self.tfTitle)
            self.canSave = false
        } else if self.record.title.count > 64 {
            self.makeRed(textField: self.tfTitle)
            let alert = AlertView.getFromNib(title: "Maximum length for record title is 64 characters.")
            alert.show()
            return false
        }
        
        // Validate Cells
        for i in 0..<self.validFields.count {
            let indexPath = IndexPath(row: i, section: 0)
            let field = self.validFields[i]
            
            // Fix bug blank field with spaces only
            let name = Utils.getString(field.name).trim()
            let value = Utils.getString(field.value).trim()
            if (name.isEmpty && !value.isEmpty) ||
                (!name.isEmpty &&  value.isEmpty) {
                self.canSave = false
            }
            self.tbView.reloadRows(at: [indexPath], with: .none)
        }
        
        if self.canSave  {
            if (self.validFields.count <= 0) || self.checkIfRecordHasNoFields()  {
                // A record must have at least 1 field
                let alert = AlertView.getFromNib(title: "Record must have at least 1 field.")
                alert.show()
                self.canSave = false
            }
        } else {
            let alert = AlertView.getFromNib(title: "Pleased complete fields.\n\n***Maximum length for field name is 64 characters.\n\n***Maximum length for field value is 255 characters.")
            alert.show()
        }
        
        return self.canSave
    }
    
    private func validate(cell:EditFieldCell) {
        cell.field.name = cell.field.name?.trim() ?? ""
        cell.tfName.text = cell.field.name
        
        cell.field.value = cell.field.value?.trim() ?? ""
        cell.tfValue.text = cell.field.value
        
        if( (!cell.field.name.isEmpty && cell.field.value.isEmpty ) ||
            ( cell.field.name.isEmpty && !cell.field.value.isEmpty )
            ) {
            if cell.field.name.isEmpty {
                cell.tfName.text = nil
                self.makeRed(textField: cell.tfName)
                self.canSave = false
                return
            }
            if cell.field.value.isEmpty {
                cell.tfValue.text = nil
                self.makeRed(textField: cell.tfValue)
                self.canSave = false
                return
            }
        } else if cell.field.name.isEmpty && cell.field.value.isEmpty {
            // Both name and value are empty
            cell.tfName.text = nil
            cell.tfValue.text = nil
            self.removeRed(textField: cell.tfName)
            self.removeRed(textField: cell.tfValue)
        } else {
            // Both name and value are NOT empty
            self.removeRed(textField: cell.tfName)
            self.removeRed(textField: cell.tfValue)
            
            // check max length
            if cell.field.name.count > 64 {
                self.makeRed(textField: cell.tfName)
                self.canSave = false
                return
            }
            
            if cell.field.value.count > 255 {
                self.makeRed(textField: cell.tfValue)
                self.canSave = false
                return
            }
        }
    }
    
    private func checkIfRecordHasNoFields() -> Bool {
        for i in 0..<self.validFields.count {
            let field = self.validFields[i]
            let name = field.name ?? ""
            let value = field.value ?? ""
            if !name.isEmpty && !value.isEmpty {
                return false
            }
        }
        
        return true
    }
}

extension LocalEditRecordVC:UITableViewDelegate, UITableViewDataSource {
    // MARK: TableViewDataSource _ Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.validFields.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kEditFieldCell, for: indexPath)
        cell.selectionStyle = .none
        
        let field = self.validFields[indexPath.row]
        (cell as! EditFieldCell).configureCellData(field)
        (cell as! EditFieldCell).index = indexPath
        (cell as! EditFieldCell).record = self.record
        
        if self.shouldValidate {
            self.validate(cell: cell as! EditFieldCell)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.vHeader.tfTags.text = self.record.tags
        return self.vHeader
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if Utils.isPad() {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44))
            var frame = self.vFooter.frame
            frame.size.width = 375
            frame.origin.x = (view.frame.size.width - frame.size.width)/2.0
            self.vFooter.frame = frame
            view.addSubview(self.vFooter)
            return view
        } else {
            return self.vFooter
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 134
    }
    
    /*func sectionIndexTitles(for tableView: UITableView) -> [String]? {
     //return ["A", "E", "G", "K", "N", "O", "Q", "Z"]
     return self.indexTitles
     }*/
    
    private func resetField(_ field:Field, record:Record) {
        for item in record.fields {
            if item.id == field.id {
                field.name = item.name
                field.value = item.value
                break
            }
        }
    }
    
    @objc func deleteField(noti: NSNotification) {
        let index = noti.userInfo![Keys.index]
        let indexPath = index as! IndexPath
        let field = self.validFields[indexPath.row]
        if field.isSynced {
            // reset the original values before deleting.
            self.resetField(field, record: self.backupRecord)
            field.isDeleted = -1 // deleted locally
            self.validFields.remove(at: indexPath.row)
        } else {
            var index = -1
            for i in 0..<self.record.fields.count {
                if (self.record.fields[i]).id == field.id {
                    index = i
                    break
                }
            }
            if index != -1 {
                self.record.fields.remove(at: index)
            }
            self.validFields.remove(at: indexPath.row)
        }
        self.markDirty(record: self.record)
        self.tbView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        self.tbView.reloadData()
    }
    
    @objc func addNewField(noti: NSNotification) {
        guard self.validFields.count <= 19 else { // Allow max is 20 field on a record
            self.view.endEditing(true)
            let alert = AlertView.getFromNib(title: "It seems you are adding too many fields.\nAre you doing tests?\n\nIf not, please let us know the reason or context you need many fields for a record. We will base on that to improve our app.\n\nThank you!")
            alert.show()
            return
        }
        
        let empty = Field()
        self.record.fields.append(empty)
        self.validFields.append(empty)
        //self.tbView.reloadData()
        
        // Append row at the bottom of tbView
        self.tbView.beginUpdates()
        let indexPath:IndexPath = IndexPath(row:(self.validFields.count - 1), section:0)
        self.tbView.insertRows(at: [indexPath], with: .bottom)
        self.tbView.endUpdates()
        self.tbView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
        if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            //self.tbView.setContentOffset(CGPoint(x: 0, y: 170), animated: true)
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            // Do nothing
        } else if UIDevice.current.screenType == .iPhoneX {
            // Do nothing
        } else {
            // self.tbView.setContentOffset(CGPoint(x: 0, y: 20), animated: true)
        }
    }
    
    @objc func keyboardWillHide(noti: NSNotification) {
        let screenSize = UIScreen.main.bounds.size
        var frame = self.tbView.frame
        frame.size.height = screenSize.height - frame.origin.y
        self.tbView.frame = frame
        if UIDevice.current.screenType == .iPhones_5_5s_5c_SE {
            //self.tbView.setContentOffset(CGPoint(x: 0, y: -20), animated: true)
        } else if UIDevice.current.screenType == .iPhones_6Plus_6sPlus_7Plus_8Plus {
            // Do nothing
        } else if UIDevice.current.screenType == .iPhoneX {
            // Do nothing
        } else {
            self.tbView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
        
    }
}
