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
    
    @State var showAddDomain = false
    @State var domain = ""
    @State var exact = true
    
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
                List(blacklist, id: \.self) { item in
                    Text(item.domain)
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
        .onAppear(perform: fetch)
    }
    
    func addDomain() {
        let list: ListType = exact ? .blacklist : .blacklistRegex
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
        self.blacklist = [ListItem]()
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

