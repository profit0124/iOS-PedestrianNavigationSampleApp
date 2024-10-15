//
//  SearchDetailViewModel.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/13/24.
//

import Foundation
import Combine


final class SearchDetailViewModel: ObservableObject {
    let model: SearchResultModel
    private var service: RoutesService
    
    @Published var state: State?
    
    var cancellable = Set<AnyCancellable>()
    
    init(model: SearchResultModel) {
        self.model = model
        self.service = .init()
    }
    
    struct State {
        let totalDistance: Int
        let totalTime: Int
        let routes: [NavigationModel]
        var selectedRoute: NavigationModel?
    }
    
    enum Action {
        case fetch
        case selectItem(NavigationModel)
        case diselectItem
    }
    
    func send(_ action: Action) {
        switch action {
        case .fetch:
            fetch()
        case .selectItem(let navigationModel):
            state?.selectedRoute = navigationModel
        case .diselectItem:
            state?.selectedRoute = nil
        }
    }
    
    private func fetch() {
        service.fetch(model)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure = completion {
                    print(completion)
                }
            } receiveValue: { value in
                self.state = value
            }
            .store(in: &cancellable)
    }
}
