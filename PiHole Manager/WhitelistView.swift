//
//  WhitelistView.swift
//  PiHole Manager
//
//  Created by Will Hodges on 12/23/21.
//

import SwiftUI
import SwiftHole

struct WhitelistView: View {
    
    var scannedKey: String
    var ip: String
    
    @State var hole: SwiftHole?
    
    @State var whitelist = [ListItem]()
    
    var body: some View {
        VStack {
            Text("Whitelist")
                .font(.title)
            List(whitelist, id: \.self) { item in
                Text(item.domain)
            }
        }
        .onAppear(perform: fetch)
    }
    
    func fetch() {
        self.hole = SwiftHole.init(host: ip, apiToken: scannedKey)
        self.hole!.fetchList(ListType.whitelist) { result in
            switch result {
            case .success(let data):
                self.whitelist.append(contentsOf: data)
            case .failure(let error):
                print(error)
            }
        }
        
        self.hole!.fetchList(ListType.whitelistRegex) { result in
            switch result {
            case .success(let data):
                self.whitelist.append(contentsOf: data)
            case .failure(let error):
                print(error)
            }
        }
    }
}

struct WhitelistView_Previews: PreviewProvider {
    static var previews: some View {
        WhitelistView(scannedKey: "asdf", ip: "asdfasdf")
    }
}

