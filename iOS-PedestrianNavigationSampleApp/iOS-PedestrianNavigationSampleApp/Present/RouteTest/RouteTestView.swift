//
//  RouteTestView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 10/21/24.
//

import SwiftUI
import MapKit
import UIKit

struct RouteTestView: View {
    
    @StateObject private var vm: RouteTestViewModel
    
    init(_ destination: SearchResultModel) {
        self._vm = .init(wrappedValue: .init(destination: destination))
    }
    
    var body: some View {
        ZStack {
            RouteTestMapView(vm: vm)
                .task {
                    vm.send(.onAppear)
                }
            
            VStack {
                Spacer()
                HStack {
                    Button {
                        vm.send(.changeIndex(false))
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.white)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.blue)
                            }
                    }
                    
                    Button {
                        vm.send(.goRoute)
                    } label: {
                        Text("go route")
                            .font(.system(.title2, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.blue)
                            }
                    }
                    
                    Button {
                        vm.send(.changeIndex(true))
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.blue)
                            }
                    }
                }
                
            }
            .padding(16)
        }
        
    }
}


struct RouteTestMapView: UIViewRepresentable {
    let mapView: MKMapView
    @ObservedObject var vm: RouteTestViewModel
    
    init(vm: RouteTestViewModel) {
        self.mapView = MKMapView(frame: .zero)
        self.vm = vm
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> some UIView {
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.touchEvent))
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.addGestureRecognizer(tapGesture)
        
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.updateView()
    }
    
    
    final class Coordinator: NSObject, MKMapViewDelegate {
        let parent: RouteTestMapView
        
        
        
        init(parent: RouteTestMapView) {
            self.parent = parent
        }
        
        @objc func touchEvent(_ sender: UITapGestureRecognizer) {
            let point = sender.location(in: parent.mapView)
            let location = parent.mapView.convert(point, toCoordinateFrom: parent.mapView)
            
            parent.vm.send(.touchEvent(location))
        }
        
        func setCamera() {
            if let currentLocation = parent.vm.currentLocation {
                let camera = MKMapCamera()
                camera.centerCoordinate = currentLocation.coordinate
                camera.centerCoordinateDistance = 500
                parent.mapView.camera = camera
            }
        }
        
        func updateView() {
            setCamera()
            updatePolyLine()
            updateAnnotation()
        }
        
        func updateAnnotation() {
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            if let currentLocation = parent.vm.currentLocation {
                let currentAnnotation = MKPointAnnotation()
                currentAnnotation.coordinate = currentLocation.coordinate
                currentAnnotation.title = "Current"
                parent.mapView.addAnnotation(currentAnnotation)
            }
            
            let closeAnnotation = MKPointAnnotation()
            closeAnnotation.coordinate = parent.vm.closePoint
            closeAnnotation.title = "Close"
            parent.mapView.addAnnotation(closeAnnotation)
        }
        
        func updatePolyLine() {
            deletePolyLine()
            addPolyLine()
        }
        
        func deletePolyLine() {
            parent.mapView.removeOverlays(parent.mapView.overlays)
        }
        
        func addPolyLine() {
            if let currentPolyLine = parent.vm.currentPolyline {
                parent.mapView.addOverlay(currentPolyLine)
            }
            if let nextPolylines = parent.vm.nextPolylines {
                parent.mapView.addOverlay(nextPolylines)
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
            switch overlay {
            case let overlay as ColorPolyline:
                let renderer = MKPolylineRenderer(overlay: overlay)
                renderer.strokeColor = overlay.color
                renderer.lineWidth = 5
                return renderer
                
            default:
                return MKPolylineRenderer(overlay: overlay)
            }
        }
    }
}

extension UIColor {
    func getRandomColor() -> UIColor {
        let red: CGFloat = .random(in: 0...1)
        let green: CGFloat = .random(in: 0...1)
        let blue: CGFloat = .random(in: 0...1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
