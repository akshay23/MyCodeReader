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
import ImagePicker
import SimpleAlert

class ViewController: UIViewController {
    
    @IBOutlet var scanButton: FUIButton!
    @IBOutlet var qrValueLabel: UILabel!

    lazy var readerVC = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode],
                                 captureDevicePosition: .back)
    })
    
    var scannedValue: String?
    var selectedAssets: [UIImage]?

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
        
        qrValueLabel.numberOfLines = 5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let _ = scannedValue {
            let imagePicker = ImagePickerController()
            imagePicker.delegate = self
            Configuration.doneButtonTitle = "Upload"
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let value = scannedValue {
            qrValueLabel.text = value
        } else {
            qrValueLabel.text = ""
        }
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
                self.scannedValue = res.value
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
        self.scannedValue = nil
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
}

// MARK: ImagePickerDelegate
extension ViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.selectedAssets = images
        
        dismiss(animated: true, completion: {
            var numOfAssets = 0
            if let assets = self.selectedAssets {
                numOfAssets = assets.count
            }
            
            let alert = AlertController(title: "Number of selected assets", message: "\(numOfAssets)", style: .alert)
            alert.addAction(AlertAction(title: "OK", style: .ok))
            self.present(alert, animated: true, completion: nil)
        })
        
    
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.scannedValue = nil
        dismiss(animated: true, completion: nil)
    }
}
