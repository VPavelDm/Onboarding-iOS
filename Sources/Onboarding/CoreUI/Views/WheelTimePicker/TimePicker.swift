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
        @Environment(\.colorPalette) private var colorPalette
        @EnvironmentObject private var viewModel: ViewModel

        @State private var size: CGSize = .zero

        var body: some View {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    timeView("00:00").opacity(0)
                    timeView("00:00").opacity(0)
                    ForEach(viewModel.times.indices, id: \.self) { index in
                        timeView(viewModel.times[index])
                            .visualEffect { view, proxy in
                                view
                                    .offset(y: offset(proxy))
                                    .scaleEffect(scale(proxy), anchor: .bottom)
                                    .opacity(opacity(proxy))
                            }
                    }
                    timeView("00:00").opacity(0)
                    timeView("00:00").opacity(0)
                }
                .scrollTargetLayout()
            }
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
                .frame(width: timeViewBubbleSize, height: timeViewBubbleSize)
                .background(Color(hex: "3DADFF"))
                .clipShape(Circle())
                .frame(width: timeViewSize, height: timeViewSize)
                .padding(.top, (.earthHeight - timeViewSize) / 2)
        }

        nonisolated private func offset(_ proxy: GeometryProxy) -> CGFloat {
            let progress = progress(proxy)
            return progress * -.progressStep
        }

        nonisolated private func scale(_ proxy: GeometryProxy) -> CGFloat {
            let progress = progress(proxy)
            return 1 + progress * 0.25
        }

        nonisolated private func opacity(_ proxy: GeometryProxy) -> CGFloat {
            progress(proxy)
        }

        nonisolated private func progress(_ proxy: GeometryProxy) -> CGFloat {
            let screenWidth = proxy.bounds(of: .scrollView)?.width ?? .zero
            let midX = proxy.frame(in: .scrollView).midX
            return 1 - abs(midX - screenWidth / 2) / screenWidth * 2
        }

        var timeViewSize: CGFloat {
            size.width / 5
        }

        var timeViewBubbleSize: CGFloat {
            max(timeViewSize - 16, 0)
        }
    }
}
