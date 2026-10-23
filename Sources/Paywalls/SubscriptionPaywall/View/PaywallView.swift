//
//  PaywallView.swift
//  onboarding-ios
//
//  Created by Claude on 11.08.26.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import StoreKit

/// A subscription (or lifetime) paywall: trial timeline (or feature list) over a plan
/// selector — or a single price card when the offering resolves to one plan — and a
/// single CTA. Hard by default: no close button, and `onUnlocked` fires only after a
/// successful purchase or restore. Pass `dismiss:` to make it a cart instead — a
/// delayed corner close and an optional named decline. Restore, Terms and Privacy
/// stay reachable in the footer, and a failed offerings fetch turns the CTA into a
/// retry so the screen can never become a dead end.
///
/// The view draws no background — it expects the host to provide one — and its text
/// is white by default, designed for dark backdrops; hosts on light backdrops set
/// `PaywallConfiguration.textColor`. App-specific copy comes in through
/// `PaywallConfiguration`.
public struct PaywallView: View {

    @State private var viewModel: PaywallViewModel
    @State private var showCloseButton: Bool
    @Environment(\.paywallCTAStyle) private var customCTAStyle
    @Namespace private var selectionNamespace
    /// The tallest plan row, which every row matches.
    @State private var planRowHeight: CGFloat = 0
    /// Haptics: a light tap as a purchase starts (success is played in
    /// `unlock()`, which the host may answer by removing this view at once).
    @State private var purchaseTaps = 0

    private let configuration: PaywallConfiguration
    private let dismiss: PaywallDismissBehavior?
    private let headerAccessory: AnyView?
    private let onUnlocked: () -> Void
    private let layer: Layer
    /// Set by `PaywallTabsView`, which owns the scroll view: the column takes
    /// this height as its minimum instead of measuring a scroll view of its own.
    private let embeddedMinHeight: CGFloat?
    private let isCurrent: Bool

    /// Which parts of the page this view draws. `PaywallTabsView` stacks one
    /// `.content` layer per tab under a single `.chrome` layer, so what every tab
    /// shares (the mark, the host's tabs, the close, the footer links) never
    /// moves or blurs while the rest is swapped. A hidden part keeps its room.
    enum Layer {
        case full
        case chrome
        case content
    }

    public init(
        viewModel: PaywallViewModel,
        configuration: PaywallConfiguration,
        dismiss: PaywallDismissBehavior? = nil,
        onUnlocked: @escaping () -> Void
    ) {
        self.init(
            viewModel: viewModel,
            configuration: configuration,
            dismiss: dismiss,
            headerAccessory: nil,
            layer: .full,
            embeddedMinHeight: nil,
            isCurrent: true,
            onUnlocked: onUnlocked
        )
    }

