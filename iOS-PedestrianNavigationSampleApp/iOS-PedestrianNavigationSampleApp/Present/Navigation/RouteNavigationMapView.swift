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
        // 현재 위치가 변경때마다 PolylineUpdate
        if !viewModel.isLoading {
            context.coordinator.updatePolyLine()
            // TODO: Gesture로 지도 이동 시, Camera update 를 일정시간 막아두기
            // 현재 위치의 변경때마다 카메라 follow
            context.coordinator.updateCamera()
        }
    }
    
    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RouteNavigationMapView
        
        init(parent: RouteNavigationMapView) {
            self.parent = parent
        }
        
        /// ViewModel 에 할당된 navigationModel 배열을 활용하여 루트를 표시하는 Polyline 추가
        func addPolyLine() {
            if let currentPolyLine = parent.viewModel.currentPolyline {
                parent.mapView.addOverlay(currentPolyLine)
            }
            parent.mapView.addOverlay(parent.viewModel.nextPolylines)
        }
        
        
        // TODO: Update 로직의 최적화
        /// 현재위치가 업데이트 될 때마다, Polyline을 삭제 후 새로운 상태로 추가
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
