//
//  OverviewView.swift
//  PiHole Manager
//
//  Created by Will Hodges on 12/23/21.
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

struct OverviewView: View {

    var scannedKey: String
    var ip: String
    
    @State var hole: SwiftHole?
    
    @State var summary: Summary?
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                TitleView(text: "Today's Data", color: Color.purple, width: geometry.size.width * 0.9375, height: 50)
                    if let summary = summary {
                        let side = geometry.size.width / 3.2
                        HStack {
                            Spacer()
                            DataView(label: "Queries", data: String(summary.dnsQueriesToday), color: Color.green, width: side, height: side)
                            DataView(label: "Blocked", data: String(summary.adsBlockedToday), color: Color.blue, width: side, height: side)
                            DataView(label: "Percentage Blocked", data: String(round(summary.adsPercentageToday, toNearest: 0.1).truncate(places: 2)) + "%", color: Color.orange, width: side, height: side)
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            DataView(label: "Blocklist", data: String(summary.domainsBeingBlocked), color: SwiftUI.Color.red, width: side, height: side)
                            DataView(label: "Clients", data: String(summary.uniqueClients), color: SwiftUI.Color.cyan, width: side, height: side)
                            DataView(label: "Cache Size", data: String(summary.queriesCached), color: SwiftUI.Color.indigo, width: side, height: side)
                            Spacer()
                        }
                    }
                Button(action: {
                    fetch()
                }) {
                    VStack {
                        Text("Refresh")
                            .font(.title)
                    }
                    .multilineTextAlignment(.center)
                    .frame(width: geometry.size.width * 0.9375, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 35, style: .continuous)
                            .fill(.mint)
                    )
                    .foregroundColor(.white)
                }
                Spacer()
            }
        }.onAppear(perform: fetch)
    }
    
    func fetch() {
        self.hole = SwiftHole.init(host: ip, apiToken: scannedKey)
        hole!.fetchSummary { result in
                    switch result {
                    case .success(let summary):
                        self.summary = summary
                    case .failure(let error):
                        print(error)
                    }
                }
    }
}

struct OverviewView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewView(scannedKey: "testing", ip: "0.0.0.0")
    }
}
