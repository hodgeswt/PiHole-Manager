//
//  WatchDataView.swift
//  PiHole-WatchOS WatchKit Extension
//
//  Created by Will Hodges on 12/24/21.
//

import SwiftUI

struct WatchDataView: View {
    
    var label: String
    var data: String
    var color: SwiftUI.Color
    
    var width: CGFloat
    var height: CGFloat
    
    @Binding var reload: Bool
    
    var body: some View {
        VStack {
            Text(label)
                .font(.body)
            Text(data)
                .font(.title2)
        }
        .multilineTextAlignment(.center)
        .frame(width: self.width, height: self.height)
        .background(
            RoundedRectangle(cornerRadius: 35, style: .continuous)
                .fill(self.color)
        )
        .foregroundColor(.white)
        .onTapGesture {
            reload.toggle()
        }
    }
}
