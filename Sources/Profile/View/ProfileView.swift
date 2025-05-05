//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 05.05.25.
//

import SwiftUI

public struct ProfileView<PaywallScreen>: View where PaywallScreen: View {
    @State private var showPaywall: Bool = false

    private var showBuySubscriptionButton: Bool
    private var appLink: String
    private var supportEmail: String
    private var termsLink: String
    private var privacyLink: String
    private var paywall: () -> PaywallScreen
    private var fetchSubscriptionStatus: () async throws -> Void

    public init(
        showPaywall: Bool,
        showBuySubscriptionButton: Bool,
        appLink: String,
        supportEmail: String,
        termsLink: String,
        privacyLink: String,
        paywall: @escaping () -> PaywallScreen,
        fetchSubscriptionStatus: @escaping () -> Void
    ) {
        self.showPaywall = showPaywall
        self.showBuySubscriptionButton = showBuySubscriptionButton
        self.appLink = appLink
        self.supportEmail = supportEmail
        self.termsLink = termsLink
        self.privacyLink = privacyLink
        self.paywall = paywall
        self.fetchSubscriptionStatus = fetchSubscriptionStatus
    }

    public var body: some View {
        NavigationStack {
            Form {
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
            .navigationTitle("Profile")
            .sheet(isPresented: $showPaywall) {
                paywall()
            }
            .task {
                try? await fetchSubscriptionStatus()
            }
        }
    }

    private var buySubscriptionButton: some View {
        Button {
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
        .buttonStyle(ProfileButtonStyle())
    }

    private var shareAppButton: some View {
        ShareLink(item: URL(string: appLink)!) {
            HStack(spacing: 12) {
                imageView(name: "arrowshape.turn.up.right.fill", color: .green)
                Text("Share the App")
            }
        }
        .buttonStyle(ProfileButtonStyle())
    }

    private var shareFeedbackButton: some View {
        Link(destination: URL(string: "mailto:\(supportEmail)")!) {
            HStack(spacing: 12) {
                imageView(name: "ellipsis.message.fill", color: .pink)
                Text("Leave feedback")
            }
        }
        .buttonStyle(ProfileButtonStyle())
    }

    private var termsButton: some View {
        Link(destination: URL(string: termsLink)!) {
            HStack(spacing: 12) {
                imageView(name: "book.pages.fill", color: .gray)
                Text("Terms & Conditions")
            }
        }
        .buttonStyle(ProfileButtonStyle())
    }

    private var privacyButton: some View {
        Link(destination: URL(string: privacyLink)!) {
            HStack(spacing: 12) {
                imageView(name: "book.pages.fill", color: .gray)
                Text("Privacy Policy")
            }
        }
        .buttonStyle(ProfileButtonStyle())
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
