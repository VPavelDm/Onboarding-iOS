//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 07.07.25.
//

import SwiftUI

@available(iOS 17.0, *)
private struct PopupModifier<Item, PopupContent>: ViewModifier where Item: Identifiable & Hashable, PopupContent: View {
    @Binding var item: Item?
    @ViewBuilder var popupContent: (Item) -> PopupContent

    func body(content: Content) -> some View {
        content
            .shading(item: $item) { item in
                popupContent(item)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(uiColor: .systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(32)
                    .frame(maxWidth: 500)
            }
    }
}

@available(iOS 17.0, *)
private struct PopupBoolModifier<PopupContent>: ViewModifier where PopupContent: View {
    struct ItemIdentifiable: Identifiable, Sendable, Hashable {
        var id: UUID = UUID()
    }

    @State private var item: ItemIdentifiable?

    @Binding var isPresented: Bool
    @ViewBuilder var popupContent: () -> PopupContent
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _, newValue in
                if newValue {
                    item = ItemIdentifiable()
                } else {
                    item = nil
                }
            }
            .shading(item: $item) { _ in
                popupContent()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(uiColor: .systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(32)
                    .frame(maxWidth: 500)
            }
    }
}

@available(iOS 17.0, *)
public extension View {

    func popup<Item, PopupContent>(
        item: Binding<Item?>,
        @ViewBuilder content: @escaping (Item) -> PopupContent
    ) -> some View where Item: Identifiable & Hashable, PopupContent: View {
        modifier(PopupModifier(item: item, popupContent: content))
    }

    func popup<PopupContent>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> PopupContent
    ) -> some View where PopupContent: View {
        modifier(PopupBoolModifier(isPresented: isPresented, popupContent: content))
    }
}
