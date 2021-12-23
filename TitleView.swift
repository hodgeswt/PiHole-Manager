//
//  TitleView.swift
//  PiHole Manager
//
//  Created by Will Hodges on 12/23/21.
//

import SwiftUI

struct TitleView: View {
    
    var text: String
    var color: SwiftUI.Color
    var width: CGFloat
    var height: CGFloat
    
    
    var body: some View {
        VStack {
            Text(text)
                .font(.title)
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

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView(text: "Test", color: SwiftUI.Color.red, width: .infinity, height: 150)
    }
}

