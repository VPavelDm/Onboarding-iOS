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
/// plans, CTA and the line under it) blurs from one tab into the next, each
/// element where the last one was, provided the tabs' pages lay out alike
/// (`PaywallConfiguration.planRowSpacing`, `showsTrialTimeline`,
/// `emphasizesOfferFootnote`).
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
                        onUnlocked: onUnlocked
                    )
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .animation(reduceMotion ? .easeInOut(duration: 0.2) : .easeInOut(duration: 0.3), value: selection)
        .onChange(of: selection) { _, new in built.insert(new) }
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
            onUnlocked: onUnlocked
        )
        .opacity(isSelected ? 1 : 0)
        .blur(radius: isSelected || reduceMotion ? 0 : 12)
        .allowsHitTesting(isSelected)
        .accessibilityHidden(!isSelected)
        .transition(reduceMotion ? .opacity : AnyTransition(.blurReplace))
    }
}
