//
//  SearchResultSimulatorViewModel.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 10/23/24.
//

import Foundation
import Combine

@MainActor
final class SearchResultSimulatorViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var results: [SearchResultModel] = []
    
    let service: SearchServiceType
    
    var cancellable: Set<AnyCancellable> = []
    
    var isLoading: Bool = false
    
    init(_ text: String) {
        self.searchText = text
        self.service = StubSearchService()
    }
    
    enum Action {
        case fetchData
    }
    
    func send(_ action: Action) {
        switch action {
        case .fetchData:
            fetch()
        }
    }
    
    private func fetch() {
        isLoading = true
        results = []
        
        service.fetch(searchText)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure = completion {
                    print("failure")
                }
            } receiveValue: { [weak self] in
                self?.results = $0
                self?.isLoading = false
            }
            .store(in: &cancellable)
    }
}
