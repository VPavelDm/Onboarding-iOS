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
    @State private var size: CGSize = .zero
    @State private var activeIndex: Int?

    var body: some View {
        VStack {
            ZStack {
                EarthShape()
                    .frame(maxHeight: .earthHeight)
                timeScrollView
            }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea(.container, edges: .bottom)
    }

    private var timeScrollView: some View {
        ScrollViewReader { reader in
            ScrollView(.horizontal) {
                HStack(spacing: 30) {
                    ForEach(viewModel.times.indices, id: \.self) { index in
                        Button {
                            print("LOG: click - \(index)")
                            withAnimation {
                                reader.scrollTo(index, anchor: .center)
                            }
                        } label: {
                            timeView(viewModel.times[index])
                        }
                        .buttonStyle(PlainButtonStyle())
                        .id(index)
                        .visualEffect { view, proxy in
                            view
                                .offset(y: offset(proxy))
                                .scaleEffect(scale(proxy), anchor: .bottom)
                        }
                    }
                }
                .frame(height: .earthHeight)
                .offset(y: -.progressStep)
                .scrollTargetLayout()
                .padding(.horizontal, size.width / 2 - .circleSize / 2)
            }
            .coordinateSpace(name: "scrollView")
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $activeIndex)
            .readSize(size: $size)
            .onAppear {
                reader.scrollTo(5)
            }
        }
    }

    private func timeView(_ time: String) -> some View {
        Text(time)
            .multilineTextAlignment(.center)
            .foregroundStyle(.white)
            .font(.system(size: 14, weight: .semibold))
            .frame(width: .circleSize, height: .circleSize)
            .background(Color.red)
            .clipShape(Circle())
    }

    nonisolated private func offset(_ proxy: GeometryProxy) -> CGFloat {
        let progress = progress(proxy)
        return max(abs(progress), 0.6) * .progressStep
    }

    nonisolated private func scale(_ proxy: GeometryProxy) -> CGFloat {
        let progress = progress(proxy)
        return max(1.5 - abs(progress), 1)
    }

    nonisolated private func progress(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.bounds(of: .scrollView)?.minX ?? 0
        print("LOG: \(proxy.frame(in: .scrollView))")
        return minX / proxy.size.width
    }
}

// MARK: - Constants

extension CGFloat {

    static let circleSize: CGFloat = 60
    static let earthHeight: CGFloat = 200
    static let progressStep: CGFloat = 30
}

// MARK: - View Model

@available(iOS 17.0, *)
private extension WheelTimePicker {

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var times: [String]

        init() {
            var times: [String] = []

            let calendar = Calendar.current
            let locale = Locale(languageCode: .english, languageRegion: .unitedStates)
            let dateFormatter = DateFormatter()

            if locale.is24TimeFormat {
                dateFormatter.dateStyle = .none
                dateFormatter.timeStyle = .short
            } else {
                dateFormatter.dateFormat = "hh:mm\na"
            }

            dateFormatter.locale = locale

            let midnight = calendar.startOfDay(for: Date())

            for hour in 0..<1 {
                for minute in stride(from: 0, to: 60, by: 60) {
                    guard let time = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: midnight) else {
                        continue
                    }
                    let formattedTime = dateFormatter.string(from: time)
                    times.append(formattedTime)
                }
            }

            self._times = Published(initialValue: times)
        }
    }
}

// MARK: - Earth Shape

@available(iOS 17.0, *)
private extension WheelTimePicker {

    struct EarthShape: Shape {

        func path(in rect: CGRect) -> Path {
            var path = Path()

            let startingHeight = rect.height * 0.3

            path.move(to: CGPoint(x: rect.minX - startingHeight / 3, y: startingHeight))
            path.addCurve(
                to: CGPoint(x: rect.maxX + startingHeight / 3, y: startingHeight),
                control1: CGPoint(x: rect.minX, y: rect.minY),
                control2: CGPoint(x: rect.maxX, y: rect.minY)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()

            return path
        }
    }
}

// MARK: - Preview

#Preview {
    if #available(iOS 17.0, *) {
        WheelTimePicker()
    } else {
        Text("iOS 16")
    }
}
