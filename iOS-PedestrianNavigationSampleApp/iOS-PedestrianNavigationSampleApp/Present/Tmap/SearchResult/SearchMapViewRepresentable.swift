//
//  SearchMapViewRepresentable.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/12/24.
//

import SwiftUI
import MapKit

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
    
    final class Coordinator: NSObject, MKMapViewDelegate {
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
            }
        }
    }
}
