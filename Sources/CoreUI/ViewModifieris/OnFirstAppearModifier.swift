//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import SwiftUI

private struct OnFirstAppearModifier: ViewModifier {
    @State private var isLoaded: Bool = false

    var perform: () async -> Void

    func body(content: Content) -> some View {
        content
            .task {
                guard !isLoaded else { return }
                isLoaded = true
                await perform()
            }
    }
}

public extension View {

    func onFirstAppear(perform: @escaping () async -> Void) -> some View {
        modifier(OnFirstAppearModifier(perform: perform))
    }
}
