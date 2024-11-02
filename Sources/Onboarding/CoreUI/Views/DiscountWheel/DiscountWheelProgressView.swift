//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 02.11.24.
//

import SwiftUI

struct DiscountWheelProgressView: View {
    @State private var screenSize: CGSize = .zero

    @Binding var pressed: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .frame(height: 5)
                .foregroundStyle(.red)
            Rectangle()
                .frame(width: pressed ? screenSize.width : 0, height: 5)
                .foregroundStyle(.blue)
        }
        .readSize(size: $screenSize)
    }
}
