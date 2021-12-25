//
//  ContentView.swift
//  PiHole-WatchOS WatchKit Extension
//
//  Created by Will Hodges on 12/24/21.
//
import Foundation
import SwiftUI
import SwiftHole

func round(_ value: Double, toNearest: Double) -> Double {
    return round(value / toNearest) * toNearest
}

extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

struct ContentView: View {
    
    @State var loggedIn = false
    
    @State var ip: String = ""
    @State var apiKey: String = ""
    
    @State var summary: Summary?
    
    @State var reload = false
    @State var text = "Loading..."
    
    var model = WatchConnectivityProvider()
    
    var body: some View {
        if loggedIn {
            if let data = summary {
                GeometryReader { geometry in
                    let width = geometry.size.width;
                    let height = geometry.size.height;
                    
                    TabView {
                        WatchDataView(label: "Queries", data: String(data.dnsQueriesToday), color: Color.green, width: width, height: height, reload: $loggedIn)
                        WatchDataView(label: "Blocked", data: String(data.adsBlockedToday), color: Color.blue, width: width, height: height, reload: $loggedIn)
                        WatchDataView(label: "Percentage Blocked", data: String(round(data.adsPercentageToday, toNearest: 0.1).truncate(places: 2)) + "%", color: Color.orange, width: width, height: height, reload: $loggedIn)
                        WatchDataView(label: "Blocklist", data: String(data.domainsBeingBlocked), color: Color.red, width: width, height: height, reload: $loggedIn)
                        WatchDataView(label: "Clients", data: String(data.uniqueClients), color: Color.cyan, width: width, height: height, reload: $loggedIn)
                        WatchDataView(label: "Cache Size", data: String(data.queriesCached), color: Color.indigo, width: width, height: height, reload: $loggedIn)
                    }
                }
                .onAppear(perform: fetch)
            }
        } else {
            NotLoggedView(reload: $reload, text: $text)
            .onAppear(perform: fetch)
        }
    }
    
    func fetch() {
        model.connect()
        model.send(message: ["dataRequest": true])
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if model.apiKey != "" && model.ip != "" {
                self.apiKey = model.apiKey
                self.ip = model.ip
                self.loggedIn = true
                
                let hole = SwiftHole.init(host: self.ip, apiToken: self.apiKey)
                hole.fetchSummary { result in
                            switch result {
                            case .success(let summary):
                                self.summary = summary
                            case .failure(_):
                                break
                            }
                        }
                
            } else {
                self.apiKey = ""
                self.ip = ""
                self.loggedIn = false
                self.text = "Please Log in using the PiHole Manager iOS App."
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
