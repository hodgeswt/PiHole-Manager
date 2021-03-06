//
//  ContentView.swift
//  PiHole Manager
//
//  Created by Will Hodges on 12/23/21.
//

import SwiftUI
import CodeScanner
import WatchConnectivity

struct ContentView: View {
    
    var model = PhoneConnectivityProvider()
    
    let defaults = UserDefaults(suiteName: "group.com.will-hodges.Pi-Hole-Manager")!
    
    @State var loggedIn = false
    @State var logOut = false
    
    @State var scan = false
    @State var scannedKey: String?
    
    @State var showEnterIp = false
    @State var enterIp = false
    @State var ip = ""
    
    @State var showHelp = false
    
    @State var buttonText = "Scan API Key"
    
    var body: some View {
        TabView {
            if (!loggedIn) {
                VStack {
                    Text("Log In").font(.title)
                    Spacer()
                    Button(action: {
                        if (buttonText == "Scan API Key") {
                            scan = true
                        }
                        
                        if (buttonText == "Enter PiHole IP") {
                            enterIp = true
                        }
                    }) {
                        Text(buttonText)
                    }
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 35, style: .continuous)
                            .fill(Color.blue)
                    )
                    .foregroundColor(.white)
                    .onTapGesture {
                        if (buttonText == "Scan API Key") {
                            scan = true
                        }
                        
                        if (buttonText == "Enter PiHole IP") {
                            enterIp = true
                        }
                    }
                    Spacer().fixedSize(horizontal: false, vertical: true)
                    Button(action: {
                        showHelp = true
                    }) {
                        Text("Help")
                            .font(.footnote)
                    }
                    Spacer()
                }
                .sheet(isPresented: $showHelp) {
                    VStack {
                        Text("Your API Key is available on your PiHole Admin Panel, under Settings > API/Web Interface > Show API token.\n\nYour PiHole IP is the address of your PiHole. It should be four numbers separated by periods.")
                        Spacer().fixedSize(horizontal: false, vertical: true)
                        Button("Dismiss") {
                            showHelp = false
                        }
                        .frame(height: 25)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 35, style: .continuous)
                                .fill(Color.blue)
                        )
                        .foregroundColor(.white)
                        .onTapGesture {
                            showHelp = false
                        }
                    }
                }
                .sheet(isPresented: $scan) {
                    CodeScannerView(codeTypes: [.qr]) { response in
                        if case let .success(result) = response {
                            scannedKey = result.string
                            self.defaults.set(result.string, forKey: "apiKey")
                            scan = false
                            buttonText = "Enter PiHole IP"
                        }
                    }
                }
                .sheet(isPresented: $enterIp) {
                    VStack {
                        HStack {
                            Spacer()
                            TextField("PiHole IP", text: $ip)
                                .keyboardType(.numbersAndPunctuation)
                            Spacer()
                        }
                        Spacer().fixedSize(horizontal: false, vertical: true)
                        Button("Save IP") {
                            self.defaults.set(self.ip, forKey: "ip")
                            self.model.send(message: [self.ip:self.scannedKey!])
                            enterIp = false
                            loggedIn = true
                        }
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 35, style: .continuous)
                                .fill(Color.blue)
                        )
                        .foregroundColor(.white)
                        .onTapGesture {
                            self.defaults.set(self.ip, forKey: "ip")
                            self.model.send(message: [self.ip:self.scannedKey!])
                            loggedIn = true
                        }
                    }
                }
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Scan")
                }
            } else {
                OverviewView(scannedKey: scannedKey!, ip: ip, logOut: $logOut)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Overview")
                    }
                BlacklistView(scannedKey: scannedKey!, ip: ip, logOut: $logOut)
                    .tabItem {
                        Image(systemName: "exclamationmark.octagon")
                        Text("Blacklist")
                    }
                WhitelistView(scannedKey: scannedKey!, ip: ip, logOut: $logOut)
                    .tabItem {
                        Image(systemName: "checkmark.circle")
                        Text("Whitelist")
                    }
                ControlView(scannedKey: scannedKey!, ip: ip, logOut: $logOut)
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Controls")
                    }
            }
        }
        .onChange(of: logOut) { _ in
            self.defaults.set("", forKey: "apiKey")
            self.defaults.set("", forKey: "ip")
            self.ip = ""
            
            self.scan = false
            self.scannedKey = nil
            
            self.showEnterIp = false
            self.enterIp = false
            self.ip = ""
            
            self.showHelp = false
            
            self.buttonText = "Scan API Key"
            
            self.model.send(message: ["":""])
            
            self.loggedIn = false
        }
        .onAppear(perform: fetch)
    }
    
    func fetch() {
        if let savedIp = self.defaults.string(forKey: "ip") {
            if let savedKey = self.defaults.string(forKey: "apiKey") {
                if savedIp != "" && savedKey != "" {
                    self.ip = savedIp
                    self.scannedKey = savedKey
                    self.model.send(message: [savedIp:savedKey])
                    self.loggedIn = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
