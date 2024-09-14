//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 14.09.24.
//

import SwiftUI
import CoreUI

struct CheckBox: View {
    @Environment(\.colorPalette) private var colorPalette
    @Binding var isChose: Bool

    var body: some View {
        CoreUI.CheckBox(colorPalette: colorPalette, isChose: $isChose)
    }
}
