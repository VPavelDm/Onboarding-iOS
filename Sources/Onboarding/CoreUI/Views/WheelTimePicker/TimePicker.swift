//
//  File.swift
//
//
//  Created by Pavel Vaitsikhouski on 19.09.24.
//

import SwiftUI

@available(iOS 17.0, *)
extension WheelTimePicker {

    struct TimePicker: View {
        @EnvironmentObject private var viewModel: ViewModel

        @State private var size: CGSize = .zero

        var body: some View {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(values.hiddenBubbles(in: size), id: \.self) { _ in
                        timeView("00:00").opacity(0)
                    }
                    ForEach(viewModel.times.indices, id: \.self) { index in
                        timeView(viewModel.times[index])
                            .visualEffect { view, proxy in
                                view
                                    .offset(y: values.offset(proxy))
                                    .scaleEffect(values.scale(proxy), anchor: .bottom)
                                    .opacity(values.opacity(proxy))
                            }
                    }
                    ForEach(values.hiddenBubbles(in: size), id: \.self) { _ in
                        timeView("00:00").opacity(0)
                    }
                }
                .scrollTargetLayout()
            }
            .sensoryFeedback(.selection, trigger: viewModel.selectedTimeIndex)
            .scrollPosition(id: $viewModel.selectedTimeIndex, anchor: .center)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .frame(height: .earthHeight)
            .readSize(size: $size)
        }

        private func timeView(_ time: String) -> some View {
            Text(time)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: values.timeViewBubbleSize(in: size), height: values.timeViewBubbleSize(in: size))
                .background(Color(hex: "4743A3"))
                .clipShape(Circle())
                .frame(width: values.timeViewSize(in: size), height: values.timeViewSize(in: size))
                .padding(.top, (.earthHeight - values.timeViewSize(in: size)) / 2)
        }

        nonisolated var values: TimePickerValues {
            TimePickerValues()
        }
    }
}

#Preview {
    WheelTimePicker(step: .testData(), completion: { _ in })
}
