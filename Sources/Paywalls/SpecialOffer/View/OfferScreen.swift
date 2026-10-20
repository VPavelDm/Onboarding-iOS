//
//  OfferScreen.swift
//  onboarding-ios
//
//  Created by Claude on 20.10.26.
//

import SwiftUI

/// The special offer: the host's artwork across the top fading into the
/// page, a badge, the percent off in display type, a live clock, the price
/// struck through against the offer's, what it comes to a day, and one CTA.
/// The corner close works at once: the clock already says the price is
/// temporary. Unlock (a purchase or a restore) leaves through `onUnlocked`;
/// the close, the clock reaching zero and a placement with no plan through
/// `onDismiss`. Neither fires twice.
///
/// The view draws its own background (`OfferConfiguration.backgroundColor`),
/// so it can be presented as a cover on its own. The CTA takes the host's
/// `paywallCTAButtonStyle(_:)` when one is in the environment.
public struct OfferScreen: View {
    private let viewModel: OfferViewModel
    private let onUnlocked: () -> Void
    private let onDismiss: () -> Void

    @Environment(\.paywallCTAStyle) private var customCTAStyle

    public init(viewModel: OfferViewModel, onUnlocked: @escaping () -> Void = {}, onDismiss: @escaping () -> Void = {}) {
        self.viewModel = viewModel
        self.onUnlocked = onUnlocked
        self.onDismiss = onDismiss
    }

    private var configuration: OfferConfiguration { viewModel.configuration }
    private var textColor: Color { configuration.textColor }
    private var accent: Color { configuration.resolvedAccent }
    private var ground: Color { configuration.backgroundColor }

