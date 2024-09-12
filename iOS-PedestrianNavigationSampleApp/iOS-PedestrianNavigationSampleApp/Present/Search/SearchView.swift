//
//  SearchView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject var router: ViewRouter
    @StateObject private var viewModel: SearchViewModel = .init()
    
    var body: some View {
        HStack {
            TextField("목적지를 입력해주세요.", text: $viewModel.text)
            
            Button {
                router.push(.searchResult(text: viewModel.text))
            } label: {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.white)
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(viewModel.text.isEmpty ? .gray : .blue)
                    }
            }
            .disabled(viewModel.text.isEmpty)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: 2)
                .foregroundStyle(.blue)
        }
        .padding(16)
        .onDisappear {
            viewModel.clearText()
        }

    }
}

#Preview {
    SearchView()
        .environmentObject(ViewRouter())
}
