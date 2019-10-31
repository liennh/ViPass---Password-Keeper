//
//  AppDelegate.swift
//  ViPass
//
//  Created by Ngo Lien on 4/25/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import UIKit
import BigInt
import KeychainSwift
import RealmSwift
import CryptoSwift
import SwiftyStoreKit
import Fabric
import Crashlytics

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appIsStarting:Bool = false
    var copiedHUD:ClearClipboardView!
    
    func showCopiedHUD(content:String) {
        if self.copiedHUD != nil {
            self.copiedHUD.dismissView()
        }
        
        self.copiedHUD = ClearClipboardView.getFromNib()
        self.copiedHUD.lbContent.text = content
        self.copiedHUD.show()
    }
    
    func showCloudMainVC() {
        let mainVC = CloudMainVC()
        self.window?.rootViewController = mainVC
        self.window?.makeKeyAndVisible()
    }
    
    func showLocalMainVC() {
        let mainVC = LocalMainVC()
        self.window?.rootViewController = mainVC
        self.window?.makeKeyAndVisible()
    }
    
    func showUnlock(credentials:[String:Any]?) {
        var vc:UnlockVC?
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            vc = UnlockVC(nibName: "UnlockVC", bundle: nil)
        case .pad:
            vc = UnlockVC(nibName: "UnlockPAD", bundle: nil)
        default: break;
        }
        vc!.credentials = credentials
        self.window?.rootViewController = vc!
        self.window?.makeKeyAndVisible()
    }
    
    func showLogin() {
        self.window?.endEditing(true)
        var vc:LoginVC?
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            vc = LoginVC(nibName: "LoginVC", bundle: nil)
        case .pad:
            vc = LoginVC(nibName: "LoginPAD", bundle: nil)
        default: break;
        }
        let navVC = UINavigationController(rootViewController: vc!)
        navVC.isNavigationBarHidden = true
        self.window?.rootViewController = navVC
        self.window?.makeKeyAndVisible()
    }
    
    func showLoginOnly() {
        self.window?.endEditing(true)
        var vc:LoginVC?
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            vc = LoginVC(nibName: "LoginOnly", bundle: nil)
        case .pad:
            vc = LoginVC(nibName: "LoginPAD_Only", bundle: nil)
        default: break;
        }
        vc?.loginOnly = true
        let navVC = UINavigationController(rootViewController: vc!)
        navVC.isNavigationBarHidden = true
        self.window?.rootViewController = navVC
        self.window?.makeKeyAndVisible()
    }
    
    func showGetStarted() {
        self.window?.endEditing(true)
        var vc:GetStartedVC?
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            vc = GetStartedVC(nibName: "GetStartedVC", bundle: nil)
        case .pad:
            vc = GetStartedVC(nibName: "GetStartedPAD", bundle: nil)
        default: break;
        }
        let navVC = UINavigationController(rootViewController: vc!)
        navVC.isNavigationBarHidden = true
        self.window?.rootViewController = navVC
        self.window?.makeKeyAndVisible()
    }
    
    func showWelcome() {
        var welcomeVC:WelcomeVC?
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            welcomeVC = WelcomeVC(nibName: "WelcomeVC", bundle: nil)
        case .pad:
            if UIDevice.current.isPadPro129 {
                welcomeVC = WelcomeVC(nibName: "WelcomePAD129", bundle: nil)
            } else {
                welcomeVC = WelcomeVC(nibName: "WelcomePAD", bundle: nil)
            }
        default: break;
        }
        
        self.window?.rootViewController = welcomeVC
        self.window?.makeKeyAndVisible()
    }
    
    func test_encrypt2() {
        let key = GenUtils.generateRandomBytes(length: 32)
        let iv = GenUtils.generateRandomBytes(length: 16)
        let plainData = "Hello World vvv".bytes
        
        
        let wrongKey = GenUtils.generateRandomBytes(length: 32)
        
        let cbc = CBC(iv: iv)
        let aes = try! AES(key: key, blockMode: cbc, padding: .pkcs7)
        let encrypted = try! aes.encrypt(plainData)
        
        if encrypted != nil {
            let cbcXXX = CBC(iv: iv)
            let aesXXX = try! AES(key: key, blockMode: cbcXXX, padding: .pkcs7)
            let decrypted = try! aesXXX.decrypt(wrongKey)
            let str = (Data(bytes: decrypted)).toString()
            if str == "Hello World xxx" {
                DDLog("OKOKOK")
            } else {
                DDLog("Wrong")
            }
        } else {
            DDLog("Wrong")
        }
    }
    
    func testSHA1() {
        let H = Digest.hasher(.sha1)
        let result = H("1Pass Production".toData())
        let bytes = result.bytes
        DDLog("Result: \(bytes)")
    }
    
    func testBigInteger() {
        let bytes = "1Pass Production".bytes
        let a = BigUInt(Data(bytes: bytes))
    }
    
    func testCBC() {
        var key = [UInt8]()
        for i in 1...32 {
            key.append(UInt8(i))
        }
        
        var key2 = [UInt8]()
        for i in 0...31 {
            key2.append(UInt8(i))
        }

        var iv = [UInt8]()
        for i in 1...16 {
            iv.append(UInt8(i))
        }
       
        let plainData = "1Pass Production".toData().bytes
        DDLog("plain bytes: \(plainData.description)")
        
        let aes = try? AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
        let encrypted = try! aes?.encrypt(plainData)
        DDLog("encrypted: \(encrypted?.description)")
        
        let aesWithWrongKey = try? AES(key: key2, blockMode: CBC(iv: iv), padding: .pkcs7)
        let decrypted = try! aesWithWrongKey?.decrypt(encrypted!)
        DDLog("decrypted: \(decrypted?.description)")
        let data = Data(bytes: decrypted!)
        let str = String(data: data, encoding: .utf8)! // Will crash here. Thread 1: Fatal error: Unexpectedly found nil while unwrapping an Optional value
    }
    
    func testPBKDF2() {
        let bytes = "1Pass Production".bytes
        let saltBytes = "Salt".bytes
        let theKey:[UInt8] = try! PKCS5.PBKDF2(password: bytes, salt: saltBytes, iterations: 1, variant: .sha256).calculate()
        DDLog("KEY: \(theKey)")
        let xx = 1
        let xxx = xx + 2
    }
    
    func testRSA() {
        let inputData = "Hello".toData()
        guard let clientKey = try? RSA.Key(fromPEMPublicKey: Singleton.shared.publicKey) else {
            return
        }
        let encrypted = try? RSA.encrypt(data: inputData, withKey: clientKey, usingCipher: .aes_256_cbc)
        let bytes = encrypted?.bytes
        let xx = 1
    }
    
    func test_SessionKey() {
        let str = "1Pass Production";
        let inputBytes = str.bytes;
        
        let result = AppEncryptor.getSessionKey(bytes: inputBytes)
        DDLog("inputBytes: \(inputBytes)")
        DDLog("result: \(result)")
    }
    
    func test_MasterKey() {
        let password = "1Pass Production"
        let secretKey = "A big Secret"
        
        let result = AppEncryptor.getMasterKey(password: password, secretKey: secretKey)
        DDLog("result: \(result)")
    }
    
    func test_AES256() {
        let password = "1Pass Production"
        let secretKey = "A big Secret"
        let plainData = "Hello World".bytes
        
        let key = AppEncryptor.getMasterKey(password: password, secretKey: secretKey)
        let encrypted = AppEncryptor.encryptAES256(plainData: plainData, key: key!)
        let decrypted = AppEncryptor.decryptAES256(cipheredBytes: encrypted!, key: key!)
        
        
        DDLog("plainData byte[]: \(plainData)")
        DDLog("Key byte[]: \(key!)")
        DDLog("encrypted byte[]: \(encrypted!)")
        DDLog("decrypted byte[]: \(decrypted!)")
    }
    
    func test_SRP() {
        let salt = "Salt".toData()
        let I = "Alex"
        let P = "123456"
        let x = calculate_x(algorithm: .sha1, salt: salt, username: I, password: P)
        let v = calculate_v(group: .N3072, x: x)
        let k = calculate_k(group: .N3072, algorithm: .sha1)
        let u = calculate_u(group: .N3072, algorithm: .sha1, A: I.toData(), B: P.toData())
        let HAMK = calculate_HAMK(algorithm: .sha1, A: I.toData(), M: P.toData(), K: salt)
        
        let A = "I am A".toData();
        let B = "I am B".toData();
        let K = "I am K".toData();
        
        let M = calculate_M(group: .N3072, algorithm: .sha1, u: u, salt: salt, A: A, B: B, K: K)
        
        DDLog("x: \(x)")
        DDLog("v: \(v)")
        DDLog("k: \(k)")
        DDLog("u: \(u)")
        DDLog("HAMK: \(HAMK.bytes)")
        DDLog("M: \(M.bytes)")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NetworkAvailability.reachabilityForInternetConnection().startNotifier()
        UIApplication.shared.statusBarStyle = .lightContent
        self.completePendingPurchases()
        self.setupSiren()
       
        let df = UserDefaults.standard

        // Handle Push Notification
        if launchOptions != nil && launchOptions![UIApplicationLaunchOptionsKey.remoteNotification] != nil {
            self.appIsStarting = true
        }
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        
        // Check to show Welcome or Unlock screen
        if df.bool(forKey: Keys.alreadyShownWelcome) {
            // Not show Welcome any more
            // Read credentials from disk
            if let credentials = df.object(forKey: Keys.credentials) as? [String:Any] {
                let username = credentials[Keys.i] as! String
                if Utils.checkIfPrivateKeyAvailable(forUsername: username) {
                    // Show Unlock screen
                    self.showUnlock(credentials: credentials)
                } else {
                    self.showGetStarted()
                }
            } else {
                self.showGetStarted()
            }
        } else {
            df.set(true, forKey: Keys.alreadyShownWelcome)
            // Show Welcome
            self.showWelcome()
        }
        
        Fabric.with([Answers.self])
        Fabric.with([Crashlytics.self])
        self.window?.makeKeyAndVisible()
        
        
        let params = [
            "page": "hotel_page",
            "search_id": "",
            "params": [
                "check_in": "2019-05-15",
                "check_out": "2019-05-18",
                "marker": "153346.$1489",
                "currency": "usd",
                "locale": "en",
                "rooms": [[
                    "adults": 1,
                    "children": [12, 8]
                    ]],
                "locations_ids": [],
                "hotels_ids": [349035],
                "destination": "Hanoi Daewoo Hotel",
                "host": "travel.meembar.com",
                "flags": [
                    "auid": "CtY4vlwQuYpN+ENrLRJNAg==",
                    "ab": "",
                    "deviceType": "desktop"
                ],
                "popularity": "default"
            ],
            "selected_hotels_ids": [],
           // "filters": [],
            "sort": "popularity",
            "limit": 1,
            "offset": 0
            ] as! [String : Any]
        
        
        let url = "http://travel.meembar.com/api/wl_search/result"
        
//        APIHandler.sharedInstance.makeRequest(url, method: .post, parameters: params) { (status, xxxx) in
//            let x = 1
//        }
        postAction()
    
        
        return true
    }

