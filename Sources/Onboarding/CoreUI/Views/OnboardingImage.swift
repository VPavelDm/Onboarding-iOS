//
//  File.swift
//  
//
//  Created by Pavel Vaitsikhouski on 06.09.24.
//

import SwiftUI

struct OnboardingImage: View {
    var image: ImageType
    var bundle: Bundle

    var body: some View {
        switch image {
        case .named(let string):
            Image(string, bundle: bundle)
                .resizable()
        case .remote(let url):
            AsyncImage(url: url)
        }
    }
}
