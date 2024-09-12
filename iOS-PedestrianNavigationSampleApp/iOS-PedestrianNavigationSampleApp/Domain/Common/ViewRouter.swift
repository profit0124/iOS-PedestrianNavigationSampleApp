//
//  ViewRouter.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import SwiftUI

protocol ViewRouterProtocol {
    var path: [NavigationDestination] { get set }
    func push(_ destination: NavigationDestination)
    func pop()
    func goToRoot()
}

final class ViewRouter: ViewRouterProtocol, ObservableObject {
    
    @Published var path: [NavigationDestination]
    
    init() {
        self.path = []
    }
    
    func push(_ destination: NavigationDestination) {
        path.append(destination)
    }
    
    func pop() {
        let _ = path.removeLast()
    }
    
    func goToRoot() {
        path.removeAll()
    }
}
