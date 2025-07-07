//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 07.07.25.
//

import SwiftUI

@available(iOS 17.0, *)
private struct PopupModifier<PopupContent>: ViewModifier where PopupContent: View {
    @Binding var isPresented: Bool
    @ViewBuilder var popupContent: () -> PopupContent

    func body(content: Content) -> some View {
        content
            .shading(isPresented: $isPresented) {
                popupContent()
                    .modifier(PopupContentModifier())
            }
    }
}

@available(iOS 17.0, *)
private struct PopupItemModifier<Item, PopupContent>: ViewModifier where Item: Equatable, PopupContent: View {
    @State private var isPresented: Bool = false
    @State private var cachedItem: Item?

    @Binding var item: Item?
    @ViewBuilder var popupContent: (Item) -> PopupContent

    func body(content: Content) -> some View {
        content
            .onChange(of: item) { _, newValue in
                if newValue != nil {
                    cachedItem = newValue
                    isPresented = true
                } else {
                    isPresented = false
                }
            }
            .shading(isPresented: $isPresented) {
                if let item = cachedItem {
                    popupContent(item)
                        .modifier(PopupContentModifier())
                        .onDisappear {
                            cachedItem = nil
                        }
                }
            }
    }
}

private struct PopupContentModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(uiColor: .systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(32)
    }
}

@available(iOS 17.0, *)
public extension View {

    func popup<PopupContent>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> PopupContent
    ) -> some View where PopupContent: View {
        modifier(PopupModifier(isPresented: isPresented, popupContent: content))
    }

    func popup<Item, PopupContent>(
        item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> PopupContent
    ) -> some View where Item: Equatable, PopupContent: View {
        modifier(PopupItemModifier(item: item, popupContent: content))
    }
}

