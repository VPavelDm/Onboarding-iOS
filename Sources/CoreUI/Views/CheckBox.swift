//
//  SwiftUIView.swift
//  
//
//  Created by Pavel Vaitsikhouski on 05.09.24.
//

import SwiftUI

public struct CheckBox: View {
    @Binding var isChose: Bool

    public init(isChose: Binding<Bool>) {
        self._isChose = isChose
    }

    public var body: some View {
        Button {
            isChose.toggle()
        } label: {
            ZStack {
                if isChose {
                    RoundedRectangle(cornerRadius: .cornerRadius)
                        .frame(width: .size, height: .size)
                        .foregroundStyle(Color.accentColor)
                    Image(systemName: "checkmark")
                        .resizable()
                        .font(.system(size: .size / 2, weight: .semibold))
                        .frame(width: .size / 2, height: .size / 2)
                        .foregroundStyle(.black)
                } else {
                    RoundedRectangle(cornerRadius: .cornerRadius)
                        .stroke(lineWidth: .borderWidth)
                        .frame(width: .size, height: .size)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .animation(.easeInOut, value: isChose)
        }
    }
}

// MARK: - Constants

extension CGFloat {

    static let size: Self = 20
    static let cornerRadius: Self = 4
    static let borderWidth: Self = 1
}
