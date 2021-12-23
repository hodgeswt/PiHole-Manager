//
//  ContentView.swift
//  PiHole Manager
//
//  Created by Will Hodges on 12/23/21.
//

import SwiftUI
import CodeScanner

struct ContentView: View {
    let defaults = UserDefaults.standard
    
    @State var loggedIn = false
    
    @State var scan = false
    @State var scannedKey: String?
    
    @State var showEnterIp = false
    @State var enterIp = false
    @State var ip = ""
    
    @State var showHelp = false
    
    @State var buttonText = "Scan API Key"
    @State var instructionsText = ""

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
                            loggedIn = true
                        }
                    }
                }
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Scan")
                }
            } else {
                OverviewView(scannedKey: scannedKey!, ip: ip)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Overview")
                    }
                ControlView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Controls")
                    }
            }
        }.onAppear(perform: fetch)
    }
    
    func fetch() {
        if let savedIp = self.defaults.string(forKey: "ip") {
            if let savedKey = self.defaults.string(forKey: "apiKey") {
                if savedIp != "" && savedKey != "" {
                    self.ip = savedIp
                    self.scannedKey = savedKey
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
