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
    
    @State var blacklist = [ListItem:ListType]()
    @State var blacklistDomains = [ListItem]()
    
    @State var showAddDomain = false
    @State var domain = ""
    @State var exact = true
    
    @State var showAlert = false
    
    @Binding var logOut: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Blacklist")
                    .font(.title)
                Spacer()
                Button(action: {
                    showAddDomain = true
                }) {
                    Text("Add Domain")
                }
                .frame(width: geometry.size.width * 0.925, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 35, style: .continuous)
                        .fill(Color.blue)
                )
                .onTapGesture {
                    showAddDomain = true
                }
                .foregroundColor(.white)
                List {
                    ForEach(blacklistDomains, id: \.self) { item in
                        Text(item.domain)
                    }
                    .onDelete(perform: deleteItem)
                }
                .refreshable {
                    fetch()
                }
            }
        }
        .sheet(isPresented: $showAddDomain)  {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        TextField("Domain name", text: $domain)
                        Spacer()
                    }
                    Spacer()
                        .fixedSize(horizontal: false, vertical: true)
                    HStack {
                        Spacer()
                        Toggle("Exact", isOn: $exact)
                        Spacer()
                    }
                    Spacer()
                        .fixedSize(horizontal: false, vertical: true)
                    Button(action: {
                        addDomain()
                    }) {
                        Text("Add Domain")
                    }.frame(width: geometry.size.width * 0.925, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 35, style: .continuous)
                                .fill(Color.blue)
                        )
                        .foregroundColor(.white)
                        .onTapGesture {
                            addDomain()
                        }
                    Spacer()
                }
            }
        }
        .alert("Invalid API Key or PiHole IP", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                self.logOut = true
            }
        }
        .onAppear(perform: fetch)
    }
    
    func deleteItem(at offsets: IndexSet) {
        let index = offsets.first!
        let item: ListItem = blacklistDomains[index]
        let list = blacklist[item]
        
        self.hole!.remove(domain: item.domain, from: list!) { result in
            switch result {
            case .success(_):
                blacklistDomains.remove(at: index)
                blacklist.removeValue(forKey: item)
            case .failure(_):
                break
            }
        }
    }
    
    func addDomain() {
        let list: ListType = exact ? .blacklist : .blacklistRegex
        self.hole!.add(domain: self.domain, to: list) { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                break
            }
            
        }
        self.domain = ""
        fetch()
        showAddDomain = false
    }
    
    func fetch() {
        self.blacklist = [ListItem:ListType]()
        self.blacklistDomains = [ListItem]()
        self.hole = SwiftHole.init(host: ip, apiToken: scannedKey)
        
        self.hole!.fetchSummary { result in
                    switch result {
                    case .failure(_):
                        self.showAlert = true
                    default:
                        break
                    }
                }
        
        
        self.hole!.fetchList(ListType.blacklist) { result in
            switch result {
            case .success(let data):
                for item in data {
                    self.blacklist[item] = ListType.blacklist
                }
                self.blacklistDomains.append(contentsOf: data)
            case .failure(_):
                break
            }
        }
        
        self.hole!.fetchList(ListType.blacklistRegex) { result in
            switch result {
            case .success(let data):
                for item in data {
                    self.blacklist[item] = ListType.blacklistRegex
                }
                self.blacklistDomains.append(contentsOf: data)
            case .failure(_):
                break
            }
        }
    }
}