func postAction() {
    let Url = String(format: "http://travel.meembar.com/api/wl_search/result")
    guard let serviceUrl = URL(string: Url) else { return }
    let params = [
        "page": "hotel_page",
        "search_id": "",
        "params": [
            "check_in": "2019-05-15",
            "check_out": "2019-05-18",
            "marker": "153346.$1489",
            "currency": "usd",
            "locale": "en",
            "rooms": [[
                "adults": 1,
                "children": [12, 8]
                ]],
            "locations_ids": [],
            "hotels_ids": [349035],
            "destination": "Hanoi Daewoo Hotel",
            "host": "travel.meembar.com",
            "flags": [
                "auid": "CtY4vlwQuYpN+ENrLRJNAg==",
                "ab": "",
                "deviceType": "desktop"
            ],
            "popularity": "default"
        ],
        "selected_hotels_ids": [],
        //"filters": [],
        "sort": "popularity",
        "limit": 1,
        "offset": 0
        ] as! [String : Any]
    var request = URLRequest(url: serviceUrl)
    request.httpMethod = "POST"
    request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
    guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
        return
    }
    request.httpBody = httpBody
    
    let session = URLSession.shared
    session.dataTask(with: request) { (data, response, error) in
        if let response = response {
            print(response)
        }
        if let data = data {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                
                print(json)
            } catch {
                print(error)
            }
        }
        }.resume()
}
    
    // Auto Lock App
    @objc public func applicationDidTimeout(notification: NSNotification) {
        DDLog("application did timeout, perform actions")
        // Read credentials from disk
        let df = UserDefaults.standard
        let credentials = df.object(forKey: Keys.credentials) as! [String:Any]
        // Show Unlock screen
        self.showUnlock(credentials: credentials)
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        self.appIsStarting = false
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.appIsStarting = false
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        self.appIsStarting = true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        //Check version
       // Siren.shared.checkVersion(checkType: .daily)
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.appIsStarting = false
       // PushHandler.showTabbarBadgeCount(index: 3)
        Siren.shared.checkVersion(checkType: .daily)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       /* let installation = PFInstallation.current()
        installation?.setDeviceTokenFrom(deviceToken)
        installation?.saveInBackground()
        
        PFPush.subscribeToChannel(inBackground: "") { succeeded, error in
            if succeeded {
                DDLog("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.\n")
            } else {
                DDLog("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.\n", error!)
            }
        }*/
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if error._code == 3010 {
            DDLog("Push notifications are not supported in the iOS Simulator.\n")
        } else {
            DDLog("application:didFailToRegisterForRemoteNotificationsWithError: %@\n", error)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
       /* PFPush.handle(userInfo)
        if application.applicationState == UIApplicationState.inactive {
            PFAnalytics.trackAppOpened(withRemoteNotificationPayload: userInfo)
        }*/
    }
    
    ///////////////////////////////////////////////////////////
    // Uncomment this method if you want to use Push Notifications with Background App Refresh
    ///////////////////////////////////////////////////////////
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //         if application.applicationState == UIApplicationState.Inactive {
        //             PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        //         }
        
       /* let state = application.applicationState
        if (state == UIApplicationState.background ||
            (state == UIApplicationState.inactive &&
                !self.appIsStarting)) {
            let aps:[String:Any] = userInfo["aps"] as! [String : Any]
            if (Utils.isObjectNotNil(aps as AnyObject)) {
                // perform the background fetch and
                // call completion handler
                PushHandler.increasePushBadgeCount()
                PushHandler.doBackgroundFetchPushNotification(userInfo, completionHandler)
            }
        } else if (state == UIApplicationState.inactive &&
            self.appIsStarting) {
            // user tapped notification
            PushHandler.increasePushBadgeCount()
            PushHandler.userDidTapOnPushNotification(userInfo)
            completionHandler(UIBackgroundFetchResult.newData)
        } else {
            // app is active
            PushHandler.handlePushNotificationWhenAppActive(userInfo)
            PushHandler.setTabbarBadgeCount(index: 3)
            completionHandler(UIBackgroundFetchResult.noData)
        }
        */
        
    }
    
    // MARK: In-app Purchase
    private func completePendingPurchases() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
    }
    
    // MARK: Check for New Updates
    func setupSiren() {
        let siren = Siren.shared
        
        // Optional
        siren.delegate = self
        
        // Optional
        siren.debugEnabled = false//true
        
        // Optional - Change the name of your app. Useful if you have a long app name and want to display a shortened version in the update dialog (e.g., the UIAlertController).
        siren.appName = AppConfig.App_Name
        
        // Optional - Change the various UIAlertController and UIAlertAction messaging. One or more values can be changes. If only a subset of values are changed, the defaults with which Siren comes with will be used.
        //        siren.alertMessaging = SirenAlertMessaging(updateTitle: "New Fancy Title",
        //                                                   updateMessage: "New message goes here!",
        //                                                   updateButtonMessage: "Update Now, Plz!?",
        //                                                   nextTimeButtonMessage: "OK, next time it is!",
        //                                                   skipVersionButtonMessage: "Please don't push skip, please don't!")
        
        // Optional - Defaults to .Option
        siren.alertType = .none // or .force, .skip, .option
        
        // Optional - Can set differentiated Alerts for Major, Minor, Patch, and Revision Updates (Must be called AFTER siren.alertType, if you are using siren.alertType)
       /* siren.majorUpdateAlertType = .option
        siren.minorUpdateAlertType = .option
        siren.patchUpdateAlertType = .option
        siren.revisionUpdateAlertType = .option
       */
        // Optional - Sets all messages to appear in Russian. Siren supports many other languages, not just English and Russian.
        //siren.forceLanguageLocalization = .english
        
        // Optional - Set this variable if your app is not available in the U.S. App Store. List of codes: https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Chapters/AppStoreTerritories.html
        //        siren.countryCode = ""
        
        // Optional - Set this variable if you would only like to show an alert if your app has been available on the store for a few days.
        // This default value is set to 1 to avoid this issue: https://github.com/ArtSabintsev/Siren#words-of-caution
        // To show the update immediately after Apple has updated their JSON, set this value to 0. Not recommended due to aforementioned reason in https://github.com/ArtSabintsev/Siren#words-of-caution.
        //        siren.showAlertAfterCurrentVersionHasBeenReleasedForDays = 3
        
        // Optional (Only do this if you don't call checkVersion in didBecomeActive)
        //        siren.checkVersion(checkType: .immediately)
    }

}

