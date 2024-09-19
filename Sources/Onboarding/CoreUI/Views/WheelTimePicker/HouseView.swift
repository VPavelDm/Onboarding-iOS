//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 19.09.24.
//

import SwiftUI

// MARK: - House

@available(iOS 17.0, *)
extension WheelTimePicker {

    struct HouseView: View {
        @ObservedObject var viewModel: ViewModel

        var body: some View {
            ZStack {
                homeView
                sunView
                    .frame(maxHeight: .dayNightRadius * 2, alignment: .top)
                    .rotationEffect(viewModel.sunAngle)
                    .animation(.linear, value: viewModel.sunAngle)
                moonView
                    .frame(maxHeight: .dayNightRadius * 2, alignment: .top)
                    .rotationEffect(viewModel.moonAngle)
                    .animation(.linear, value: viewModel.moonAngle)
            }
            .offset(y: .dayNightRadius - .homeSize / 2 + 5)
        }

        private var homeView: some View {
            Image("home", bundle: Bundle.module)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.white)
                .frame(width: .homeSize, height: .homeSize)
        }

        private var moonView: some View {
            Image(systemName: "moon.fill")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.yellow)
                .frame(width: 32, height: 32)
        }

        private var sunView: some View {
            Image(systemName: "sun.min.fill")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.yellow)
                .frame(width: 32, height: 32)
        }
    }
}

#Preview {
    VStack {
        if #available(iOS 17.0, *) {
            WheelTimePicker()
        }
    }
}
