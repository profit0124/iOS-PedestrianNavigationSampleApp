//
//  RoundedRectangleButtonStyle.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 10/7/24.
//

import SwiftUI

struct RoundedRectangleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue)
            )
            .padding()
    }
}
