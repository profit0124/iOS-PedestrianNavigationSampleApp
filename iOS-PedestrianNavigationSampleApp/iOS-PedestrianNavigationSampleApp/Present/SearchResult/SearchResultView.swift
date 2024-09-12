//
//  SearchResultView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import SwiftUI
import MapKit
import Combine

struct SearchResultView: View {
    
    @StateObject private var viewModel: SearchResultViewModel
    @State private var mapView: MKMapView = .init(frame: .zero)
    
    init(_ text: String) {
        self._viewModel = .init(wrappedValue: SearchResultViewModel(searchText: text))
    }
    
    var body: some View {
        VStack {
            GeometryReader {
                let size = $0.size
                VStack {
                    MapViewRepresentable(mapView: $mapView,
                                         results: $viewModel.results)
                    
                    Group {
                        if viewModel.results.isEmpty {
                            if viewModel.isLoading {
                                ProgressView()
                            } else {
                                Text("검색 결과가 없습니다.")
                            }
                        } else {
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 12) {
                                    ForEach(viewModel.results) { result in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(result.name)
                                                    .font(.system(size: 22, weight: .semibold))
                                                
                                                Text(result.newAddress)
                                                    .font(.system(size: 12))
                                            }
                                            
                                            Spacer()
                                            
                                            Button(action: {}, label: {
                                                Image(systemName: "magnifyingglass")
                                                    .foregroundStyle(Color.white)
                                                    .padding(10)
                                                    .background {
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .fill(.blue)
                                                    }
                                            })
                                            
                                            
                                        }
                                    }
                                }
                                .padding(.top, 12)
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .frame(height: size.height / 2)
                }
            }
            
        }
        .searchable(text: $viewModel.searchText)
        .onSubmit(of: .search) {
            viewModel.fetch()
        }
        .task {
            viewModel.fetch()
        }
    }
}

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var mapView: MKMapView
    @Binding var results: [SearchResultModel]
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.setRegion(.init(center: .init(latitude: 37.6000, longitude: 127.0442), span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
        
        mapView.showsUserLocation = true
        return mapView
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // view 의 rerender 가 일어날 때 호출됨
        context.coordinator.addAnnotation()
    }
    
    final class Coordinator {
        let parent: MapViewRepresentable
        var annotations: [MKPointAnnotation] = []
        
        init(parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        func addAnnotation() {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.parent.mapView.removeAnnotations(annotations)
                self.annotations = []
                self.parent.results.forEach { result in
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(
                        latitude: result.lat,
                        longitude: result.long)
                    annotation.title = result.name
                    self.annotations.append(annotation)
                }
                self.parent.mapView.addAnnotations(annotations)
                print("add annotation")
            }
        }
    }
}

#Preview {
    SearchResultView("Search result")
}
