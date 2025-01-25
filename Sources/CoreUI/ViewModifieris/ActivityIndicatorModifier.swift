//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import SwiftUI

private struct ProgressViewModifier<ProgressContent>: ViewModifier where ProgressContent: View {
    var isVisible: Bool
    var progressContent: () -> ProgressContent

    func body(content: Content) -> some View {
        ZStack {
            if isVisible {
                progressContent()
            } else {
                content
            }
        }
        .animation(.easeInOut, value: isVisible)
    }
}

public extension View {

    func progressView<ProgressContent>(isVisible: Bool, progressContent: @escaping () -> ProgressContent) -> some View where ProgressContent: View {
        modifier(ProgressViewModifier(isVisible: isVisible, progressContent: progressContent))
    }
}
