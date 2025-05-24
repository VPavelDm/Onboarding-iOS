//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 08.09.24.
//

import SwiftUI

public struct AsyncButton<Label, CircularProgress>: View where Label: View, CircularProgress: View {
    @State private var isLoading: Bool = false

    var perform: () async -> Void
    var label: () -> Label
    var progress: () -> CircularProgress

    public init(
        perform: @escaping () async -> Void,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder progress: @escaping () -> CircularProgress = { ProgressView().tint(.black) }
    ) {
        self.perform = perform
        self.label = label
        self.progress = progress
    }

    public var body: some View {
        Button {
            Task { @MainActor in
                isLoading = true
                await perform()
                isLoading = false
            }
        } label: {
            ZStack {
                label().opacity(isLoading ? 0 : 1)
                progress().opacity(isLoading ? 1 : 0)
            }
        }
    }
}
