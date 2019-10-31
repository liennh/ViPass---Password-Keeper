//
//  ScanViewController.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2016-12-12.
//  Copyright © 2016 breadwallet LLC. All rights reserved.
//

import UIKit
import AVFoundation

let π: CGFloat = .pi

struct Padding {
    subscript(multiplier: Int) -> CGFloat {
        get {
            return CGFloat(multiplier) * 8.0
        }
    }
}

struct C {
    static let padding = Padding()
    struct Sizes {
        static let buttonHeight: CGFloat = 48.0
        static let headerHeight: CGFloat = 48.0
        static let largeHeaderHeight: CGFloat = 220.0
        static let logoAspectRatio: CGFloat = 125.0/417.0
        static let roundedCornerRadius: CGFloat = 6.0
    }
    static var defaultTintColor: UIColor = {
        return UIView().tintColor
    }()
}

typealias ScanCompletion = () -> Void
typealias KeyScanCompletion = (String) -> Void

class ScanViewController : UIViewController  { // Trackable

    static func showAlertCameraNotAllowed() {
        let confirm = ConfirmView.getFromNib(title: "ViPass is not allowed to access the camera. Go to Settings to allow camera access.", confirm: "Settings", cancel: "Cancel")
        confirm.confirmAction = {
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(appSettings)
            }
        }
        
        confirm.cancelAction = {} // Do nothing
        confirm.show()
    }

    static var isCameraAllowed: Bool {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) != .denied
    }

    var completion: ScanCompletion? = nil
    var scanKeyCompletion: KeyScanCompletion? = nil

    fileprivate let guide = CameraGuideView()
    fileprivate let session = AVCaptureSession()
    private let toolbar = UIView()
    private let close = UIButton.close
    private let flash = UIButton.icon(image: UIImage(named: "ic-flash")!, accessibilityLabel: "Camera Flash")
    fileprivate var currentUri = ""
    

    /*init(completion: @escaping ScanCompletion) {
        self.completion = completion
        self.scanKeyCompletion = nil
        super.init(nibName: nil, bundle: nil)
    }
*/
    init(scanKeyCompletion: @escaping KeyScanCompletion) {
        self.scanKeyCompletion = scanKeyCompletion
        self.completion = nil
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .black
        toolbar.backgroundColor = .secondaryButton

        view.addSubview(toolbar)
        toolbar.addSubview(close)
        toolbar.addSubview(flash)
        view.addSubview(guide)

        toolbar.constrainBottomCorners(sidePadding: 0, bottomPadding: 0)
        if E.isIPhoneX {
            toolbar.constrain([ toolbar.constraint(.height, constant: 60.0) ])
            
            close.constrain([
                close.constraint(.leading, toView: toolbar),
                close.constraint(.top, toView: toolbar, constant: 2.0),
                close.constraint(.width, constant: 44.0),
                close.constraint(.height, constant: 44.0) ])
            
            flash.constrain([
                flash.constraint(.trailing, toView: toolbar),
                flash.constraint(.top, toView: toolbar, constant: 2.0),
                flash.constraint(.width, constant: 44.0),
                flash.constraint(.height, constant: 44.0) ])
            
        } else {
            toolbar.constrain([ toolbar.constraint(.height, constant: 48.0) ])
            
            close.constrain([
                close.constraint(.leading, toView: toolbar),
                close.constraint(.top, toView: toolbar, constant: 2.0),
                close.constraint(.bottom, toView: toolbar, constant: -2.0),
                close.constraint(.width, constant: 44.0) ])
            
            flash.constrain([
                flash.constraint(.trailing, toView: toolbar),
                flash.constraint(.top, toView: toolbar, constant: 2.0),
                flash.constraint(.bottom, toView: toolbar, constant: -2.0),
                flash.constraint(.width, constant: 44.0) ])
        }

        guide.constrain([
            guide.constraint(.leading, toView: view, constant: C.padding[6]),
            guide.constraint(.trailing, toView: view, constant: -C.padding[6]),
            guide.constraint(.centerY, toView: view),
            NSLayoutConstraint(item: guide, attribute: .width, relatedBy: .equal, toItem: guide, attribute: .height, multiplier: 1.0, constant: 0.0) ])
        guide.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)

        close.tap = { [weak self] in
            self?.dismiss(animated: true, completion: {
            })
        }

        addCameraPreview()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.spring(0.8, animations: {
            self.guide.transform = .identity
        }, completion: { _ in })
        
        if ScanViewController.isCameraAllowed == false {
            ScanViewController.showAlertCameraNotAllowed()
        }
    }

    private func addCameraPreview() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        session.addInput(input)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)

        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: .main)
        session.addOutput(output)

        if output.availableMetadataObjectTypes.contains(where: { objectType in
            return objectType == AVMetadataObject.ObjectType.qr
        }) {
            output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        } else {
            let alert = AlertView.getFromNib(title: "No qr code support.")
            alert.show()
        }

        DispatchQueue(label: "qrscanner").async {
            self.session.startRunning()
        }

        if device.hasTorch {
            flash.tap = {
                do {
                    try device.lockForConfiguration()
                    device.torchMode = device.torchMode == .on ? .off : .on
                    device.unlockForConfiguration()
                } catch let error {
                    let alert = AlertView.getFromNib(title: "Camera Torch error.")
                    alert.show()
                }
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension ScanViewController : AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let data = metadataObjects as? [AVMetadataMachineReadableCodeObject] {
            if data.count == 0 {
                guide.state = .normal
            } else {
                data.forEach {
                    guard let uri = $0.stringValue else { return }
                    handleKey(uri)
                }
            }
        }
    }
    
    func isValid(privateKey:String) -> Bool {
        if UUID(uuidString: privateKey) != nil {
            return true
        } else {
            return false
        }
    }
    
    func handleKey(_ key: String) {
        if isValid(privateKey:key) {
            guide.state = .positive
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.dismiss(animated: true, completion: {
                    self.scanKeyCompletion?(key)
                })
            })
        } else {
            guide.state = .negative
        }
    }

}
