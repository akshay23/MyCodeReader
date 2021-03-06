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
import Photos
import MBProgressHUD

class ViewController: UIViewController {
    
    @IBOutlet var scanButton: FUIButton!
    @IBOutlet var qrValueLabel: UILabel!

    lazy var readerVC = QRCodeReaderViewController(builder: QRCodeReaderViewControllerBuilder {
        $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode],
                                 captureDevicePosition: .back)
    })
    
    var scannedValue: String?
    var selectedAssets: [PHAsset]?
    var selectedImages: [UIImage]?
    var galleryView: GalleryView?
    var socket: Socket!

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
        qrValueLabel.text = ""
        socket = Socket()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let value = scannedValue {
            socket.sendMessage(message: value) {
                DispatchQueue.main.async(execute: {
                    let imagePicker = ImagePickerController()
                    imagePicker.delegate = self
                    Configuration.doneButtonTitle = "Upload"
                    self.present(imagePicker, animated: true, completion: nil)
                })
            }
        } else {
            let imagePicker = ImagePickerController()
            imagePicker.delegate = self
            Configuration.doneButtonTitle = "Upload"
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let value = scannedValue {
            qrValueLabel.text = value
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func uploadAssets() {
        print("Upload assets to appservice")
        for asset in selectedAssets! {
            Backend.uploadAsset(asset: asset)
        }
    }
}

// MARK: IBActions
extension ViewController {
    @IBAction func showScanner(_ sender: Any) {
        // Retrieve the QRCode content
        // By using the delegate pattern
        readerVC.delegate = self
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    } 
}

// MARK: QRCodeReaderViewControllerDelegate
extension ViewController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        scannedValue = result.value
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
        socket.sendMessage(message: "cancelled")
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
}

// MARK: ImagePickerDelegate
extension ViewController: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if images.count > 0 {
            print("Number of assets \(imagePicker.stack.assets.count)")
            galleryView = GalleryView(frame: view.frame, delegate: self, images: images)
            imagePicker.view.addSubview(self.galleryView!)
            galleryView!.didMoveToSuperview()
        }
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        selectedAssets = imagePicker.stack.assets
        selectedImages = images
        scannedValue = nil
        dismiss(animated: true, completion: nil)
        
        if let images = selectedImages, images.count > 0 {
            uploadAssets()
        }
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        scannedValue = nil
        socket.sendMessage(message: "cancelled")
        dismiss(animated: true, completion: nil)
    }
}

// MARK: GalleryViewDelegate
extension ViewController: GalleryViewDelegate {
    func dissmissGalleryView() {
        if let gView = galleryView {
            gView.removeFromSuperview()
            galleryView = nil
        }
    }
}
