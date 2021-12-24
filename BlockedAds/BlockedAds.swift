//
//  BlockedAds.swift
//  BlockedAds
//
//  Created by Will Hodges on 12/24/21.
//

import WidgetKit
import SwiftUI
import Intents
import SwiftHole

enum DefaultsFetchError: Error {
    case emptyDefaults
    case emptyApiResponse
}

struct DataRetriever {
    static func fetch(completion: @escaping (Result<Int,Error>) -> ()) {
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
                    completion(.success(data.adsBlockedToday))
                case .failure(_):
                    completion(.failure(DefaultsFetchError.emptyApiResponse))
                }
            }
        }
    }
}

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> BlockedAdsEntry {
        BlockedAdsEntry(date: Date(), adsBlocked: 100)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (BlockedAdsEntry) -> ()) {
        let entry = BlockedAdsEntry(date: Date(), adsBlocked: 100)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        DataRetriever.fetch() { result in
            let currentDate = Date()
            let refreshDate: Date
            
            var entry: BlockedAdsEntry
            var entries: [BlockedAdsEntry] = [BlockedAdsEntry]()
            
            switch result {
            case .success(let blocked):
                entry = BlockedAdsEntry(date: currentDate, adsBlocked: blocked)
                refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
            case .failure(_):
                entry = BlockedAdsEntry(date: currentDate, adsBlocked: 0)
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
    let adsBlocked: Int
}

struct BlockedAdsEntryView : View {
    
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            VStack {
                Text("Ads Blocked")
                    .font(.body)
                Spacer()
                    .fixedSize(horizontal: false, vertical: true)
                Text(String(entry.adsBlocked))
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
                .background(SwiftUI.Color.blue)
        }
        .configurationDisplayName("Blocked Ads")
        .description("This widget shows the number of ads your PiHole has blocked today.")
    }
    
}
