//
//  ViewController.swift
//  MyCodeReader
//
//  Created by Akshay Bharath on 12/3/16.
//  Copyright © 2016 Akshay Bharath. All rights reserved.
//

import UIKit
import FlatUIKit
import FontAwesome_swift
import AVFoundation
import QRCodeReader

class ViewController: UIViewController {
    
    @IBOutlet var scanButton: FUIButton!
    
    lazy var readerVC = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode],
                                 captureDevicePosition: .back)
    })

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanButton.buttonColor = UIColor.turquoise()
        scanButton.shadowColor = UIColor.greenSea()
        scanButton.shadowHeight = 6.0
        scanButton.cornerRadius = 6.0
        scanButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 60)
        scanButton.setTitle(String.fontAwesomeIcon(name: .qrcode), for: .normal)
        scanButton.setTitleColor(UIColor.clouds(), for: .normal)
        scanButton.setTitleColor(UIColor.clouds(), for: .highlighted)
        
        let naviTitleFrame = CGRect(x: 0, y: 0, width: 100, height: 40)
        let naviTitle = UITextView(frame: naviTitleFrame)
        naviTitle.text = "Scan QR Code"
        naviTitle.font = UIFont.systemFont(ofSize: 18)
        naviTitle.backgroundColor = .clear
        naviTitle.textAlignment = .center
        navigationItem.titleView = naviTitle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: IBActions
extension ViewController {
    @IBAction func showScanner(_ sender: Any) {
        // Retrieve the QRCode content
        // By using the delegate pattern
        readerVC.delegate = self
        
        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            if let res = result {
                print("Actually scanned value is \(res.value)")
            }
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    } 
}


// MARK: QRCodeReaderViewControllerDelegate
extension ViewController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        if let cameraName = newCaptureDevice.device.localizedName {
            print("Switching capturing to: \(cameraName)")
        }
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
}
