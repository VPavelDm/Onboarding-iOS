//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import SwiftUI

// Must stay internal (not private/@nobridge) — Skip drops unbridged modifiers, so `.onFirstAppear` wouldn't fire on Android.
struct OnFirstAppearModifier: ViewModifier {
    @State var isLoaded: Bool = false

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
