//
//  DataView.swift
//  PiHole Manager
//
//  Created by Will Hodges on 12/23/21.
//

import SwiftUI

struct DataView: View {
    
    var label: String
    var data: String
    var color: SwiftUI.Color
    
    var width: CGFloat
    var height: CGFloat
    
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
    }
}

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView(label: "test", data: "323", color: SwiftUI.Color.green, width: 150, height: 150)
    }
}

