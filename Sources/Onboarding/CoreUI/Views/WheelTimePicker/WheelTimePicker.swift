//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 19.09.24.
//

import SwiftUI

@available(iOS 17.0, *)
struct WheelTimePicker: View {

    @StateObject private var viewModel = ViewModel()
    @State private var selectedTimeIndex: Int?

    var body: some View {
        VStack(spacing: 0) {
            timeView
                .frame(maxHeight: .infinity)
            HouseView(selectedTimeIndex: $selectedTimeIndex, viewModel: viewModel)
            ZStack {
                EarthShape()
                    .fill(Color(hex: "2A2663"))
                    .frame(maxHeight: .earthHeight)
                TimePicker(selectedTimeIndex: $selectedTimeIndex)
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .background(Color(hex: "1F1B4E"))
        .environmentObject(viewModel)
    }

    private var timeView: some View {
        Text(viewModel.times[selectedTimeIndex ?? 0])
            .foregroundStyle(.white)
            .font(.system(size: 84, weight: .bold))
            .contentTransition(.numericText())
            .animation(.easeInOut, value: selectedTimeIndex)
            .monospaced()
    }
}

// MARK: - Constants

extension CGFloat {

    static let circleSize: CGFloat = 60
    static let earthHeight: CGFloat = 200
    static let progressStep: CGFloat = 30
    static let dayNightRadius: CGFloat = 120
    static let homeSize: CGFloat = 100
}

// MARK: - Preview

#Preview {
    if #available(iOS 17.0, *) {
        WheelTimePicker()
    } else {
        Text("iOS 16")
    }
}