extension AppDelegate: SirenDelegate
{
    func sirenDidShowUpdateDialog(alertType: Siren.AlertType) {
       // DDLog(#function, alertType)
    }
    
    func sirenUserDidCancel() {
       // DDLog(#function)
    }
    
    func sirenUserDidSkipVersion() {
       // DDLog(#function)
    }
    
    func sirenUserDidLaunchAppStore() {
        //DDLog(#function)
    }
    
    func sirenDidFailVersionCheck(error: Error) {
        //DDLog(#function, error)
    }
    
    func sirenLatestVersionInstalled() {
        //DDLog(#function, "Latest version of app is installed")
    }
    
    func sirenNetworkCallDidReturnWithNewVersionInformation(lookupModel: SirenLookupModel) {
        //DDLog(#function, "\(lookupModel)")
    }
    
    // This delegate method is only hit when alertType is initialized to .none
    func sirenDidDetectNewVersionWithoutAlert(title: String, message: String, updateType: UpdateType) {
        let alert = AlertView.getFromNib(title: "Thank you for being a loyal customer. We are excited to inform you that a new version of \(AppConfig.App_Name) is available for download on AppStore. Please update it to get the latest features and the best user experience.\n\nDon't want to get hacked? Get ViPass!")
        alert.okAction = {
            Siren.shared.launchAppStore()
        }
        alert.force = true
        alert.show()
    }
}