    public var body: some View {
        GeometryReader { geo in
            let compact = configuration.compactHeight.map { geo.size.height < $0 } ?? false
            ZStack(alignment: .bottom) {
                artwork(size: geo.size)
                content(compact: compact)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .background(ground.ignoresSafeArea())
        .overlay(alignment: .topTrailing) { closeButton }
        .alert(
            Text(verbatim: viewModel.alert.map(viewModel.message(for:)) ?? ""),
            isPresented: Binding(get: { viewModel.alert != nil }, set: { if !$0 { viewModel.alert = nil } }),
            actions: { Button(action: {}) { Text("OK", bundle: .module) } }
        )
        // Keyed to the model: should a host hand over a new one, it loads too.
        .task(id: ObjectIdentifier(viewModel)) {
            if await !viewModel.onAppear() {
                onDismiss()
            }
        }
    }

    // MARK: - Artwork

    /// The picture filling the top two thirds, fading into the page so the
    /// copy reads over its lower edge.
    @ViewBuilder
    private func artwork(size: CGSize) -> some View {
        if let image = configuration.artwork {
            let height = size.height * 0.72
            VStack(spacing: 0) {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.width, height: height, alignment: .top)
                    .clipped()
                    .overlay {
                        LinearGradient(
                            stops: [
                                .init(color: ground.opacity(0), location: 0.35),
                                .init(color: ground.opacity(0.85), location: 0.78),
                                .init(color: ground, location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                Spacer(minLength: 0)
            }
            .ignoresSafeArea(edges: .top)
            .accessibilityHidden(true)
        }
    }

    // MARK: - Content

    /// The plan has landed; until then its figures shimmer in place.
    private var isLoaded: Bool { viewModel.plan != nil }

    private func content(compact: Bool) -> some View {
        VStack(spacing: 0) {
            badge
            Text(verbatim: "\(viewModel.percentOff ?? 50)%")
                .font(.system(size: compact ? 76 : 96, weight: .heavy, design: .rounded))
                .foregroundStyle(accent)
                .shadow(color: accent.opacity(isLoaded ? 0.25 : 0), radius: 20)
                .offerLoadingPlaceholder(isLoaded, color: accent.opacity(0.3), widthFraction: 0.75, heightFraction: 0.62)
                .padding(.top, compact ? 8 : 14)
            Text(verbatim: configuration.offTitle)
                .font(.system(size: compact ? 36 : 44, weight: .heavy, design: .rounded))
                .foregroundStyle(textColor)
                .padding(.top, compact ? -10 : -14)
            countdown
                .padding(.top, compact ? 12 : 16)
            priceLines
                .padding(.top, compact ? 12 : 16)
            if let note = configuration.renewalNote {
                Text(verbatim: note)
                    .font(.footnote)
                    .foregroundStyle(textColor.opacity(0.55))
                    .padding(.top, compact ? 14 : 18)
            }
            ctaButton
                .padding(.top, 12)
            PaywallFooterView(
                termsURL: configuration.termsURL,
                privacyURL: configuration.privacyURL,
                textColor: textColor,
                onRestore: handleRestore
            )
            .padding(.top, 2)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    private var badge: some View {
        HStack(spacing: 6) {
            if let symbol = configuration.badgeSymbol {
                Image(systemName: symbol)
            }
            Text(verbatim: configuration.badgeTitle)
                .tracking(1.2)
        }
        .font(.footnote.weight(.bold))
        .foregroundStyle(accent)
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(Capsule().fill(accent.opacity(0.14)))
        .overlay(Capsule().strokeBorder(accent.opacity(0.4), lineWidth: 1))
    }

    /// Redrawn once a second; ends the offer on the tick that reaches zero.
    private var countdown: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            HStack(spacing: 6) {
                Image(systemName: "timer")
                Text(verbatim: viewModel.endsInLabel(at: context.date))
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: true))
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(accent)
            .onChange(of: viewModel.isExpired(at: context.date)) { _, expired in
                if expired, viewModel.expire() { onDismiss() }
            }
        }
    }

    /// "Just ~~$59.99~~ **$29.99** per year" over "(less than **$0.09** per day)".
    /// Kept in place while the plan loads, so nothing jumps when it lands.
    private var priceLines: some View {
        VStack(spacing: 4) {
            Text(priceLine ?? AttributedString("Just $00.00 $00.00 per year"))
                .offerLoadingPlaceholder(isLoaded, color: textColor.opacity(0.22), widthFraction: 0.8)
            if configuration.perDayTemplate != nil {
                Text(perDayLine ?? AttributedString("(less than $0.00 per day)"))
                    .offerLoadingPlaceholder(isLoaded, color: textColor.opacity(0.22), widthFraction: 0.6)
            }
        }
        .font(.title3)
        .foregroundStyle(textColor)
        .minimumScaleFactor(0.8)
        .lineLimit(1)
        .animation(.easeOut(duration: 0.35), value: isLoaded)
    }

    private var priceLine: AttributedString? {
        guard let template = viewModel.priceLineTemplate,
              let old = viewModel.regularPriceLabel,
              let new = viewModel.priceLabel else { return nil }
        return Self.fill(template, [
            "{old}": { run in
                run.append(AttributedString(old))
                run.strikethroughStyle = .single
                run.foregroundColor = textColor.opacity(0.55)
            },
            "{new}": { run in
                run.append(AttributedString(new))
                run.font = .title3.bold()
            }
        ])
    }

    private var perDayLine: AttributedString? {
        guard let template = configuration.perDayTemplate, let perDay = viewModel.perDayLabel else { return nil }
        return Self.fill(template, [
            "{price}": { run in
                run.append(AttributedString(perDay))
                run.font = .title3.bold()
                run.foregroundColor = accent
            }
        ])
    }

    /// The template with each placeholder replaced by its styled run, in
    /// whatever order the language puts them.
    private static func fill(_ template: String, _ tokens: [String: (inout AttributedString) -> Void]) -> AttributedString {
        var result = AttributedString()
        var rest = Substring(template)
        while let (token, range) = tokens.keys.compactMap({ key in rest.range(of: key).map { (key, $0) } })
            .min(by: { $0.1.lowerBound < $1.1.lowerBound }) {
            result.append(AttributedString(String(rest[..<range.lowerBound])))
            var run = AttributedString()
            tokens[token]?(&run)
            result.append(run)
            rest = rest[range.upperBound...]
        }
        result.append(AttributedString(String(rest)))
        return result
    }

    /// The host's style from `paywallCTAButtonStyle(_:)` wins over the package slab.
    @ViewBuilder
    private var ctaButton: some View {
        if let customCTAStyle {
            customCTAStyle.apply(to: ctaBaseButton)
        } else {
            ctaBaseButton.buttonStyle(PaywallCTAButtonStyle(
                background: configuration.ctaBackground,
                foreground: configuration.ctaForeground
            ))
        }
    }

    private var ctaBaseButton: some View {
        Button {
            Task { if await viewModel.purchase() { onUnlocked() } }
        } label: {
            ZStack {
                ProgressView()
                    .tint(configuration.ctaForeground ?? .primary)
                    .opacity(viewModel.phase == .purchasing ? 1 : 0)
                HStack(spacing: 8) {
                    Text(verbatim: viewModel.ctaTitle)
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.bold))
                }
                .opacity(viewModel.phase == .purchasing ? 0 : 1)
            }
        }
        .disabled(!viewModel.canPurchase)
        .animation(.easeOut(duration: 0.2), value: viewModel.phase)
    }

    private var closeButton: some View {
        PaywallCloseButton(textColor: textColor, style: configuration.closeButtonStyle) {
            if viewModel.decline() { onDismiss() }
        }
        .disabled(viewModel.phase == .purchasing)
        .padding(.top, 8)
        .padding(.trailing, 16)
        .accessibilityLabel(Text("Close", bundle: .module))
    }

    private func handleRestore() {
        Task { if await viewModel.restore() { onUnlocked() } }
    }
}

private extension View {
    /// Until `loaded`, the text keeps its room but hides behind a shimmering
    /// rounded bar a share of its size, so nothing moves when the figure lands;
    /// then the two crossfade.
    func offerLoadingPlaceholder(_ loaded: Bool, color: Color, widthFraction: CGFloat, heightFraction: CGFloat = 0.6) -> some View {
        // The layout text swaps for the real one at once, while still hidden;
        // crossfading the two strings showed "$00.00" through the price.
        contentTransition(.identity)
            .opacity(loaded ? 1 : 0)
            .overlay {
                GeometryReader { proxy in
                    Capsule()
                        .fill(color)
                        .frame(width: proxy.size.width * widthFraction, height: proxy.size.height * heightFraction)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .modifier(OfferShimmerModifier())
                .opacity(loaded ? 0 : 1)
                .allowsHitTesting(false)
            }
            .animation(.easeOut(duration: 0.35), value: loaded)
    }
}

/// Dims the receiver and sweeps a band of full strength across it, left to
/// right, for a placeholder standing in for a figure that is still loading.
private struct OfferShimmerModifier: ViewModifier {
    var restingOpacity: Double = 0.5

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isSweeping = false

    func body(content: Content) -> some View {
        if reduceMotion {
            content.opacity(restingOpacity)
        } else {
            content
                .mask { mask }
                .onAppear { isSweeping = true }
        }
    }

    private var mask: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack(alignment: .leading) {
                Color.black.opacity(restingOpacity)
                LinearGradient(
                    colors: [.black.opacity(0), .black, .black.opacity(0)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: width * 0.6)
                .offset(x: isSweeping ? width : -width * 0.6)
                .animation(.linear(duration: 1.4).delay(0.25).repeatForever(autoreverses: false), value: isSweeping)
            }
        }
    }
}
