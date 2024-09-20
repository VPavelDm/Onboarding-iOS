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
                LazyHStack(spacing: 30) {
                    ForEach(viewModel.times.indices, id: \.self) { index in
                        timeView(viewModel.times[index])
                            .visualEffect { view, proxy in
                                view
                                    .offset(y: offset(proxy))
                                    .scaleEffect(scale(proxy), anchor: .bottom)
                                    .opacity(opacity(proxy))
                            }
                    }
                }
                .frame(height: .earthHeight)
                .offset(y: .progressStep * 1.25)
                .scrollTargetLayout()
                .safeAreaPadding(.horizontal, size.width / 2 - .circleSize / 2)
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $viewModel.selectedTimeIndex, anchor: .center)
            .readSize(size: $size)
        }

        private func timeView(_ time: String) -> some View {
            Text(time)
                .multilineTextAlignment(.center)
                .foregroundStyle(colorPalette.primaryTextColor)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: .circleSize, height: .circleSize)
                .background(colorPalette.primaryButtonBackgroundColor)
                .clipShape(Circle())
        }

        nonisolated private func offset(_ proxy: GeometryProxy) -> CGFloat {
            let progress = progress(proxy)
            return progress * -.progressStep
        }

        nonisolated private func scale(_ proxy: GeometryProxy) -> CGFloat {
            let progress = progress(proxy)
            return 1 + progress * 0.5
        }

        nonisolated private func opacity(_ proxy: GeometryProxy) -> CGFloat {
            progress(proxy)
        }

        nonisolated private func progress(_ proxy: GeometryProxy) -> CGFloat {
            let screenWidth = proxy.bounds(of: .scrollView)?.width ?? .zero
            let midX = proxy.frame(in: .scrollView).midX
            return 1 - abs(midX - screenWidth / 2) / screenWidth * 2
        }

    }
}
