//
//  PaywallTabsView.swift
//  onboarding-ios
//
//  Created by Claude on 18.10.26.
//

import SwiftUI

/// Two or more paywalls behind tabs, swapped in place. What every tab shares
/// stays put: the header mark, the tabs under the headline, the close and the
/// footer links. The rest (headline, features, plans, CTA and the line under
/// it) fades from one tab into the next, each element where the last one was,
/// provided the tabs' pages lay out alike (`PaywallConfiguration.planRowSpacing`,
/// `showsTrialTimeline`, `footnote`). A plain crossfade with a touch of blur:
/// the 12 pt blur and `.blurReplace` it opened with (4.10) smeared the whole
/// page on every switch (Pavel, 2026-10-20).
///
/// One cadence is selected across the tabs: the tab the paywall opens on picks
/// it (its `featuredPeriod`), and a plan chosen on one tab selects the plan of
/// the same cadence on the others, where they sell one.
///
/// Every tab's page is built up front, hidden, so a switch is a crossfade
/// between two laid-out pages: built on first selection (4.10), the first
/// switch played the page's insertion and its plans landing over the fade
/// (Pavel, 2026-10-20). `paywall_shown` still goes out once per tab actually
/// seen (`PaywallView` reports it when the tab becomes current).
///
/// Two ways in. `init(viewModel:)` takes a `PaywallTabsViewModel` (4.12): the
/// package draws the segmented control from the paywall's colours, logs the
/// one view of the placement, keeps the exits single-shot and gives the
/// haptics; a host that would rather draw the tabs itself passes `tabs:`.
/// `init(pages:selection:dismiss:tabs:onUnlocked:)` is the host-driven form
/// from 4.10: the host owns the selection and the tabs view, and reports a
/// choice by changing `selection`.
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
    /// The tabs model, when the package runs the tabs; its selection wins.
    private let tabsModel: PaywallTabsViewModel?
    private let hostSelection: Int
    private let dismiss: PaywallDismissBehavior?
    /// The host's tabs view; nil draws the package's segmented control.
    private let tabs: AnyView?
    private let onUnlocked: () -> Void

    /// The tab whose model the shared layer uses for Restore: the one open first.
    @State private var chromeIndex: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The tabs run by `viewModel`. `onDismiss` adds the corner close (after
    /// the model's `closeButtonDelay`); nil keeps the paywall hard. Unlock
    /// and close each fire once, whichever tab they happen on.
    public init(
        viewModel: PaywallTabsViewModel,
        onDismiss: (@MainActor () -> Void)? = nil,
        tabs: AnyView? = nil,
        onUnlocked: @escaping () -> Void
    ) {
        self.pages = viewModel.pages.map { Page(viewModel: $0.paywall, configuration: $0.tab.configuration) }
        self.tabsModel = viewModel
        self.hostSelection = 0
        self.dismiss = onDismiss.map { onDismiss in
            PaywallDismissBehavior(closeButtonDelay: viewModel.closeButtonDelay) {
                guard viewModel.markDismissed() else { return }
                onDismiss()
            }
        }
        self.tabs = tabs
        self.onUnlocked = {
            guard viewModel.markUnlocked() else { return }
            onUnlocked()
        }
        _chromeIndex = State(initialValue: viewModel.selectedIndex)
    }

    public init(
        pages: [Page],
        selection: Int,
        dismiss: PaywallDismissBehavior? = nil,
        tabs: AnyView,
        onUnlocked: @escaping () -> Void
    ) {
        precondition(pages.indices.contains(selection), "selection must index into pages")
        self.pages = pages
        self.tabsModel = nil
        self.hostSelection = selection
        self.dismiss = dismiss
        self.tabs = tabs
        self.onUnlocked = onUnlocked
        _chromeIndex = State(initialValue: selection)
    }

    private var selection: Int { tabsModel?.selectedIndex ?? hostSelection }

    public var body: some View {
        let tabsView = tabsView
        GeometryReader { geo in
            ScrollView {
                ZStack(alignment: .top) {
                    ForEach(pages.indices, id: \.self) { index in
                        page(index, tabs: tabsView, minHeight: geo.size.height)
                    }
                    PaywallView(
                        viewModel: pages[chromeIndex].viewModel,
                        configuration: pages[chromeIndex].configuration,
                        dismiss: dismiss,
                        headerAccessory: tabsView,
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
        .sensoryFeedback(.selection, trigger: selection) { _, _ in tabsModel != nil }
        .sensoryFeedback(.success, trigger: tabsModel?.unlocked ?? false) { _, new in new }
        .task { await tabsModel?.onAppear() }
        .onChange(of: currentChoice) { old, new in
            // A switch of tab is not a choice of plan.
            guard old.tab == new.tab, let period = new.period else { return }
            for (index, page) in pages.enumerated() where index != new.tab {
                page.viewModel.follow(period: period)
            }
        }
    }

    /// The host's tabs, else the package's control in the chrome page's colours.
    private var tabsView: AnyView {
        if let tabs { return tabs }
        let configuration = pages[chromeIndex].configuration
        return AnyView(
            PaywallSegmentedControl(
                titles: tabsModel?.titles ?? [],
                selectedIndex: selection,
                textColor: configuration.textColor,
                accent: configuration.accent ?? configuration.ctaBackground ?? .accentColor,
                accentForeground: configuration.accentForeground ?? configuration.ctaForeground ?? .white,
                onSelect: { tabsModel?.select(index: $0) }
            )
        )
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

    private func page(_ index: Int, tabs: AnyView, minHeight: CGFloat) -> some View {
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
    }
}
