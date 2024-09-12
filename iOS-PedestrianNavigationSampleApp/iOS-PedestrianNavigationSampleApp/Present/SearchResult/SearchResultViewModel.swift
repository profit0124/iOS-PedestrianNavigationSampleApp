//
//  SearchResultViewModel.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation
import MapKit
import Combine

@MainActor
final class SearchResultViewModel: ObservableObject {
    @Published var searchText: String
    @Published var isLoading: Bool = false
    @Published var results: [SearchResultModel] = []
    
    let service: SearchService
    
    var cancellable = Set<AnyCancellable>()
    
    init(searchText: String) {
        self.searchText = searchText
        
        self.service = SearchService()
    }
    
    enum Action {
        case onAppear
        case fetchData
    }
    
    func send(_ action: Action) {
        switch action {
        case .onAppear:
            onAppear()
            
        case .fetchData:
            fetch()
        }
    }
    
    func onAppear() {
        isLoading = true
    }
    
    private func fetch() {
        isLoading = true
        results = []
        
        service.fetch(self.searchText)
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
