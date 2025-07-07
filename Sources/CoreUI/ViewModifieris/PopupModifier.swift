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
}
