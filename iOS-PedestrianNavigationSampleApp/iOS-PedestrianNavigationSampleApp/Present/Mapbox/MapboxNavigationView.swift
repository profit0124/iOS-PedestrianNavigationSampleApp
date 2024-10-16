//
//  MapboxNavigationView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 10/15/24.
//

import SwiftUI
import MapKit

struct MapboxNavigationView: View {
    
    @StateObject private var vm: MapboxNavigationViewModel
    
    init(_ model: SearchResultModel) {
        self._vm = .init(wrappedValue: .init(model: model))
    }
    
    var body: some View {
        ZStack {
            MapboxNavigationViewRepresentable(vm: vm)
            
            if !vm.isCompleted {
                ProgressView()
            }
        }
        .onAppear {
            vm.send(.onAppear)
        }
    }
}


struct MapboxNavigationViewRepresentable: UIViewRepresentable {
    
    let mapView: MKMapView
    @ObservedObject var vm: MapboxNavigationViewModel
    
    init(vm: MapboxNavigationViewModel) {
        self.mapView = MKMapView(frame: .zero)
        self.vm = vm
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        self.mapView.showsUserLocation = true
        self.mapView.userTrackingMode = .followWithHeading
        self.mapView.delegate = context.coordinator
        return self.mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        context.coordinator.addPolyLine()
    }
    
    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapboxNavigationViewRepresentable
        
        init(parent: MapboxNavigationViewRepresentable) {
            self.parent = parent
        }
        
        func addPolyLine() {
            let coordinator = parent.vm.mapboxCoordinates
            let polyLine = MKPolyline(coordinates: coordinator, count: coordinator.count)
            
            parent.mapView.addOverlay(polyLine)
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
            switch overlay {
                case let polyline as MKPolyline:
                let renderer = MKPolylineRenderer(overlay: polyline)
                renderer.strokeColor = .red
                renderer.lineWidth = 3
                return renderer
                
            default:
                fatalError()
            }
        }
    }
}
