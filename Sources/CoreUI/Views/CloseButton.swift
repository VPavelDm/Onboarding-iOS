//
//  SwiftUIView.swift
//  onboarding-ios
//
//  Created by Pavel Vaitsikhouski on 23.01.26.
//

import SwiftUI

public struct CloseButton: View {
    var action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        if #available(iOS 26.0, *) {
            Button(role: .close) {
                action()
            }
        } else {
            Button {
                action()
            } label: {
                Text("Close")
            }
            .buttonStyle(ToolbarButtonStyle())
        }
    }
}
