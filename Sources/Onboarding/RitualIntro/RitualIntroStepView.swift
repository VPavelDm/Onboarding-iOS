import SwiftUI
import CoreUI

/// A step that introduces the habit tools an app offers as a grid of numbered cards, each of
/// which turns over to explain itself. One card is turned over at a time.
///
/// Meant for a custom step: show it from the `OnboardingView`'s custom-step builder and call the
/// step's params from `onClose`.
public struct RitualIntroStepView: View {
    @State private var flippedToolID: RitualIntroTool.ID?
    @State private var revealedTools = 0

    private let copy: RitualIntroStepCopy
    private let tools: [RitualIntroTool]
    private let colorPalette: ColorPalette
    private let onClose: () async -> Void

    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    public init(
        copy: RitualIntroStepCopy,
        tools: [RitualIntroTool],
        colorPalette: ColorPalette,
        onClose: @escaping () async -> Void
    ) {
        self.copy = copy
        self.tools = tools
        self.colorPalette = colorPalette
        self.onClose = onClose
    }

    public var body: some View {
        VStack(spacing: 28) {
            Spacer()
            headerSection
            toolsGrid
            Spacer()
            continueButton
        }
        .padding(.horizontal, UIConstants.hScreenPadding)
        .padding(.bottom, UIConstants.vScreenPadding)
    }

    private var headerSection: some View {
        VStack(spacing: UIConstants.headingSpacing) {
            titleView
            descriptionView
        }
    }

    private var titleView: some View {
        Text(verbatim: copy.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundStyle(colorPalette.textColor)
            .multilineTextAlignment(.center)
    }

    private var descriptionView: some View {
        Text(verbatim: copy.description)
            .font(.subheadline)
            .foregroundStyle(colorPalette.textColor.opacity(0.7))
            .multilineTextAlignment(.center)
    }

    private var toolsGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            ForEach(Array(tools.enumerated()), id: \.element.id) { index, tool in
                RitualIntroToolCard(
                    tool: tool,
                    number: index + 1,
                    isFlipped: flippedToolID == tool.id,
                    colorPalette: colorPalette
                ) {
                    toggleFlip(tool)
                }
                .staggeredAppear(visible: revealedTools > index)
            }
        }
        .staggeredReveal(count: tools.count, revealed: $revealedTools)
    }

    private var continueButton: some View {
        AsyncButton {
            await onClose()
        } label: {
            Text(verbatim: copy.buttonTitle)
        }
        .buttonStyle(PrimaryButtonStyle(colorPalette: colorPalette))
    }

    private func toggleFlip(_ tool: RitualIntroTool) {
        flippedToolID = (flippedToolID == tool.id) ? nil : tool.id
    }
}

private struct RitualIntroToolCard: View {
    let tool: RitualIntroTool
    let number: Int
    let isFlipped: Bool
    let colorPalette: ColorPalette
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            frontFace
                .cardFlip(isFlipped: isFlipped) { backFace }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.6, dampingFraction: 0.85), value: isFlipped)
    }

    private var frontFace: some View {
        VStack(spacing: 14) {
            iconHalo
            VStack(spacing: 4) {
                titleView
                subtitleView
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, minHeight: 170, alignment: .top)
        .glassBackground(cornerRadius: 20)
        .overlay(alignment: .topTrailing) { numberBadge }
    }

    private var backFace: some View {
        VStack(spacing: 10) {
            titleView
            Text(verbatim: tool.detail)
                .font(.caption2)
                .foregroundStyle(colorPalette.textColor.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, minHeight: 170, alignment: .top)
        .glassBackground(cornerRadius: 20)
    }

    private var iconHalo: some View {
        ZStack {
            haloGlow
            Circle()
                .fill(colorPalette.accentColor.opacity(0.12))
                .frame(width: 56, height: 56)
            toolIcon
        }
    }

    private var toolIcon: some View {
        Image(systemName: tool.systemImage)
            .font(.system(size: 28, weight: .medium))
            .foregroundStyle(colorPalette.textColor)
    }

    private var haloGlow: some View {
        Circle()
            .fill(colorPalette.accentColor.opacity(0.22))
            .frame(width: 76, height: 76)
            .blur(radius: 16)
    }

    private var titleView: some View {
        Text(verbatim: tool.title)
            .font(.headline)
            .foregroundStyle(colorPalette.textColor)
    }

    private var subtitleView: some View {
        Text(verbatim: tool.subtitle)
            .font(.caption2)
            .foregroundStyle(colorPalette.textColor.opacity(0.6))
            .multilineTextAlignment(.center)
    }

    private var numberBadge: some View {
        Text(verbatim: "\(number)")
            .font(.caption2.weight(.bold))
            .foregroundStyle(colorPalette.textColor.opacity(0.55))
            .frame(width: 20, height: 20)
            .background(Circle().fill(Color.white.opacity(0.08)))
            .padding(10)
    }
}

#Preview {
    RitualIntroStepView(
        copy: RitualIntroStepCopy(
            title: "Now: how not to quit.",
            description: "Lessons alone aren't enough. You need a way to come back every day.",
            buttonTitle: "Let's set it up"
        ),
        tools: [
            RitualIntroTool(id: "widget", systemImage: "square.grid.2x2.fill", title: "Widget", subtitle: "home screen", detail: "A streak counter right on your home screen."),
            RitualIntroTool(id: "daily", systemImage: "bell.badge.fill", title: "Every day", subtitle: "reminders", detail: "Three times a day: morning, midday, evening."),
        ],
        colorPalette: .testData,
        onClose: {}
    )
    .background(Color.black)
}
