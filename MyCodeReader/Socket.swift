//
//  Socket.swift
//  MyCodeReader
//
//  Created by Akshay Bharath on 12/4/16.
//  Copyright © 2016 Akshay Bharath. All rights reserved.
//

import Foundation
import Starscream

class Socket {
    
    internal let wsURL = URL(string: "ws://echo.websocket.org")
    internal var socket: WebSocket!
    
    init() {
        socket = WebSocket(url: wsURL!)
        socket.delegate = self
        socket.connect()
    }
    
    func sendMessage(message: String, completion: (() -> ())? = nil) {
        socket.write(string: message, completion: completion)
    }
}

extension Socket: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocket) {
        print("WS Connected to \(wsURL!)")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("WS Disconnected: \(error?.localizedDescription)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("WS got some text: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("WS got some data: \(data.count)")
    }
}
