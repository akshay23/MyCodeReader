//
//  Backend.swift
//  MyCodeReader
//
//  Created by Akshay Bharath on 12/3/16.
//  Copyright © 2016 Akshay Bharath. All rights reserved.
//

import Foundation
import Alamofire

struct Animoto {
    enum Router: URLRequestConvertible {
        static let baseURLString = ""
        static let clientID = ""
        static let clientSecret = ""
        
        case authenticate
        case upload
        
        func asURLRequest() throws -> URLRequest {
            let result: (path: String, parameters: Parameters) = {
                switch self {
                case .authenticate:
                    return ("/oauth/access_token", [:])
                    
                default:
                    return ("",[:])
                }
            }()
            
            let url = try Router.baseURLString.asURL()
            let urlRequest = URLRequest(url: url.appendingPathComponent(result.path))
            
            return try URLEncoding.default.encode(urlRequest, with: result.parameters)
        }
    }
}
