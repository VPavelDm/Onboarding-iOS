//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 19.09.24.
//

import SwiftUI
import CoreUI

struct WheelTimePicker: View {

    @StateObject private var viewModel = ViewModel()

    var step: TimePickerStep
    var completion: (String) async -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                titleView
                timeView
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            HouseView(viewModel: viewModel)
                .layoutPriority(2)
            ZStack(alignment: .bottom) {
                EarthShape()
                    .fill(Color.ground)
                    .frame(maxHeight: .earthHeight)
                if #available(iOS 17.0, *) {
                    TimePicker()
                } else {
                    TimePickerIOS16()
                }
            }
            .layoutPriority(1)
            continueButton
        }
        .background(
            viewModel.backgroundColor
                .ignoresSafeArea()
                .animation(.linear, value: viewModel.selectedTimeIndex)
        )
        .onAppear {
            viewModel.selectedTimeIndex = 20
        }
        .environmentObject(viewModel)
    }

    private var titleView: some View {
        Text(step.title)
            .foregroundStyle(.white)
            .font(.system(size: 16, weight: .semibold))
    }

    private var timeView: some View {
        Text(viewModel.currentTime)
            .foregroundStyle(.white)
            .font(.system(size: 84, weight: .bold))
            .contentTransition(.numericText())
            .monospaced()
            .multilineTextAlignment(.center)
            .animation(.easeInOut, value: viewModel.selectedTimeIndex)
    }

    private var continueButton: some View {
        AsyncButton {
            await completion(viewModel.currentTime)
        } label: {
            Text(step.answer.title)
        }
        .buttonStyle(TimePickerButtonStyle())
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
    WheelTimePicker(step: .testData(), completion: { _ in })
}
