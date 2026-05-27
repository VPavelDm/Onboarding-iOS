//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 05.05.25.
//

import SwiftUI
import CoreUI

public struct ProfileView<PaywallScreen>: View where PaywallScreen: View {
    @State private var showPaywall: Bool = false

    private var showBuySubscriptionButton: Bool
    private var appLink: String
    private var supportEmail: String
    private var supportSubject: String
    private var termsLink: String
    private var privacyLink: String
    private var paywall: (Binding<Bool>) -> PaywallScreen
    @State private var actions: [Action]
    private var fetchSubscriptionStatus: () async throws -> Void
    private var trackEvent: (String) -> Void
    private var rowTint: Color

    public init(
        showBuySubscriptionButton: Bool,
        appLink: String,
        supportEmail: String,
        supportSubject: String,
        termsLink: String,
        privacyLink: String,
        paywall: @escaping (Binding<Bool>) -> PaywallScreen = { _ in EmptyView() },
        actions: [Action] = [],
        fetchSubscriptionStatus: @escaping () async throws -> Void = {},
        trackEvent: @escaping (String) -> Void,
        rowTint: Color = .gray
    ) {
        self.showBuySubscriptionButton = showBuySubscriptionButton
        self.appLink = appLink
        self.supportEmail = supportEmail
        self.supportSubject = supportSubject
        self.termsLink = termsLink
        self.privacyLink = privacyLink
        self.paywall = paywall
        self._actions = State(initialValue: actions)
        self.fetchSubscriptionStatus = fetchSubscriptionStatus
        self.trackEvent = trackEvent
        self.rowTint = rowTint
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if !actions.isEmpty {
                    sectionStack {
                        ForEach(actions.indices, id: \.self) { index in
                            actionButton($actions[index])
                            if index < actions.count - 1 {
                                rowDivider
                            }
                        }
                    }
                }
                if showBuySubscriptionButton {
                    sectionStack {
                        buySubscriptionButton
                    }
                }
                sectionStack {
                    rateAppButton
                    rowDivider
                    shareAppButton
                    rowDivider
                    shareFeedbackButton
                }
                sectionStack {
                    termsButton
                    rowDivider
                    privacyButton
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .sheet(isPresented: $showPaywall) {
            paywall($showPaywall)
        }
        .task {
            try? await fetchSubscriptionStatus()
        }
    }

    @ViewBuilder
    private func sectionStack<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(rowTint.opacity(0.18), in: .rect(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(rowTint.opacity(0.30)))
    }

    private var rowDivider: some View {
        rowTint
            .opacity(0.30)
            .frame(height: 1)
            .padding(.leading, 16)
    }

    private var buySubscriptionButton: some View {
        Button {
            trackEvent("buy_subscription_button_tapped")
            showPaywall = true
        } label: {
            HStack(spacing: 12) {
                imageView(name: "gift.fill", color: .blue)
                Text("Buy Subscription")
            }
        }
        .buttonStyle(ProfileButtonStyle())
    }

    private var rateAppButton: some View {
        Link(destination: URL(string: appLink)!) {
            HStack(spacing: 12) {
                imageView(name: "star.fill", color: .orange)
                Text("Rate the App")
            }
        }
        .simultaneousGesture(TapGesture().onEnded {
            trackEvent("rate_app_button_tapped")
        })
        .buttonStyle(ProfileButtonStyle())
    }

    private var shareAppButton: some View {
        ShareLink(item: URL(string: appLink)!) {
            HStack(spacing: 12) {
                imageView(name: "arrowshape.turn.up.right.fill", color: .green)
                Text("Share the App")
            }
        }
        .simultaneousGesture(TapGesture().onEnded {
            trackEvent("share_app_button_tapped")
        })
        .buttonStyle(ProfileButtonStyle())
    }

    private var shareFeedbackButton: some View {
        Link(destination: URL(string: "mailto:\(supportEmail)?subject=\(supportSubject)")!) {
            HStack(spacing: 12) {
                imageView(name: "ellipsis.message.fill", color: .pink)
                Text("Leave feedback")
            }
        }
        .simultaneousGesture(TapGesture().onEnded {
            trackEvent("leave_feedback_button_tapped")
        })
        .buttonStyle(ProfileButtonStyle())
    }

    private var termsButton: some View {
        Link(destination: URL(string: termsLink)!) {
            HStack(spacing: 12) {
                imageView(name: "book.pages.fill", color: .gray)
                Text("Terms & Conditions")
            }
        }
        .simultaneousGesture(TapGesture().onEnded {
            trackEvent("terms_and_conditions_button_tapped")
        })
        .buttonStyle(ProfileButtonStyle())
    }

    private var privacyButton: some View {
        Link(destination: URL(string: privacyLink)!) {
            HStack(spacing: 12) {
                imageView(name: "book.pages.fill", color: .gray)
                Text("Privacy Policy")
            }
        }
        .simultaneousGesture(TapGesture().onEnded {
            trackEvent("privacy_policy_button_tapped")
        })
        .buttonStyle(ProfileButtonStyle())
    }

    private func actionButton(_ action: Binding<Action>) -> some View {
        Button {
            action.wrappedValue.isPresented = true
        } label: {
            HStack(spacing: 12) {
                imageView(name: action.wrappedValue.image, color: action.wrappedValue.color)
                Text(action.wrappedValue.title)
            }
        }
        .buttonStyle(ProfileButtonStyle())
        .sheet(isPresented: action.isPresented) {
            action.wrappedValue.action()
        }
    }

    func imageView(name: String, color: Color) -> some View {
        Image(systemName: name)
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
            )
    }
}
