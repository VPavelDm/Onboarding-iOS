//
//  File.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 09.06.25.
//

import SwiftUI

public struct Action: Identifiable {
    public var id: UUID
    var image: String
    var title: String
    var color: Color
    var isPresented: Bool
    var action: () -> AnyView
    var handler: (() -> Void)?

    public init(
        id: UUID = UUID(),
        image: String,
        title: String,
        color: Color,
        isPresented: Bool,
        action: @escaping () -> AnyView
    ) {
        self.id = id
        self.image = image
        self.title = title
        self.color = color
        self.isPresented = isPresented
        self.action = action
        self.handler = nil
    }

    /// A row that just does something — a permission request, a jump to
    /// Settings — with no screen behind it to present.
    public init(
        id: UUID = UUID(),
        image: String,
        title: String,
        color: Color,
        handler: @escaping () -> Void
    ) {
        self.id = id
        self.image = image
        self.title = title
        self.color = color
        self.isPresented = false
        self.action = { AnyView(EmptyView()) }
        self.handler = handler
    }
}
