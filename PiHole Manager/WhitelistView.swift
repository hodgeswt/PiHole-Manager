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
    
    @State var whitelist = [ListItem:ListType]()
    @State var whitelistDomains = [ListItem]()
    
    @State var showAddDomain = false
    @State var domain = ""
    @State var exact = true
    
    @State var showAlert = false
    
    @Binding var logOut: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Whitelist")
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
                .foregroundColor(.white)
                .onTapGesture {
                    showAddDomain = true
                }
                List {
                    ForEach(whitelistDomains, id: \.self) { item in
                        Text(item.domain)
                    }
                    .onDelete(perform: deleteItem)
                }
                .refreshable {
                    fetch()
                }
            }
        }
        .alert("Invalid API Key or PiHole IP", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                self.logOut = true
            }
        }
        .onAppear(perform: fetch)
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
    }
    
    func deleteItem(at offsets: IndexSet) {
        let index = offsets.first!
        let item: ListItem = whitelistDomains[index]
        let list = whitelist[item]
        
        self.hole!.remove(domain: item.domain, from: list!) { result in
            switch result {
            case .success(_):
                whitelistDomains.remove(at: index)
                whitelist.removeValue(forKey: item)
            case .failure(_):
                break
            }
        }
    }
    
    func addDomain() {
        let list: ListType = exact ? .whitelist : .whitelistRegex
        self.hole!.add(domain: self.domain, to: list) { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                print(error)
            }
            
        }
        self.domain = ""
        fetch()
        showAddDomain = false
    }
    
    func fetch() {
        self.whitelist = [ListItem:ListType]()
        self.whitelistDomains = [ListItem]()
        self.hole = SwiftHole.init(host: ip, apiToken: scannedKey)
        
        self.hole!.fetchSummary { result in
                    switch result {
                    case .failure(_):
                        self.showAlert = true
                    default:
                        break
                    }
                }
        
        self.hole!.fetchList(ListType.whitelist) { result in
            switch result {
            case .success(let data):
                for item in data {
                    self.whitelist[item] = ListType.whitelist
                }
                self.whitelistDomains.append(contentsOf: data)
            case .failure(_):
                break
            }
        }
        
        self.hole!.fetchList(ListType.whitelistRegex) { result in
            switch result {
            case .success(let data):
                for item in data {
                    self.whitelist[item] = ListType.whitelistRegex
                }
                self.whitelistDomains.append(contentsOf: data)
            case .failure(_):
                break
            }
        }
    }
}
