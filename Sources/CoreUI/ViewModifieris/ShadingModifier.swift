//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 07.07.25.
//

import SwiftUI

@available(iOS 17.0, *)
private struct ShadingModifier<ShadingContent>: ViewModifier where ShadingContent: View {

    @State private var isFullScreenPresented: Bool = false
    @State private var isContentVisible: Bool = false

    @Binding var isPresented: Bool
    @ViewBuilder var content: () -> ShadingContent

    func body(content: Content) -> some View {
        content
            .background(leaf)
            .onChange(of: isPresented) { isPresented in
                if isPresented {
                    isFullScreenPresented = true
                } else {
                    withAnimation {
                        isContentVisible = false
                    } completion: {
                        isFullScreenPresented = false
                    }
                }
            }
    }

    private var leaf: some View {
        Text("")
            .fullScreenCover(isPresented: $isFullScreenPresented) {
                ZStack {
                    if isContentVisible {
                        backgroundView.zIndex(1)
                        content().zIndex(2)
                    }
                }
                .presentationBackground(.clear)
                .onAppear {
                    withAnimation {
                        isContentVisible = true
                    }
                }
            }
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
    }

    private var backgroundView: some View {
        Color.black.opacity(0.65)
            .ignoresSafeArea()
    }
}

@available(iOS 17.0, *)
public extension View {

    func shading<ShadingContent>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> ShadingContent
    ) -> some View where ShadingContent: View {
        modifier(ShadingModifier(isPresented: isPresented, content: content))
    }
}
