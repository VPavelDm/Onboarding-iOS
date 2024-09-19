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

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                titleView
                timeView
            }
            .frame(maxHeight: .infinity)
            HouseView(viewModel: viewModel)
            ZStack {
                EarthShape()
                    .fill(Color.ground)
                    .frame(maxHeight: .earthHeight)
                TimePicker()
            }
            continueButton
        }
        .background(
            viewModel.backgroundColor
                .ignoresSafeArea()
                .animation(.linear, value: viewModel.selectedTimeIndex)
        )
        .environmentObject(viewModel)
    }

    private var titleView: some View {
        Text("When do you plan to study?")
            .foregroundStyle(.white)
            .font(.system(size: 16, weight: .semibold))
    }

    private var timeView: some View {
        Text(viewModel.currentTime)
            .foregroundStyle(.white)
            .font(.system(size: 84, weight: .bold))
            .contentTransition(.numericText())
            .animation(.easeInOut, value: viewModel.selectedTimeIndex)
            .monospaced()
            .multilineTextAlignment(.center)
    }

    private var continueButton: some View {
        Button {} label: {
            Text("Continue")
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding([.horizontal, .bottom])
        .background(Color.ground)
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

extension Color {

    static let ground: Color = Color(hex: "2A2663")
    static let sun: Color = Color(hex: "FAFF0E")
}

// MARK: - Preview

#Preview {
    if #available(iOS 17.0, *) {
        WheelTimePicker()
    } else {
        Text("iOS 16")
    }
}
