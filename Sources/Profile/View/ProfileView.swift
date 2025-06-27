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

    @Environment(\.dismiss) private var dismiss

    private var showBuySubscriptionButton: Bool
    private var appLink: String
    private var supportEmail: String
    private var termsLink: String
    private var privacyLink: String
    private var paywall: (Binding<Bool>) -> PaywallScreen
    @State private var actions: [Action]
    private var fetchSubscriptionStatus: () async throws -> Void
    private var trackEvent: (String) -> Void

    public init(
        showBuySubscriptionButton: Bool,
        appLink: String,
        supportEmail: String,
        termsLink: String,
        privacyLink: String,
        paywall: @escaping (Binding<Bool>) -> PaywallScreen = { _ in EmptyView() },
        actions: [Action] = [],
        fetchSubscriptionStatus: @escaping () async throws -> Void = {},
        trackEvent: @escaping (String) -> Void
    ) {
        self.showBuySubscriptionButton = showBuySubscriptionButton
        self.appLink = appLink
        self.supportEmail = supportEmail
        self.termsLink = termsLink
        self.privacyLink = privacyLink
        self.paywall = paywall
        self._actions = State(initialValue: actions)
        self.fetchSubscriptionStatus = fetchSubscriptionStatus
        self.trackEvent = trackEvent
    }

    public var body: some View {
        NavigationStack {
            Form {
                if !actions.isEmpty {
                    Section {
                        ForEach($actions) { action in
                            actionButton(action)
                        }
                    }
                }
                if showBuySubscriptionButton {
                    Section {
                        buySubscriptionButton
                    }
                }
                Section {
                    rateAppButton
                    shareAppButton
                    shareFeedbackButton
                }
                Section {
                    termsButton
                    privacyButton
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    closeButton
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showPaywall) {
                paywall($showPaywall)
            }
            .task {
                try? await fetchSubscriptionStatus()
            }
        }
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
        Link(destination: URL(string: "mailto:\(supportEmail)")!) {
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

    private var closeButton: some View {
        Button {
            trackEvent("close_profile_button_tapped")
            dismiss()
        } label: {
            Text("Close")
        }
        .buttonStyle(ToolbarButtonStyle())
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
