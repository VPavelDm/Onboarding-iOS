//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 02.11.24.
//

import SwiftUI

struct DiscountWheelProgressView: View {
    var progress: Double

    var body: some View {
        ProgressView(value: progress, total: 1)
            .progressViewStyle(.linear)
    }
}
