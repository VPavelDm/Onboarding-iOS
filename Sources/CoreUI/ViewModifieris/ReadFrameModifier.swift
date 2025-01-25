//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 06.09.24.
//

import SwiftUI

private struct ReadFrameModifier: ViewModifier {

    @Binding var frame: CGRect
    @Binding var size: CGSize
    var coordinateSpace: CoordinateSpace

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometryProxy in
                    Color.clear
                        .preference(key: FramePreferenceKey.self, value: geometryProxy.frame(in: coordinateSpace))
                        .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
                }
            )
            .onPreferenceChange(FramePreferenceKey.self) { frame in
                self.frame = frame
            }
            .onPreferenceChange(SizePreferenceKey.self) { size in
                self.size = size
            }
    }
}

private struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { }
}

public extension View {

    func readSize(size: Binding<CGSize>) -> some View {
        modifier(ReadFrameModifier(frame: .constant(.zero), size: size, coordinateSpace: .global))
    }

    func readFrame(frame: Binding<CGRect>, coordinateSpace: CoordinateSpace = .local) -> some View {
        modifier(ReadFrameModifier(frame: frame, size: .constant(.zero), coordinateSpace: coordinateSpace))
    }
}
