//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 23.09.24.
//

import SwiftUI

struct CasinoStepView: View {
    @Environment(\.colorPalette) private var colorPalette

    var body: some View {
        VStack {
            titleView
            Spacer()
            CasinoWheel(colors: .wheelColors)
            Spacer()
            spinButton
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colorPalette.backgroundColor)
    }

    private var titleView: some View {
        Text("Spin to Win Your Prime Discount")
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .foregroundStyle(colorPalette.primaryTextColor)
    }

    private var spinButton: some View {
        Button {} label: {
            Text("Spin")
        }
        .buttonStyle(PrimaryButtonStyle())
    }
}

private extension Array where Element == Color {

    static var wheelColors: [Color] {
        [.darkSlice, .lightSlice, .darkSlice, .lightSlice, .darkSlice, .lightSlice, .gift, .lightSlice]
    }
}

private extension Color {

    static var darkSlice: Color {
        Color(hex: "4D5761")
    }

    static var lightSlice: Color {
        Color(hex: "6C737F")
    }

    static var gift: Color {
        Color(hex: "EF5350")
    }
}

#Preview {
    CasinoStepView()
}
