//
//  LocalNewRecordVC.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Crashlytics

class LocalNewRecordVC:BaseVC, UITextFieldDelegate {
    @IBOutlet weak var iconX:UIImageView!
    @IBOutlet weak var tfTitle:UITextField!
    @IBOutlet weak var tbView:UITableView!
    @IBOutlet weak var navBar:UIView!
    @IBOutlet weak var btnSave:UIButton!
    //var indexTitles:[String] = [String]()
    var record:Record!
    var canSave = true
    var shouldValidate = false
    
    var vHeader:EnterTagsView = EnterTagsView.getFromNib()
    var vFooter:AddNewField = AddNewField.getFromNib()
    
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
    
    private func initNewRecord() {
        // Init 3 default fields
        let username = Field()
        username.name = "Username"
        //username.value = nil
        
        let password = Field()
        password.name = "Password"
        //password.value = nil
        
        let empty = Field()
        //empty.name = nil
        //empty.value = nil
        
        // Init New Record
        self.record = Record()
        self.record.isDirty = true
        // default values like followings
//        self.record.isSynced = false
//        self.record.isDeleted = 0
        
        self.record.fields.append(objectsIn: [username, password, empty])
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Crashlytics.sharedInstance().crash()
        self.initNewRecord()
        self.vHeader.record = self.record
        self.tfTitle.becomeFirstResponder()
        self.adjustGUI()
        self.hideKeyboardWhenTappedAround()
        //self.view.translatesAutoresizingMaskIntoConstraints = true
        // Remove constraints if any.
        self.view.removeConstraints(self.view.constraints)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LocalNewRecordVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(LocalNewRecordVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
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
        // TODO: Remove empty fields or make sure no empty field
        guard self.validateInputForm() else {
            return
        }
        if self.record.tags != nil {
            self.record.tagsUpdatedAt = Date()
        }
        
        // Save to local database
        let recordCopy:Record = self.removeEmptyFields(record: self.record)
        guard recordCopy.fields.count > 0 else {
            let alert = AlertView.getFromNib(title: "Record must have at least 1 field.")
            alert.show()
            return
        }
        
        // Add record to shortcut
        Utils.addRecordToShortcut(recordID: self.record.id)
        
        self.doSave(newRecord: recordCopy)
    }
    
    private func doSave(newRecord:Record) {
        let recordCopy3 = newRecord.copy() as! Record
        AppDB.saveInBackground(record: newRecord) { (status, error) in
            guard error == nil else {
                Utils.showError(title: "Error Occurred", message: error)
                return
            }
            // If save ok, add record to Index for Full Text Search
            RecordIndex.addToIndexInBackground(record: recordCopy3) { (status, error) in
                guard error == nil else {
                    Utils.showError(title: "Error Occurred", message: error)
                    return
                }
            }
            // Save to server here or activating sync with server
            SyncRecords.syncWithServer()
            NotificationCenter.default.post(name: .Add_Record, object: nil, userInfo: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func removeEmptyFields(record:Record!) -> Record {
        let recordCopy = record.copy() as! Record
        let validFields = List<Field>()
        for field in recordCopy.fields {
            if !field.name.isEmpty && !field.value.isEmpty {
                validFields.append(field)
            }
        }
        recordCopy.fields.removeAll()
        recordCopy.fields.append(objectsIn: validFields)
        return recordCopy
    }
    
    @IBAction func ibaClose() {
        self.view.endEditing(true)
        // Check if user made any changes
        let title = self.record.title ?? ""
        if title.count > 0  {
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
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        //self.loadData()
        return false
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        self.record.title = textField.text
        self.removeRed(textField: self.tfTitle)
    }
    
    // MARK: Private methods
    private func adjustGUI() {
        self.iconX.image = self.iconX.image?.tint(UIColor.black)
        
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
        self.navBar.increaseHeight(value: 15)
        // self.formSearch.moveDown(distance: 24)
        //self.vAdd.moveDown(distance: 24)
        self.tbView.moveDown(distance: 15)
        self.tbView.decreaseHeight(value: 15)
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
        for i in 0..<self.record.fields.count {
            let indexPath = IndexPath(row: i, section: 0)
            let field = self.record.fields[i]
           
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
            if (self.record.fields.count <= 0) || self.checkIfRecordHasNoFields()  {
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
        for i in 0..<self.record.fields.count {
            let field = self.record.fields[i]
            let name = field.name ?? ""
            let value = field.value ?? ""
            if !name.isEmpty && !value.isEmpty {
                return false
            }
        }
        
        return true
    }
    
}// end class

extension LocalNewRecordVC:UITableViewDelegate, UITableViewDataSource {
    // MARK: TableViewDataSource _ Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.record.fields.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kEditFieldCell, for: indexPath)
        cell.selectionStyle = .none
        
        let field = self.record.fields[indexPath.row]
        (cell as! EditFieldCell).configureCellData(field)
        (cell as! EditFieldCell).index = indexPath
        
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
    
    @objc func deleteField(noti: NSNotification) {
        if let index = noti.userInfo![Keys.index] {
            let indexPath = index as! IndexPath
            self.record.fields.remove(at: indexPath.row)
            self.tbView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            self.tbView.reloadData()
        }
    }
    
    @objc func addNewField(noti: NSNotification) {
        guard self.record.fields.count <= 19 else { // Allow max is 20 field on a record
            self.view.endEditing(true)
            let alert = AlertView.getFromNib(title: "It seems you are adding too many fields.\nAre you doing tests?\n\nIf not, please let us know the reason or context you need many fields for a record. We will base on that to improve our app.\n\nThank you!")
            alert.show()
            return
        }
        
        let empty = Field()
        self.record.fields.append(empty)
//        self.tbView.reloadData()
//        self.scrollToBottom()
        
        // Append row at the bottom of tbView
        self.tbView.beginUpdates()
        let indexPath:IndexPath = IndexPath(row:(self.record.fields.count - 1), section:0)
        self.tbView.insertRows(at: [indexPath], with: .bottom)
        self.tbView.endUpdates()
        self.tbView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
   /* private func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.record.fields.count-1, section: 0)
            self.tbView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }*/
    
    // MARK: Keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
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
    
    @objc func keyboardWillHide(notification: NSNotification) {
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
