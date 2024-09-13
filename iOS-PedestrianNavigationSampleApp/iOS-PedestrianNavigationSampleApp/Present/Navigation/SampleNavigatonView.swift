//
//  NavigationView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import SwiftUI

struct SampleNavigatonView: View {
    
    let model: [NavigationModel]
    
    init(_ model: [NavigationModel]) {
        self.model = model
    }
    
    var body: some View {
        Text("Navigation view")
    }
}

#Preview {
    SampleNavigatonView([.init(id: 0, name: "", description: "", pointCoordinate: .init(latitude: 0, longitude: 0), lineModels: [])])
}
