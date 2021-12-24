//
//  DisableButton.swift
//  PiHole Manager
//
//  Created by Will Hodges on 12/23/21.
//

import SwiftUI

struct DisableButton: View {
    
    var text: String
    var color: SwiftUI.Color
    
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        VStack {
            Spacer()
            Text(text)
                .font(.title2)
            Spacer()
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

struct DisableButton_Previews: PreviewProvider {
    static var previews: some View {
        DisableButton(text: "Disable", color: .red, width: 50, height: 50)
    }
}

