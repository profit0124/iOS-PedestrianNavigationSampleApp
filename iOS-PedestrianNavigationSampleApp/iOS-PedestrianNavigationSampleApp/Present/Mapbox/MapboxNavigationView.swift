//
//  MapboxNavigationView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 10/15/24.
//

import SwiftUI
import MapKit
import MapboxDirections

extension ProfileIdentifier {
    func getImage() -> Image {
        switch self {
        case .walking: return Image(systemName: "figure.walk")
        case .cycling: return Image(systemName: "bicycle")
        default: return Image(systemName: "person")
        }
    }
}

struct MapboxNavigationView: View {
    
    @StateObject private var vm: MapboxNavigationViewModel
    
    init(_ model: SearchResultModel) {
        self._vm = .init(wrappedValue: .init(model: model))
    }
    
    let searchTypeList: [ProfileIdentifier] = [.walking, .cycling]
    
    var body: some View {
        ZStack {
            MapboxNavigationViewRepresentable(vm: vm)
            
            VStack {
                
                Spacer()
                
                Button {
                    vm.send(.onAppear)
                } label: {
                    Text("경로 재탐색")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue)
                        }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .overlay {
            if !vm.isCompleted {
                ProgressView()
            }
        }
        .onAppear {
            vm.send(.onAppear)
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear{
            UIApplication.shared.isIdleTimerDisabled = false
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
        if vm.isCompleted {
            context.coordinator.addPolyLine()
        } else {
            context.coordinator.deletePolyLine()
        }
    }
    
    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapboxNavigationViewRepresentable
        
        init(parent: MapboxNavigationViewRepresentable) {
            self.parent = parent
        }
        
        func addPolyLine() {
            if let mapboxCoordinates = parent.vm.mapboxCoordinates {
                let polyLine = CustomPolyline(coordinates: mapboxCoordinates, count: mapboxCoordinates.count)
                polyLine.identifier = "Mapbox"
                parent.mapView.addOverlay(polyLine)
            }
            
            if let tmapCoordinates = parent.vm.tmapCoordinates {
                let polyLine = CustomPolyline(coordinates: tmapCoordinates, count: tmapCoordinates.count)
                polyLine.identifier = "tmap"
                parent.mapView.addOverlay(polyLine)
            }
        }
        
        func deletePolyLine() {
            parent.mapView.removeOverlays(parent.mapView.overlays)
        }
        
        func updatePolyLine() {
            deletePolyLine()
            addPolyLine()
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
            switch overlay {
            case let polyline as CustomPolyline:
                let renderer = MKPolylineRenderer(overlay: polyline)
                if polyline.identifier == "Mapbox" {
                    renderer.strokeColor = .blue
                } else {
                    renderer.strokeColor = .red
                }
                renderer.lineWidth = 5
                return renderer
                
            default:
                return MKOverlayRenderer(overlay: overlay)
            }
        }
    }
}

class CustomPolyline: MKPolyline {
    var identifier: String?
}
