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
    @State private var selectedTimeIndex: Int?

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            timeView
            Spacer()
            HouseView(selectedTimeIndex: $selectedTimeIndex, viewModel: viewModel)
            ZStack {
                EarthShape()
                    .fill(Color(hex: "2A2663"))
                    .frame(maxHeight: .earthHeight)
                timeScrollView
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .background(Color(hex: "1F1B4E"))
    }

    private var timeView: some View {
        Text(viewModel.times[selectedTimeIndex ?? 0])
            .foregroundStyle(.white)
            .font(.system(size: 84, weight: .bold))
            .contentTransition(.numericText())
            .animation(.easeInOut, value: selectedTimeIndex)
            .monospaced()
    }

    private var timeScrollView: some View {
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
        .scrollPosition(id: $selectedTimeIndex, anchor: .center)
        .readSize(size: $size)
        .onAppear {
            selectedTimeIndex = 20
        }
    }

    private func timeView(_ time: String) -> some View {
        Text(time)
            .multilineTextAlignment(.center)
            .foregroundStyle(.white)
            .font(.system(size: 14, weight: .semibold))
            .frame(width: .circleSize, height: .circleSize)
            .background(Color(hex: "3DADFF"))
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

// MARK: - View Model

@available(iOS 17.0, *)
private extension WheelTimePicker {

    @MainActor
    final class ViewModel: ObservableObject {

        // MARK: - Outputs

        @Published var times: [String] = []

        // MARK: - Properties

        private let calendar = Calendar.current

        private let dateFormatter: DateFormatter = {
            let locale = Locale.current

            let dateFormatter = DateFormatter()
            dateFormatter.locale = locale

            if locale.is24TimeFormat {
                dateFormatter.dateStyle = .none
                dateFormatter.timeStyle = .short
            } else {
                dateFormatter.dateFormat = "hh:mm\na"
            }

            return dateFormatter
        }()

        // MARK: - Inits

        init() {
            initialiseTimes()
        }

        // MARK: - Intents

        func isDay(selectedTimeIndex: Int?) -> Bool {
            guard let selectedTimeIndex else { return true }
            let time = times[selectedTimeIndex]

            guard let date = dateFormatter.date(from: time) else {
                return true
            }
            guard let dayTimeStart = calendar.date(bySettingHour: 4, minute: 0, second: 0, of: date) else {
                return true
            }
            guard let dayTimeEnd = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: date) else {
                return false
            }

            return dayTimeStart <= date && date <= dayTimeEnd
        }


        // MARK: - Utils

        private func initialiseTimes() {
            var times: [String] = []

            let midnight = calendar.startOfDay(for: Date())

            for hour in 0..<24 {
                for minute in stride(from: 0, to: 60, by: 30) {
                    guard let time = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: midnight) else {
                        continue
                    }
                    let formattedTime = dateFormatter.string(from: time)
                    times.append(formattedTime)
                }
            }

            self.times = times
        }
    }
}

// MARK: - Earth Shape

@available(iOS 17.0, *)
private extension WheelTimePicker {

    struct EarthShape: Shape {

        func path(in rect: CGRect) -> Path {
            var path = Path()

            let height: CGFloat = rect.height * 0.15

            path.move(to: CGPoint(x: rect.minX, y: height))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: height),
                control: CGPoint(x: rect.midX, y: -height)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()

            return path
        }
    }
}

// MARK: - House

@available(iOS 17.0, *)
private extension WheelTimePicker {

    struct HouseView: View {
        @Binding var selectedTimeIndex: Int?
        @ObservedObject var viewModel: ViewModel
        @State private var currentAngle: Angle = .degrees(0)

        var body: some View {
            ZStack {
                homeView
                moonSunView
            }
            .offset(y: .dayNightRadius - .homeSize / 2 + 5)
            .onAppear {
                currentAngle = .degrees(360)
            }
        }

        private var homeView: some View {
            Image("home", bundle: Bundle.module)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.white)
                .frame(width: .homeSize, height: .homeSize)
        }

        private var moonSunView: some View {
            VStack {
                moonView
                Spacer()
                sunView
            }
            .frame(maxHeight: .dayNightRadius * 2)
            .rotationEffect(currentAngle)
            .animation(.linear(duration: 5).repeatForever(autoreverses: false), value: currentAngle)
        }

        private var moonView: some View {
            Image(systemName: "moon.fill")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.yellow)
                .frame(width: 32, height: 32)
        }

        private var sunView: some View {
            Image(systemName: "sun.min.fill")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.yellow)
                .frame(width: 32, height: 32)
        }
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
