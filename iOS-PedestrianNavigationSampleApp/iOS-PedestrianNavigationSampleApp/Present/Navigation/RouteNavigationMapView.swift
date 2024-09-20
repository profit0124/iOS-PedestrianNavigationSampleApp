//
//  RouteNavigationMapView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 9/19/24.
//

import MapKit
import SwiftUI

struct RouteNavigationMapView: UIViewRepresentable {
    @ObservedObject var viewModel: RouteNavigationViewModel
    @Binding var mapView: MKMapView
    
    init(viewModel: RouteNavigationViewModel, mapView: Binding<MKMapView>) {
        self.viewModel = viewModel
        self._mapView = mapView
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        context.coordinator.addPolyLine()
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        context.coordinator.updatePolyLine()
        context.coordinator.updateCamera()
    }
    
    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RouteNavigationMapView
        
        init(parent: RouteNavigationMapView) {
            self.parent = parent
        }
        
        func addPolyLine() {
            parent.mapView.addOverlay(parent.viewModel.currentPolyline)
            parent.mapView.addOverlay(parent.viewModel.nextPolylines)
        }
        
        func updatePolyLine() {
            parent.mapView.overlays.forEach{
                parent.mapView.removeOverlay($0)
            }
            addPolyLine()
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
        
        func updateCamera() {
            if let location = parent.viewModel.currentLocation {
                let region = MKCoordinateRegion(center: location, span: .init(latitudeDelta: 0.001, longitudeDelta: 0.001))
                parent.mapView.setRegion(region, animated: true)
            }
        }
    }
}
