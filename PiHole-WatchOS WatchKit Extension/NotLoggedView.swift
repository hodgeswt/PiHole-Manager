//
//  NotLoggedView.swift
//  PiHole-WatchOS WatchKit Extension
//
//  Created by Will Hodges on 12/24/21.
//

import SwiftUI

struct NotLoggedView: View {
    
    @Binding var reload: Bool
    @Binding var text: String
    
    var body: some View {
        VStack {
            Spacer()
            Text(text)
            Spacer()
        }
    }
}
