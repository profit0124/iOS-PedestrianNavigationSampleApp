//
//  SearchResultViewModel.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation
import MapKit
import Combine

protocol SearchResultViewModelProtocol: ObservableObject {
    var searchText: String { get set }
    var isLoading: Bool { get }
    var results: [SearchResultModel] { get set }
    
    func fetch()
}

final class SearchResultViewModel: SearchResultViewModelProtocol {
    @Published var searchText: String
    @Published var isLoading: Bool = false
    @Published var results: [SearchResultModel] = []
    
    let service: SearchService
    
    var cancellable = Set<AnyCancellable>()
    
    init(searchText: String) {
        self.searchText = searchText
        self.service = SearchService()
    }
    
    func fetch() {
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

final class StubSearchResultViewModel: SearchResultViewModelProtocol {
    @Published var searchText: String = ""
    @Published var results: [SearchResultModel] = []
    
    let service: SearchServiceType
    
    var cancellable: Set<AnyCancellable> = []
    
    var isLoading: Bool = false
    
    init(_ text: String) {
        self.searchText = text
        self.service = StubSearchService()
    }
    
    func fetch() {
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
