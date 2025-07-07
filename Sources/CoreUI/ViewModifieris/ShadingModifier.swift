//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 07.07.25.
//

import SwiftUI

@available(iOS 17.0, *)
private struct ShadingModifier<Item, ShadingContent>: ViewModifier where Item: Identifiable & Hashable, ShadingContent: View {

    @State private var presentedItem: Item?
    @State private var isContentVisible: Bool = false

    @Binding var item: Item?
    @ViewBuilder var content: (Item) -> ShadingContent

    func body(content: Content) -> some View {
        content
            .presentationBackground(Color(.systemBackground))
            .background(leaf)
            .onChange(of: item) { _, newItem in
                if newItem != nil {
                    presentedItem = newItem
                } else {
                    withAnimation {
                        isContentVisible = false
                    } completion: {
                        presentedItem = nil
                    }
                }
            }
    }

    private var leaf: some View {
        Text("")
            .fullScreenCover(item: $presentedItem) { item in
                ZStack {
                    if isContentVisible {
                        backgroundView.zIndex(1)
                        content(item)
                            .transition(transitionAnimation)
                            .zIndex(2)
                    }
                }
                .onAppear {
                    withAnimation {
                        isContentVisible = true
                    }
                }
                .presentationBackground(.clear)
            }
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
    }

    private var backgroundView: some View {
        Color.black.opacity(0.65)
            .ignoresSafeArea()
    }

    private var transitionAnimation: AnyTransition {
        .offset(y: 60).combined(with: .opacity)
    }
}

@available(iOS 17.0, *)
public extension View {

    func shading<Item, ShadingContent>(
        item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> ShadingContent
    ) -> some View where Item: Identifiable & Hashable, ShadingContent: View {
        modifier(ShadingModifier(item: item, content: content))
    }
}
