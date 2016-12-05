//
//  Backend.swift
//  MyCodeReader
//
//  Created by Akshay Bharath on 12/3/16.
//  Copyright © 2016 Akshay Bharath. All rights reserved.
//

import Foundation
import Photos
import SwiftyJSON

class Backend {
    static let clientID = "iphone"
    static let clientSecret = "iphone2secret"
    static let baseURLString = "https://qa.animoto.com/appservice"
    
    static let OAuthEndpoint = "/oauth/access_token"
    static let getUploadURLEndpoint = "/assets/upload_url"
    
    static var authToken: String?
    static var uploadURL: String?
}

extension Backend {
    
    static func getOAuthToken(completion: @escaping () -> ()) {
        let url = URL(string: "\(baseURLString)\(OAuthEndpoint)")
        var oRequest = URLRequest(url: url!)
        let authString = "\(clientID):\(clientSecret)"
        let encoded = authString.data(using: String.Encoding.utf8)!.base64EncodedString()
        let headerVals = [
            "Authorization": "Basic \(encoded)",
            "Accept": "application/vnd.animoto-v4+json",
            "Content-Type": "application/vnd.animoto-v4+json",
            "User-Agent": "Simulator (OS 10.0) (MyCodeReader 1.0) (app_service 2.0)"
        ]
        
        let body = NSMutableDictionary(capacity: 1)
        body["grant_type"] = "client_credentials"
        
        do {
            let json = try JSONSerialization.data(withJSONObject: body, options: [])
            oRequest.httpBody = json
            oRequest.httpMethod = "POST"
            oRequest.allHTTPHeaderFields = headerVals
        } catch {
            assertionFailure("Could not serialize json body of request")
        }
        
        let task = URLSession.shared.dataTask(with: oRequest) {
            data, response, error in
            
            if let data = data, error == nil {
                let jsonString = JSON(data: data)
                if let token = jsonString["access_token"].string {
                    print("New auth token is \(token)")
                    Backend.authToken = token
                }
            } else {
                print("error=\(error!.localizedDescription)")
            }
            
            completion()
        }
        
        task.resume()
    }
    
    static func getUploadURL() {
        let url = URL(string: "\(baseURLString)\(getUploadURLEndpoint)")
        var urlRequest = URLRequest(url: url!)
        let headerVals = [
            "Authorization": "Basic \(authToken!)",
            "Accept": "application/vnd.animoto-v4+json",
            "Content-Type": "application/vnd.animoto-v4+json",
            "User-Agent": "Simulator (OS 10.0) (MyCodeReader 1.0) (app_service 2.0)"
        ]
        
        urlRequest.httpMethod = "GET"
        urlRequest.allHTTPHeaderFields = headerVals
        
        let task = URLSession.shared.dataTask(with: urlRequest) {
            data, response, error in
            
            if let data = data, error == nil {
                let jsonString = JSON(data: data)
                if let url = jsonString["response"]["payload"]["url"].string {
                    print("Upload URL is \(url)")
                    Backend.uploadURL = url
                }
            } else {
                print("error=\(error!.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    static func uploadAsset(asset: PHAsset) {
        let phOptions = PHImageRequestOptions()
        phOptions.isNetworkAccessAllowed = true
        phOptions.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImageData(for: asset, options: phOptions) {
            (data, name, _, _) in
            
            if let imageData = data {
                let headerVals = [
                    "Content-Type": "image/jpeg",
                    "User-Agent": "Simulator (OS 10.0) (MyCodeReader 1.0) (app_service 2.0)"
                ]
                
                let body = NSMutableDictionary(capacity: 4)
                body["key"] = "Filedata"
                body["fileName"] = "sample.jpeg"
                body["contentType"] = "image/jpeg"
                body["data"] = imageData.base64EncodedString()
                
                let url = URL(string: uploadURL!)
                var urlRequest = URLRequest(url: url!)
                urlRequest.httpMethod = "POST"
                urlRequest.allHTTPHeaderFields = headerVals
                
                do {
                    let json = try JSONSerialization.data(withJSONObject: body, options: [])
                    urlRequest.httpBody = json
                    
                    let task = URLSession.shared.uploadTask(with: urlRequest, from: imageData) {
                        data, response, error in
                        
                        if let data = data, error == nil {
                            let jsonString = JSON(data: data)
                            print(jsonString)
                        } else {
                            print("error=\(error!.localizedDescription)")
                        }
                    }
                    
                    task.resume()

                } catch {
                    assertionFailure("Could not serialize json body of request")
                }
            }
        }
    }
}
