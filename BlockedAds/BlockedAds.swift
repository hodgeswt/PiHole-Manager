//
//  BlockedAds.swift
//  BlockedAds
//
//  Created by Will Hodges on 12/24/21.
//
import Foundation
import WidgetKit
import SwiftUI
import Intents
import SwiftHole


func round(_ value: Double, toNearest: Double) -> Double {
    return round(value / toNearest) * toNearest
}

extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

enum DefaultsFetchError: Error {
    case emptyDefaults
    case emptyApiResponse
}

struct DataRetriever {
    static func fetch(type: WidgetEnum, completion: @escaping (Result<String,Error>) -> ()) {
        
        let index = type.rawValue
        
        let defaults = UserDefaults(suiteName: "group.com.will-hodges.Pi-Hole-Manager")
        let ip = defaults!.string(forKey: "ip") ?? ""
        let apiKey = defaults!.string(forKey: "apiKey") ?? ""
        
        if ip == "" || apiKey == "" {
            completion(.failure(DefaultsFetchError.emptyDefaults))
        } else {
            let hole = SwiftHole.init(host: ip, apiToken: apiKey)
            hole.fetchSummary() { result in
                switch result {
                case .success(let data):
                    switch index {
                    case 1:
                        completion(.success(String(data.dnsQueriesToday)))
                    case 2:
                        completion(.success(String(round(data.adsPercentageToday, toNearest: 0.1).truncate(places: 2)) + "%"))
                    case 3:
                        completion(.success(String(data.domainsBeingBlocked)))
                    case 4:
                        completion(.success(String(data.uniqueClients)))
                    case 5:
                        completion(.success(String(data.queriesCached)))
                    case 6:
                        completion(.success(String(data.adsBlockedToday)))
                    default:
                        completion(.success(String(data.adsBlockedToday)))
                    }
                case .failure(_):
                    completion(.failure(DefaultsFetchError.emptyApiResponse))
                }
            }
        }
    }
}

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> BlockedAdsEntry {
        BlockedAdsEntry(date: Date(), text: "Ads Blocked", data: "100", color: .blue)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (BlockedAdsEntry) -> ()) {
        let entry = BlockedAdsEntry(date: Date(), text: "Ads Blocked", data: "100", color: .blue)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        DataRetriever.fetch(type: configuration.PiHoleWidgetType) { result in
            let currentDate = Date()
            let refreshDate: Date
            
            var entry: BlockedAdsEntry
            var entries: [BlockedAdsEntry] = [BlockedAdsEntry]()
            
            var text: String
            var color: SwiftUI.Color
            
            switch configuration.PiHoleWidgetType.rawValue {
            case 1:
                text = "Queries"
                color = .green
            case 2:
                text = "Percentage Blocked"
                color = .orange
            case 3:
                text = "Blocklist"
                color = .red
            case 4:
                text = "Clients"
                color = .cyan
            case 5:
                text = "Cache Size"
                color = .indigo
            case 6:
                text = "Blocked"
                color = .blue
            default:
                text = "Blocked"
                color = .blue
            }
            
            switch result {
            case .success(let blocked):
                entry = BlockedAdsEntry(date: currentDate, text: text, data: blocked, color: color)
                refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
            case .failure(_):
                entry = BlockedAdsEntry(date: currentDate, text: text, data: "0", color: color)
                refreshDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
            }
            entries.append(entry)
            let timeline = Timeline(entries: entries, policy: .after(refreshDate))
            
            completion(timeline)
        }
    }
}

struct BlockedAdsEntry: TimelineEntry {
    let date: Date
    let text: String
    let data: String
    let color: SwiftUI.Color
}

struct BlockedAdsEntryView : View {
    
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            VStack {
                Text(entry.text)
                    .font(.body)
                Spacer()
                    .fixedSize(horizontal: false, vertical: true)
                Text(String(entry.data))
                    .font(.title)
                    .foregroundColor(.white)
            }
        }
    }
}

@main
struct BlockedAds: Widget {
    
    let kind: String = "BlockedAds"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            BlockedAdsEntryView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(entry.color)
        }
        .configurationDisplayName("PiHole Widget")
        .description("This widget shows data from your PiHole.")
    }
    
}
