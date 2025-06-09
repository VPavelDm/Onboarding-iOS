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
    }
}
