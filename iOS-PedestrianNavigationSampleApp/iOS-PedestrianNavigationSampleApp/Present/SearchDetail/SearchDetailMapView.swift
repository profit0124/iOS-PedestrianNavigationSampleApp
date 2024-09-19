//
//  SearchDetailMapView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/13/24.
//

import SwiftUI
import MapKit

struct SearchDetailMapView: UIViewRepresentable {
    @Binding var mapView: MKMapView
    @ObservedObject var viewModel: SearchDetailViewModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        if let routes = viewModel.state?.routes {
            let coordinates = routes.map { $0.lineModels }.flatMap{ $0 }.flatMap{ $0.cooridnates }
            let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(polyLine)
        }
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        context.coordinator.setRegion()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: SearchDetailMapView
        
        init(parent: SearchDetailMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
            switch overlay {
            case let polyline as MKPolyline:
                let renderer = MKPolylineRenderer(overlay: polyline)
                renderer.strokeColor = .red
                renderer.lineWidth = 2.0
                return renderer
            default:
                fatalError()
            }
            
        }
        
        func setRegion() {
            if let state = self.parent.viewModel.state {
                if let route = state.selectedRoute,
                   let start = route.lineModels.first?.cooridnates.first,
                   let end = route.lineModels.last?.cooridnates.last {
                    parent.mapView.setRegion(calculateRegion(from: start, to: end), animated: true)
                } else if let start = state.routes.first?.pointCoordinate,
                          let end = state.routes.last?.pointCoordinate {
                    parent.mapView.setRegion(calculateRegion(from: start, to: end), animated: true)
                }
            }
        }
        
        func calculateRegion(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> MKCoordinateRegion {
            let latitudeDelta = abs(start.latitude - end.latitude) * 1.5
            let longitudeDelta = abs(start.longitude - end.longitude) * 1.5
            
            let centerLatitude = (start.latitude + end.latitude) / 2
            let centerLongitude = (start.longitude + end.longitude) / 2
            let centerCoordinate = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
            
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            return MKCoordinateRegion(center: centerCoordinate, span: span)
        }
    }
}