    /// `PaywallTabsView`'s layers. `headerAccessory` (the tabs) goes under the
    /// headline, above the feature list; `isCurrent` is false for a tab that
    /// isn't showing, which follows the selection silently.
    init(
        viewModel: PaywallViewModel,
        configuration: PaywallConfiguration,
        dismiss: PaywallDismissBehavior?,
        headerAccessory: AnyView?,
        layer: Layer,
        embeddedMinHeight: CGFloat?,
        isCurrent: Bool,
        onUnlocked: @escaping () -> Void
    ) {
        viewModel.configure(with: configuration)
        _viewModel = State(initialValue: viewModel)
        _showCloseButton = State(initialValue: (dismiss?.closeButtonDelay ?? .zero) <= .zero)
        self.configuration = configuration
        self.dismiss = dismiss
        self.headerAccessory = headerAccessory
        self.onUnlocked = onUnlocked
        self.layer = layer
        self.embeddedMinHeight = embeddedMinHeight
        self.isCurrent = isCurrent
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            content
            if restoresInCorner {
                PaywallRestoreButton(textColor: configuration.textColor, action: handleRestore)
                    .padding(.top, 16)
                    .padding(.trailing, 20)
                    .modifier(part(.chrome))
            }
            if let redeemCodeAction {
                PaywallRestoreButton(title: Text("Redeem code", bundle: .module), textColor: configuration.textColor, action: redeemCodeAction)
                    .padding(.top, 16)
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(part(.chrome))
            }
            if dismiss != nil {
                PaywallCloseButton(textColor: configuration.textColor, style: configuration.closeButtonStyle, action: handleClose)
                    .padding(.top, 16)
                    .padding(.trailing, 20)
                    .opacity(showCloseButton ? 1 : 0)
                    .allowsHitTesting(showCloseButton)
                    .animation(.easeIn(duration: 0.3), value: showCloseButton)
                    .modifier(part(.chrome))
            }
        }
        .sensoryFeedback(.selection, trigger: viewModel.selectedPlanID) { old, new in
            // The chrome layer shares a tab's model; that tab's layer gives the
            // tick. A hidden tab following the shown one's choice gives none.
            layer != .chrome && isCurrent && old != nil && old != new
        }
        // The purchase's own feel, from the layer that ran it: a light tap as
        // it starts, the error buzz when it fails (success: `unlock()`).
        .sensoryFeedback(.impact(weight: .light), trigger: purchaseTaps)
        .sensoryFeedback(.error, trigger: viewModel.purchaseError) { _, new in
            layer != .chrome && isCurrent && new != nil
        }
        .sensoryFeedback(.error, trigger: viewModel.showRestoreFailedAlert) { _, new in
            layer != .chrome && isCurrent && new
        }
        .task {
            // The chrome layer shares a tab's model; that tab's own layer loads
            // it. A hidden tab loads without counting as shown.
            guard layer != .chrome else { return }
            await viewModel.loadOfferings(shown: isCurrent)
        }
        .onChange(of: isCurrent) { _, current in
            guard current, layer != .chrome else { return }
            Task { await viewModel.markShown() }
        }
        .task {
            guard let delay = dismiss?.closeButtonDelay, delay > .zero else { return }
            try? await Task.sleep(for: delay)
            showCloseButton = true
        }
        // Restore is on the chrome layer, buying on the content layers: each
        // presents the alerts of its own actions, so none shows twice.
        .paywallAlerts(
            showRestoreFailedAlert: layer == .content ? .constant(false) : $viewModel.showRestoreFailedAlert,
            showPendingApprovalAlert: layer == .chrome ? .constant(false) : $viewModel.showPendingApprovalAlert,
            purchaseError: layer == .chrome ? .constant(nil) : $viewModel.purchaseError
        )
    }

    /// Only a hard paywall moves Restore up: a dismissible one has its close
    /// button in that corner.
    private var restoresInCorner: Bool {
        dismiss == nil && configuration.restorePlacement == .corner
    }

    /// Nil hides "Redeem code": the host did not ask for it, or the platform has
    /// no offer-code sheet.
    private var redeemCodeAction: (() -> Void)? {
        #if os(iOS)
        guard configuration.offersCodeRedemption else { return nil }
        return handleRedeemCode
        #else
        return nil
        #endif
    }

    // MARK: - Subviews

    /// Scrolls only when the content is taller than the screen. The column is
    /// given the screen's height as a minimum, so on a phone where everything
    /// fits the two spacers centre the pitch between the header and the plans
    /// and the scroll view never moves; on a short phone (iPhone SE with the
    /// trial timeline or a four-row feature list) the column takes its natural
    /// height and scrolls. Before this the column was squeezed into the screen:
    /// the headline was cut to one line, the close button rode into the status
    /// bar and the footer fell off the bottom (2026-09-09).
    ///
    /// The reassurance line ("Cancel anytime" / "No payment due now") sits
    /// under the CTA since 2.10: above the tiles it floated alone in the gap
    /// under the pitch, and it belongs next to the button it reassures about.
    @ViewBuilder
    private var content: some View {
        if let embeddedMinHeight {
            column(compact: isCompact(embeddedMinHeight))
                .modifier(PaywallShimmer(isActive: awaitsPlans))
                .frame(minHeight: embeddedMinHeight)
        } else {
            GeometryReader { geo in
                ScrollView {
                    column(compact: isCompact(geo.size.height))
                        .modifier(PaywallShimmer(isActive: awaitsPlans))
                        .frame(minHeight: geo.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
    }

    /// The store hasn't answered yet: the whole page is a shimmering
    /// skeleton, the copy that is already known included, so it reads as one
    /// screen arriving rather than tiles loading under a finished page. A
    /// failed fetch stops it (the CTA turns into Retry). Only the full layer
    /// shimmers, so a tabbed paywall's layers don't sweep twice.
    private var awaitsPlans: Bool {
        layer == .full && viewModel.plans.isEmpty && !viewModel.loadFailed
    }

    /// `configuration.compactHeight`: a screen shorter than it (an iPhone SE)
    /// gets the compact page.
    private func isCompact(_ height: CGFloat) -> Bool {
        configuration.compactHeight.map { height < $0 } ?? false
    }

    /// `compact` drops the mark and tightens every gap, so the plans and the
    /// CTA fit an iPhone SE without scrolling.
    private func column(compact: Bool) -> some View {
        let gap: CGFloat = compact ? 16 : 24
        let showsMark = configuration.headerSymbol != nil && !compact
        // With a mark the header is the tallest block on the page, so it
        // starts lower and the mark sits below the status bar rather than
        // beside the corner close.
        // Without a mark the headline clears the corner pills (close, Restore,
        // Redeem code: 30 pt at 16 from the top) by a comfortable gap; at 44
        // it sat right under them.
        let top: CGFloat = compact ? 24 : (showsMark ? 56 : 72)
        return VStack(spacing: 0) {
            if let headerGap = configuration.headerSpacing {
                Spacer(minLength: top)
                header(compact: compact)
                planContext(compact: compact)
                    .padding(.top, compact ? min(headerGap, gap) : headerGap)
            } else {
                header(compact: compact)
                    .padding(.top, top)
                Spacer(minLength: gap)
                planContext(compact: compact)
            }
            Spacer(minLength: gap)
            planSelector(compact: compact)
                .modifier(part(.content))
            ctaButton
                .modifier(part(.content))
                .padding(.top, compact ? 12 : 16)
            if let declineTitle = dismiss?.declineTitle {
                declineButton(declineTitle)
                    .modifier(part(.content))
                    .padding(.top, 12)
            }
            if showsFootnote {
                footnoteLabel
                    .modifier(part(.content))
                    .padding(.top, compact ? 10 : 14)
            }
            PaywallFooterView(
                termsURL: configuration.termsURL,
                privacyURL: configuration.privacyURL,
                textColor: configuration.textColor,
                onRestore: restoresInCorner ? nil : handleRestore,
                onRedeemCode: nil
            )
            .modifier(part(.chrome))
            .padding(.top, showsFootnote ? 6 : 14)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity)
    }

    private func part(_ part: Layer) -> PaywallPartVisibility {
        PaywallPartVisibility(isVisible: layer == .full || layer == part)
    }

    private func header(compact: Bool) -> some View {
        VStack(spacing: 0) {
            if !compact, let symbol = configuration.headerSymbol {
                PaywallMark(systemImage: symbol, tint: accent, size: configuration.headerSymbolSize ?? 96, glyphColor: configuration.headerSymbolColor)
                    .modifier(part(.chrome))
                    .padding(.bottom, 18)
            }
            Text(title)
                .font(compact ? .title.weight(.bold) : .largeTitle.weight(.bold))
                .foregroundStyle(configuration.textColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                // The column is offered exactly the screen's height; when it
                // needs a few points more, the headline was the view that gave
                // them up and dropped to one truncated line ("Откройте свой
                // пла…"). Fixed vertically, the column grows and scrolls instead.
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .modifier(part(.content))

            if let subtitle = configuration.subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(configuration.textColor.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .modifier(part(.content))
                    .padding(.top, 10)
            }

            if let headerAccessory {
                headerAccessory
                    .modifier(part(.chrome))
                    .padding(.top, compact ? 14 : 20)
            }
        }
    }

    private var title: AttributedString {
        let text = viewModel.selectedHasTrial ? (configuration.trialTitle ?? configuration.title) : configuration.title
        var title = AttributedString(text)
        if let word = configuration.titleHighlight, let range = title.range(of: word) {
            title[range].foregroundColor = accent
        }
        return title
    }

    private var accent: Color { configuration.accent ?? configuration.ctaBackground ?? .accentColor }
    private var accentForeground: Color { configuration.accentForeground ?? configuration.ctaForeground ?? .white }

    /// Both variants stay mounted and only cross-fade: the ZStack keeps the taller
    /// view's height, so switching plans never shifts the layout below.
    /// Top-aligned: the feature list is shorter than the timeline it shares this box with, and
    /// centred it floated away from the headline above it.
    private func planContext(compact: Bool) -> some View {
        ZStack(alignment: .top) {
            PaywallFeaturesView(
                features: configuration.features,
                alignment: configuration.featureAlignment,
                textColor: configuration.textColor,
                accent: accent,
                accentForeground: accentForeground,
                iconStyle: configuration.featureIconStyle,
                isCompact: compact
            )
            .opacity(showsTimeline ? 0 : 1)
            if configuration.showsTrialTimeline, let days = viewModel.trialDays {
                PaywallTimelineView(
                    trialDays: days,
                    unlockBody: configuration.trialUnlockBody,
                    trialEndBody: configuration.trialEndBody,
                    textColor: configuration.textColor,
                    accent: accent,
                    accentForeground: accentForeground,
                    iconStyle: configuration.featureIconStyle,
                    midTitle: configuration.trialMidTitle,
                    midBody: configuration.trialMidBody,
                    midIcon: configuration.trialMidIcon,
                    startTitle: configuration.trialStartTitle,
                    endTitle: configuration.trialEndTitle
                )
                .opacity(showsTimeline ? 1 : 0)
            }
        }
        .modifier(part(.content))
    }

    private var showsTimeline: Bool {
        configuration.showsTrialTimeline && viewModel.selectedHasTrial
    }

    /// A lifetime unlock has nothing to cancel and nothing due later — the
    /// subscription footnote would only sow doubt, so it disappears entirely.
    private var showsFootnote: Bool {
        if configuration.footnote == .none { return false }
        if viewModel.selectedPlan?.period == .lifetime { return false }
        if viewModel.selectedPlan == nil && configuration.expectsSinglePlan { return false }
        return true
    }

    /// Same trick as `planContext`: fonts don't interpolate, so the two labels
    /// cross-fade in a fixed-height ZStack instead of morphing one Text.
    private var footnoteLabel: some View {
        ZStack {
            // Beside the store-assurance pair the trial line takes that row's
            // look — the check, the size, the grey — so switching plans swaps
            // the words under the button, not the style.
            if configuration.showsStoreAssurance {
                // Without "· then $X": the yearly tile shows the price. Weaker
                // under App Review 3.1.2 than stating it here (Pavel's call,
                // 2026-10-23).
                HStack(spacing: 16) {
                    assurance(Text("No payment due now", bundle: .module), systemImage: "checkmark")
                    assurance(Text("Secured by App Store", bundle: .module), systemImage: "checkmark.shield")
                }
                .font(.footnote.weight(.medium))
                .foregroundStyle(configuration.textColor.opacity(0.7))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .opacity(showsTrialFootnote ? 1 : 0)
            } else {
                trialFootnote
                    .modifier(PaywallOfferFootnoteStyle(textColor: configuration.textColor, quiet: configuration.footnote == .trial))
                    .opacity(showsTrialFootnote ? 1 : 0)
            }
            // Mounted only where it can show, and never empty while mounted:
            // a hidden line of another size still sets the stack's height, and
            // one there for one plan but not the next made the page jump.
            if configuration.footnote == .offer {
                introFootnote
                    .modifier(PaywallOfferFootnoteStyle(textColor: configuration.textColor, quiet: false))
                    .opacity(showsIntroFootnote ? 1 : 0)
            }
            cancelAnytime
                .opacity(showsTrialFootnote || showsIntroFootnote ? 0 : 1)
        }
    }

    private var showsTrialFootnote: Bool {
        (configuration.footnote == .offer || configuration.footnote == .trial) && viewModel.selectedHasTrial
    }

    private var showsIntroFootnote: Bool {
        configuration.footnote == .offer && !viewModel.selectedHasTrial && viewModel.selectedIntroOffer != nil
    }

    /// "$2.99 for the first week · then $5.99/week": the paid first period and
    /// the price after it, side by side before the purchase (Guideline 3.1.2),
    /// as the trial's line does. Takes the "Cancel anytime" line's place.
    @ViewBuilder
    private var introFootnote: some View {
        if let intro = viewModel.selectedIntroOffer {
            if let then = viewModel.selectedPlan?.localizedPricePerPeriod {
                Text(verbatim: String(localized: "\(intro.terms) · then \(then)", bundle: .module))
            } else {
                Text(verbatim: intro.terms)
            }
        } else {
            Text(verbatim: " ")
        }
    }

    /// "No payment due now · then $29.99/year": what the trial turns into, on the
    /// line that reassures about the button. Guideline 3.1.2 wants the charge after
    /// a free trial stated before the purchase, and the row's price alone leaves
    /// the reader to connect the two.
    private var trialFootnote: Text {
        if let then = viewModel.selectedPlan?.localizedPricePerPeriod {
            Text("No payment due now · then \(then)", bundle: .module)
        } else {
            Text("No payment due now", bundle: .module)
        }
    }

    @ViewBuilder
    private var cancelAnytime: some View {
        if configuration.showsStoreAssurance {
            HStack(spacing: 16) {
                assurance(Text("Cancel anytime", bundle: .module), systemImage: "checkmark")
                assurance(Text("Secured by App Store", bundle: .module), systemImage: "checkmark.shield")
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(configuration.textColor.opacity(0.7))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
        } else if let plan = viewModel.selectedPlan, let lead = configuration.planFootnote?(plan) {
            // One string, not two Texts: the line has to shrink as a whole.
            Text(verbatim: "\(lead) · \(String(localized: "Cancel anytime", bundle: .module))")
                .font(.footnote.weight(.medium))
                .foregroundStyle(configuration.textColor.opacity(0.55))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .contentTransition(.opacity)
                .animation(.easeOut(duration: 0.2), value: lead)
        } else {
            Text("Cancel anytime", bundle: .module)
                .font(.footnote.weight(.medium))
                .foregroundStyle(configuration.textColor.opacity(0.55))
        }
    }

    private func assurance(_ label: Text, systemImage: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
                .foregroundStyle(configuration.storeAssuranceIconColor ?? accent)
            label
        }
    }

    @ViewBuilder
    private func planSelector(compact: Bool) -> some View {
        if let plan = viewModel.plans.first, viewModel.plans.count == 1 {
            priceCard(for: plan)
        } else if viewModel.plans.isEmpty {
            if configuration.expectsSinglePlan {
                priceCard(for: nil)
            } else if configuration.planLayout == .rows {
                VStack(spacing: Self.rowSpacing) {
                    ForEach(0..<configuration.expectedPlanCount, id: \.self) { _ in
                        placeholderRow
                    }
                }
            } else {
                HStack(spacing: 12) {
                    ForEach(0..<configuration.expectedPlanCount, id: \.self) { _ in
                        placeholderTile
                    }
                }
            }
        } else if configuration.planLayout == .rows {
            planRows(compact: compact)
        } else {
            HStack(spacing: 12) {
                ForEach(viewModel.plans) { plan in
                    PaywallPlanTile(
                        plan: plan,
                        isSelected: viewModel.isSelected(plan),
                        tag: viewModel.tag(for: plan),
                        noteStyle: configuration.planNote,
                        selectionNamespace: selectionNamespace,
                        textColor: configuration.textColor,
                        accent: accent,
                        accentForeground: accentForeground,
                        wash: configuration.planWash,
                        selectionColor: configuration.selectionColor,
                        savingsBackground: configuration.savingsTagBackground,
                        savingsForeground: configuration.savingsTagForeground,
                        popularBackground: configuration.popularTagBackground,
                        popularForeground: configuration.popularTagForeground,
                        popularTitle: configuration.popularTagTitle,
                        customTitle: configuration.planTitle?(plan),
                        selection: configuration.planSelection,
                        isCompact: viewModel.plans.count >= 3,
                        onSelect: {
                            withAnimation(.snappy(duration: 0.25)) { viewModel.selectPlan(plan) }
                        }
                    )
                }
            }
        }
    }

    /// Rows sit closer than tiles; a lower row with a tag on its top edge
    /// needs the extra room, a bare one doesn't (Pavel, 2026-10-02).
    private static let rowSpacing: CGFloat = 12
    private static let taggedRowSpacing: CGFloat = 18

    private func planRowSpacing(compact: Bool) -> CGFloat {
        if let spacing = configuration.planRowSpacing { return compact ? min(spacing, 14) : spacing }
        return viewModel.plans.dropFirst().contains { viewModel.tag(for: $0) != nil } ? Self.taggedRowSpacing : Self.rowSpacing
    }

    private func planRows(compact: Bool) -> some View {
        VStack(spacing: planRowSpacing(compact: compact)) {
            ForEach(viewModel.plans) { plan in
                PaywallPlanRow(
                    plan: plan,
                    isSelected: viewModel.isSelected(plan),
                    tag: viewModel.tag(for: plan),
                    regularPrice: viewModel.regularPrice(for: plan),
                    text: configuration.planText?(plan),
                    detail: configuration.planDetail?(plan),
                    customTitle: configuration.planTitle?(plan),
                    noteStyle: configuration.planNote,
                    priceStyle: configuration.planPriceStyle,
                    isCompact: compact,
                    selectionNamespace: selectionNamespace,
                    textColor: configuration.textColor,
                    accent: accent,
                    accentForeground: accentForeground,
                    wash: configuration.planWash,
                    selectionColor: configuration.selectionColor,
                    savingsBackground: configuration.savingsTagBackground,
                    savingsForeground: configuration.savingsTagForeground,
                    popularBackground: configuration.popularTagBackground,
                    popularForeground: configuration.popularTagForeground,
                    popularTitle: configuration.popularTagTitle,
                    selection: configuration.planSelection,
                    matchedHeight: planRowHeight,
                    onNaturalHeight: { planRowHeight = max(planRowHeight, $0) },
                    onSelect: {
                        withAnimation(.snappy(duration: 0.25)) { viewModel.selectPlan(plan) }
                    }
                )
            }
        }
    }

    private func priceCard(for plan: PaywallPlan?) -> some View {
        PaywallPriceCard(
            plan: plan,
            note: configuration.priceCardNote,
            textColor: configuration.textColor,
            background: configuration.cardBackground,
            wash: configuration.planWash
        )
    }

    private var placeholderRow: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(.ultraThinMaterial)
            .frame(height: 68)
            .opacity(0.4)
    }

    private var placeholderTile: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(.ultraThinMaterial)
            .frame(height: 112)
            .opacity(0.4)
    }

    /// The host's style from `paywallCTAButtonStyle(_:)` wins over the library slab.
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
        Button(action: handleCTA) {
            Group {
                if viewModel.isPurchasing || viewModel.isLoading || viewModel.isPendingApproval {
                    ProgressView().tint(configuration.ctaForeground ?? .white)
                } else {
                    Text(ctaTitle)
                        .contentTransition(.opacity)
                }
            }
        }
        .disabled(viewModel.isPurchasing || viewModel.isLoading || viewModel.isPendingApproval)
    }

    /// The host's CTA copy applies to the buy states; the retry state keeps the
    /// library's wording, because it is about the fetch failing rather than about
    /// what is being bought. A trial selection takes `ctaTrialTitle`; otherwise the
    /// price-bearing variant wins when the selection's price is known, so the
    /// button names the charge.
    private var ctaTitle: String {
        guard viewModel.hasOfferings else { return viewModel.ctaTitle }
        if viewModel.selectedHasTrial {
            return configuration.ctaTrialTitle ?? viewModel.ctaTitle
        }
        if viewModel.selectedIntroOffer != nil, let introTitle = configuration.ctaIntroTitle {
            return introTitle
        }
        if let withPrice = configuration.ctaTitleWithPrice, let plan = viewModel.selectedPlan {
            return withPrice(plan.localizedPrice)
        }
        return configuration.ctaTitle ?? viewModel.ctaTitle
    }

    private func declineButton(_ title: String) -> some View {
        Button(action: handleDecline) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(configuration.textColor.opacity(0.5))
                .padding(.vertical, 2)
        }
        .buttonStyle(.plain)
        // Gated on the same flag as the corner ✕ — one "you may now leave"
        // moment, expressed two ways, so the dwell isn't quietly bypassed by
        // the named action.
        .opacity(showCloseButton ? 1 : 0)
        .allowsHitTesting(showCloseButton)
        .animation(.easeIn(duration: 0.3), value: showCloseButton)
    }

    // MARK: - Actions

    /// Retries the fetch while there is nothing to buy, otherwise buys the selection.
    private func handleCTA() {
        Task {
            guard viewModel.hasOfferings else {
                return await viewModel.loadOfferings()
            }
            purchaseTaps += 1
            if await viewModel.purchase() { unlock() }
        }
    }

    #if os(iOS)
    /// StoreKit's call, not SwiftUI's `offerCodeRedemption` modifier: in 4.3 the
    /// modifier set its flag and never showed the sheet or called back, on the
    /// App Store build as in the Simulator, so the button did nothing. The call
    /// returns once the sheet is closed.
    private func handleRedeemCode() {
        viewModel.redeemCodeTapped()
        Task {
            let result: Result<Void, any Error>
            do {
                guard let scene = activeWindowScene else { throw CodeRedemptionError.noWindowScene }
                try await AppStore.presentOfferCodeRedeemSheet(in: scene)
                result = .success(())
            } catch {
                result = .failure(error)
            }
            if await viewModel.codeRedemptionFinished(result) { unlock() }
        }
    }

    private var activeWindowScene: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    }

    private enum CodeRedemptionError: Error {
        case noWindowScene
    }
    #endif

    private func handleRestore() {
        Task {
            if await viewModel.restorePurchases() { unlock() }
        }
    }

    private func unlock() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
        onUnlocked()
    }

    private func handleClose() {
        viewModel.userDismissed()
        dismiss?.onDismiss()
    }

    private func handleDecline() {
        viewModel.userDeclined()
        dismiss?.onDismiss()
    }
}

