//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 14.09.24.
//

import SwiftUI
import CoreUI

struct CheckBox: View {
    @Binding var isChose: Bool

    var body: some View {
        CoreUI.CheckBox(isChose: $isChose)
    }
}
