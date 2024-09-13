//
//  SearchDetailViewModel.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/13/24.
//

import Foundation


final class SearchDetailViewModel: ObservableObject {
    let model: SearchResultModel
    var service: RoutesService
    
    init(model: SearchResultModel) {
        self.model = model
        self.service = .init()
    }
    
    func onAppear() {
        service.fetch(model)
    }
}
