//
//  PhoneConnectivityProvider.swift
//  PiHole Manager
//
//  Created by Will Hodges on 12/24/21.
//
import Foundation
import WatchConnectivity

class PhoneConnectivityProvider: NSObject, WCSessionDelegate {
    
    private let session: WCSession
    
    let defaults = UserDefaults(suiteName: "group.com.will-hodges.Pi-Hole-Manager")!
    
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
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // code
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // code
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // code
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let ip = defaults.string(forKey: "ip") {
            if let apiKey = defaults.string(forKey: "apiKey") {
                self.send(message: [ip: apiKey])
            }
        }
    }
    
    func connect() {
            guard WCSession.isSupported() else {
                print("WCSession is not supported")
                return
            }
           
            session.activate()
        }
}
