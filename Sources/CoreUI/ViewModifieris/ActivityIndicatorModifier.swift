//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import SwiftUI

#if !os(Android)
struct ProgressViewModifier<ProgressContent>: ViewModifier where ProgressContent: View {
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
#endif

public extension View {

    @ViewBuilder
    func progressView<ProgressContent>(isVisible: Bool, progressContent: @escaping () -> ProgressContent) -> some View where ProgressContent: View {
        #if os(Android)
        self
        #else
        modifier(ProgressViewModifier(isVisible: isVisible, progressContent: progressContent))
        #endif
    }
}
