//
//  SearchResultViewModel.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import Foundation
import MapKit

@MainActor
final class SearchResultViewModel: ObservableObject {
    @Published var searchText: String
    @Published var isLoading: Bool = false
    @Published var results: [SearchResultModel] = []
    
    init(searchText: String) {
        self.searchText = searchText
    }
    
    enum Action {
        case onAppear
    }
    
    func send(_ action: Action) {
        switch action {
        case .onAppear:
            onAppear()
        }
    }
    
    func onAppear() {
        isLoading = true
    }
    
    func fetch() {
        Task {
            do {
                isLoading = true
                results = []
                // TODO: Domain 작업 후 results 값 할당 로직 구현
                try await Task.sleep(nanoseconds: 3_000_000_000)
                results = [.mock1, .mock2, .mock3]
                isLoading = false
            } catch {
                print("error: \(error)")
            }
        }
        
    }
}
