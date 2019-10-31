//
//  APIHandler.swift
//  ViPass
//
//  Created by Ngo Lien on 5/20/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class APIHandler: NSObject {

    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
    
        return SessionManager(configuration: configuration)
    }()

    public static let sharedInstance: APIHandler = {
        return APIHandler()
    }()


    override init() {
        super.init()
    }

    func getHeader() -> Alamofire.HTTPHeaders {
        if Utils.currentSyncMethod() == SyncMethod.custom {
            // Custom server
            let df = UserDefaults.standard
            let info = df.object(forKey: Keys.customServerInfo) as! [String:Any]
            let apiKey = (info[Keys.customServerAPIKey] as! String)
            return [Keys.api_Key: apiKey,
                    "Content-Type": "application/json"
            ]
        } else {
            // ViPass server. (e.g: "http://206.189.154.88:8181/api/v1/" )
            return [Keys.api_Key: AppConfig.api_Key_value,
                    "Content-Type": "application/json"
            ]
        }
    }
    
    func getServerURL() -> String {
        if Utils.currentSyncMethod() == SyncMethod.custom {
            // Custom server
            let df = UserDefaults.standard
            let info = df.object(forKey: Keys.customServerInfo) as! [String:Any]
            return (info[Keys.customServerURL] as! String)
        } else {
            // ViPass server. (e.g: "http://206.189.154.88:8181/api/v1/" )
            return AppConfig.BASE_API
        }
    }
    
    // Alamofire+Synchronous
    public func makeSyncRequest(_ api: String,
                            method: HTTPMethod = .get,
                            parameters: Parameters? = nil,
                            completion: @escaping APICompletion) {
        
        let urlString = self.getServerURL() + api
        let headers = self.getHeader()
        
        let response = Alamofire.request(urlString, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(options: .allowFragments)
        
        self.handle(response: response, completion: completion)
    }
    

    public func makeRequest(_ api: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        completion: @escaping APICompletion) {

        DDLog("makeRequest")
        let urlString = api //self.getServerURL() + api
        let headers = self.getHeader()

        Alamofire.request(urlString, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { (response: DataResponse<Any>) in
            
                self.handle(response: response, completion: completion)
        }
    }
    
    public func makeCustomRequest(_ api: String,
                            method: HTTPMethod = .get,
                            parameters: Parameters? = nil,
                            completion: @escaping APICompletion) {
        
        DDLog("makeCustomRequest")
        let urlString = Global.shared.customURL! + api
        let headers = [Keys.api_Key: Global.shared.customApiKey!,
                       "Content-Type": "application/json"]
        
        Alamofire.request(urlString, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { (response: DataResponse<Any>) in
                
                self.handle(response: response, completion: completion)
        }
    }
    
    // MARK: Private method
    private func handle(response:DataResponse<Any>, completion: @escaping APICompletion) {
        switch(response.result) {
        case .success(_):
            //DDLog("response : \(String(describing: response.result.value))")
            let json = JSON(response.result.value as Any)
            let result = json.dictionaryObject
            if json[Keys.status].bool == true {
                // Succeeded
                completion(true, result!)
            } else {
                // Failed
                let error = result![Keys.error] as! String
                self.handleError(msg: error, completion: completion)
            }
            
        case .failure(_):
            DDLog("API Failure : \(String(describing: response.result.error))")
            var msg = response.result.error?.localizedDescription ?? ""
            if msg == "" {
                msg = "Something went wrong"
            }
            DispatchQueue.main.async {
                Utils.showError(title: "Error Occurred", message: msg)
            }
            let errorInfo = [Keys.error: msg]
            completion(false, errorInfo)
        }
    }
    
    private func handleError(msg:String, completion: @escaping APICompletion) {
        if msg == ErrorMsg.invalid_session_key {
            // Happen when user login on another device. Then return this device
            
            // Remove Crendials
            Utils.removeCredentialsFromDisk()
            
            // Remove current user state
            Global.shared.currentUser = nil
            
            // show login screen
            DispatchQueue.main.async {
                let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
                appDelegate.showLoginOnly()
            }
        } else {
            DispatchQueue.main.async {
                Utils.showError(title: "Error Occurred", message: msg)
            }
            let errorInfo = [Keys.error: msg]
            completion(false, errorInfo)
        }
    }
    

}// class