/// The trial or intro-offer line under the CTA: emphasized, or `quiet` in
/// the "Cancel anytime" line's own style.
private struct PaywallOfferFootnoteStyle: ViewModifier {
    let textColor: Color
    let quiet: Bool

    func body(content: Content) -> some View {
        content
            .font(quiet ? .footnote.weight(.medium) : .subheadline.weight(.semibold))
            .foregroundStyle(textColor.opacity(quiet ? 0.55 : 0.85))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }
}

/// A part another layer draws: it keeps its room, but shows nothing and takes
/// no touches, so the layer under or over it gets them.
private struct PaywallPartVisibility: ViewModifier {
    let isVisible: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .allowsHitTesting(isVisible)
            .accessibilityHidden(!isVisible)
    }
}

/// The loading skeleton: the content redacted into placeholder shapes, with a
/// soft band of light sweeping across them. Turns off with a short fade.
private struct PaywallShimmer: ViewModifier {
    let isActive: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .redacted(reason: isActive ? .placeholder : [])
            .overlay {
                if isActive && !reduceMotion {
                    GeometryReader { geo in
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.35), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 0.5)
                        .rotationEffect(.degrees(12))
                        .offset(x: -geo.size.width * 0.5 + phase * geo.size.width * 1.5)
                    }
                    .mask(content.redacted(reason: .placeholder))
                    .allowsHitTesting(false)
                    .transition(.opacity)
                }
            }
            .animation(.easeOut(duration: 0.3), value: isActive)
            .onAppear {
                withAnimation(.linear(duration: 1.3).repeatForever(autoreverses: false)) { phase = 1 }
            }
    }
}
