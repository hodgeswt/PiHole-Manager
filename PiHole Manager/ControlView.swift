//
//  ControlView.swift
//  PiHole Manager
//
//  Created by Will Hodges on 12/23/21.
//

import SwiftUI
import SwiftHole

struct ControlView: View {
    
    var scannedKey: String
    var ip: String
    
    @Binding var logOut: Bool
    
    @State var hole: SwiftHole?
    
    // False == currently enabled
    // True == currently disabled
    @State var disableState = false
    @State var disableText = "Disable"
    @State var disableColor = Color.red
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    TitleView(text: "Control Panel", color: Color.purple, width: geometry.size.width * 0.625, height: 50)
                    Spacer()
                }
                HStack {
                    let side = geometry.size.width / 3.2
                    DisableButton(text: disableText, color: disableColor, width: side, height: side)
                        .onTapGesture {
                            toggleHole()
                        }
                    LogOutButton(text: "Log Out", color: Color.blue, width: side, height: side, logOut: $logOut)
                }
                Spacer()
            }
        }
        .onAppear(perform: fetch)
    }
    
    func toggleHole() {
        if (self.disableState == false) {
            // We need to disable the PiHole
            self.hole!.disablePiHole(seconds: 0) { result in
                switch result {
                case .success:
                    self.disableState = true
                    updateButton()
                case .failure:
                    self.disableState = false
                    updateButton()
                }
            }
        } else {
            // We need to enable the PiHole
            self.hole!.enablePiHole() { result in
                switch result {
                case .success:
                    self.disableState = false
                    updateButton()
                case .failure:
                    self.disableState = true
                    updateButton()
                }
            }
        }
    }
    
    func updateButton() {
        disableText = disableState ? "Enable" : "Disable"
        disableColor = disableState ? Color.green : Color.red
    }
    
    func fetch() {
        self.hole = SwiftHole.init(host: ip, apiToken: scannedKey)
        hole!.fetchSummary { result in
                    switch result {
                    case .success(let summary):
                        if (summary.status == "enabled") {
                            self.disableState = false
                        } else {
                            self.disableState = true
                        }
                        updateButton()
                    case .failure(let error):
                        print(error)
                    }
                }
    }
}
