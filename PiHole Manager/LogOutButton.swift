//
//  LogOutButton.swift
//  PiHole Manager
//
//  Created by Will Hodges on 12/23/21.
//

import SwiftUI

struct LogOutButton: View {
    
    var text: String
    var color: SwiftUI.Color
    
    var width: CGFloat
    var height: CGFloat
    
    @Binding var logOut: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                self.logOut.toggle()
            }) {
                Text(text)
                    .font(.title2)
            }
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
