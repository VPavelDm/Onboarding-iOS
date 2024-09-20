//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 20.09.24.
//

import SwiftUI

extension WheelTimePicker {

    struct TimePickerIOS16: View {
        @EnvironmentObject private var viewModel: ViewModel

        var intProxy: Binding<Double> {
            Binding(
                get: { Double(viewModel.selectedTimeIndex ?? 0) },
                set: { newValue in viewModel.selectedTimeIndex = Int(newValue) }
            )
        }

        var body: some View {
            Slider(value: intProxy, in: 0...47)
                .tint(Color(hex: "3DADFF"))
                .padding(.horizontal)
                .padding(.vertical, 32)
        }
    }
}

#Preview {
    WheelTimePicker(completion: { _ in })
}
