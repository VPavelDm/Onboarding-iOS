//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 24.12.24.
//

import SwiftUI
import Combine

struct CountdownClockView: View {

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var timeComponents: [DiscountProduct.TimeComponent]
    @State private var isRedacted: Bool = true
    @Binding var discount: DiscountProduct.Discount

    init(discount: Binding<DiscountProduct.Discount>) {
        self._discount = discount
        self._timeComponents = State(initialValue: discount.wrappedValue.timeComponents)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 4) {
            ForEach(timeComponents.indices, id: \.self) { index in
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        ForEach(timeComponents[index].digits.indices, id: \.self) { dIndex in
                            CardView(text: "\(timeComponents[index].digits[dIndex])")
                                .redacted(reason: .placeholder, if: isRedacted)
                        }
                    }
                    labelView(timeComponents[index].label)
                }
                if index < timeComponents.count - 1 {
                    dotsView
                }
            }
        }
        .onReceive(timer) { _ in
            guard Date.now <= discount.expirationDate else { return }
            timeComponents = discount.timeComponents
            isRedacted = false
        }
    }

    private var dotsView: some View {
        VStack(spacing: 2) {
            Circle()
                .frame(width: 4, height: 4)
                .foregroundStyle(Color.secondary)
            Circle()
                .frame(width: 4, height: 4)
                .foregroundStyle(Color.secondary)
        }
        .padding(.top, 11)
    }

    private func labelView(_ value: String) -> some View {
        Text(value)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.secondary)
    }
}

private extension CountdownClockView {

    struct CardView: View {

        var text: String

        var body: some View {
            Text(text)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.primary)
                .animation(.easeInOut, value: text)
                .contentTransition(.numericText(countsDown: true))
                .frame(width: 24, height: 32)
                .clipped()
                .background(Color(uiColor: .systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}
