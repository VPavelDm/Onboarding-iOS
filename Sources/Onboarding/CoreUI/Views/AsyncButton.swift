//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 14.09.24.
//

import SwiftUI
import CoreUI

struct AsyncButton<Label>: View where Label: View {
    var perform: () async -> Void
    var label: () -> Label

    var body: some View {
        CoreUI.AsyncButton(perform: perform, label: label)
    }
}
