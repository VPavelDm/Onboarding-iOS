//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 07.09.24.
//

import SwiftUI

struct BackButton: View {
    @Environment(\.colorPalette) private var colorPalette

    var action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "chevron.compact.left")
                .resizable()
                .font(.system(size: 12, weight: .light))
                .frame(width: 12, height: 16)
                .frame(width: 20)
                .foregroundStyle(colorPalette.primaryTextColor)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
