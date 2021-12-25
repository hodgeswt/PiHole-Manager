//
//  WatchConnectivityProvider.swift
//  PiHole Manager
//
//  Created by Will Hodges on 12/24/21.
//
import Foundation
import WatchConnectivity

class WatchConnectivityProvider: NSObject, WCSessionDelegate {
    
    private let session: WCSession
    
    var ip: String = ""
    var apiKey: String = ""
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        self.connect()
    }
    
    func send(message: [String:Any]) -> Void {
        session.sendMessage(message, replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        self.ip = message.keys.first!
        self.apiKey = message[self.ip] as! String
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // code
    }
    
    func connect() {
            guard WCSession.isSupported() else {
                print("WCSession is not supported")
                return
            }
           
            session.activate()
        }
}
