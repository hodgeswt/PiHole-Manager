//
//  BlacklistView.swift
//  PiHole Manager
//
//  Created by Will Hodges on 12/23/21.
//

import SwiftUI
import SwiftHole

struct BlacklistView: View {
    
    var scannedKey: String
    var ip: String
    
    @State var hole: SwiftHole?
    
    @State var blacklist = [ListItem]()
    
    var body: some View {
        VStack {
            Text("Blacklist")
                .font(.title)
            List(blacklist, id: \.self) { item in
                Text(item.domain)
            }
        }
        .onAppear(perform: fetch)
    }
    
    func fetch() {
        self.hole = SwiftHole.init(host: ip, apiToken: scannedKey)
        self.hole!.fetchList(ListType.blacklist) { result in
            switch result {
            case .success(let data):
                self.blacklist.append(contentsOf: data)
            case .failure(let error):
                print(error)
            }
        }
        
        self.hole!.fetchList(ListType.blacklistRegex) { result in
            switch result {
            case .success(let data):
                self.blacklist.append(contentsOf: data)
            case .failure(let error):
                print(error)
            }
        }
    }
}

struct BlacklistView_Previews: PreviewProvider {
    static var previews: some View {
        BlacklistView(scannedKey: "asdf", ip: "asdfasdf")
    }
}

