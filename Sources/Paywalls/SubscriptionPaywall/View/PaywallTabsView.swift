//
//  PaywallTabsView.swift
//  onboarding-ios
//
//  Created by Claude on 18.10.26.
//

import SwiftUI

/// Two or more paywalls behind the host's own tabs (Songs / Lyrics), swapped in
/// place. What every tab shares stays put: the header mark, the tabs under the
/// headline, the close and the footer links. The rest (headline, features,
/// plans, CTA and the line under it) fades from one tab into the next, each
/// element where the last one was, provided the tabs' pages lay out alike
/// (`PaywallConfiguration.planRowSpacing`, `showsTrialTimeline`,
/// `footnote`). A plain crossfade with a touch of blur: the 12 pt blur and
/// `.blurReplace` it opened with (4.10) smeared the whole page on every
/// switch (Pavel, 2026-10-20).
///
/// One cadence is selected across the tabs: the tab the paywall opens on picks
/// it (its `featuredPeriod`), and a plan chosen on one tab selects the plan of
/// the same cadence on the others, where they sell one.
///
/// A tab's page is built the first time it is selected, so its plans load and
/// `paywall_shown` goes out once per tab actually seen. The tabs view is the
/// host's; it reports a choice by changing `selection`.
public struct PaywallTabsView: View {

    /// One tab's paywall.
    public struct Page {
        let viewModel: PaywallViewModel
        let configuration: PaywallConfiguration

        public init(viewModel: PaywallViewModel, configuration: PaywallConfiguration) {
            self.viewModel = viewModel
            self.configuration = configuration
        }
    }

    private let pages: [Page]
    private let selection: Int
    private let dismiss: PaywallDismissBehavior?
    private let tabs: AnyView
    private let onUnlocked: () -> Void

    /// The tabs built so far.
    @State private var built: Set<Int>
    /// The tab whose model the shared layer uses for Restore: the one open first.
    @State private var chromeIndex: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        pages: [Page],
        selection: Int,
        dismiss: PaywallDismissBehavior? = nil,
        tabs: AnyView,
        onUnlocked: @escaping () -> Void
    ) {
        precondition(pages.indices.contains(selection), "selection must index into pages")
        self.pages = pages
        self.selection = selection
        self.dismiss = dismiss
        self.tabs = tabs
        self.onUnlocked = onUnlocked
        _built = State(initialValue: [selection])
        _chromeIndex = State(initialValue: selection)
    }

    public var body: some View {
        GeometryReader { geo in
            ScrollView {
                ZStack(alignment: .top) {
                    ForEach(pages.indices, id: \.self) { index in
                        if built.contains(index) || index == selection {
                            page(index, minHeight: geo.size.height)
                        }
                    }
                    PaywallView(
                        viewModel: pages[chromeIndex].viewModel,
                        configuration: pages[chromeIndex].configuration,
                        dismiss: dismiss,
                        headerAccessory: tabs,
                        layer: .chrome,
                        embeddedMinHeight: geo.size.height,
                        isCurrent: true,
                        onUnlocked: onUnlocked
                    )
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .animation(.easeInOut(duration: reduceMotion ? 0.2 : 0.25), value: selection)
        .onChange(of: selection) { _, new in built.insert(new) }
        .onChange(of: currentChoice) { old, new in
            // A switch of tab is not a choice of plan.
            guard old.tab == new.tab, let period = new.period else { return }
            for (index, page) in pages.enumerated() where index != new.tab {
                page.viewModel.follow(period: period)
            }
        }
    }

    private struct Choice: Equatable {
        let tab: Int
        let period: PaywallPlan.Period?
    }

    /// The shown tab's selected cadence; it changes when that tab's plans
    /// land (the opening pick) or the user picks another plan there.
    private var currentChoice: Choice {
        Choice(tab: selection, period: pages[selection].viewModel.selectedPlan?.period)
    }

    private func page(_ index: Int, minHeight: CGFloat) -> some View {
        let isSelected = index == selection
        return PaywallView(
            viewModel: pages[index].viewModel,
            configuration: pages[index].configuration,
            dismiss: dismiss,
            headerAccessory: tabs,
            layer: .content,
            embeddedMinHeight: minHeight,
            isCurrent: isSelected,
            onUnlocked: onUnlocked
        )
        .opacity(isSelected ? 1 : 0)
        .blur(radius: isSelected || reduceMotion ? 0 : 3)
        .allowsHitTesting(isSelected)
        .accessibilityHidden(!isSelected)
        .transition(.opacity)
    }
}
