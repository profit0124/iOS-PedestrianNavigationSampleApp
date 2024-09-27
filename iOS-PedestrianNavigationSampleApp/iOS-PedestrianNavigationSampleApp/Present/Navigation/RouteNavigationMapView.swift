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
        mapView.showsUserLocation = false
        mapView.addAnnotation(GoalAnnotation(coordinate: .init(latitude: viewModel.destination.lat, longitude: viewModel.destination.long)))
        context.coordinator.addPolyLine()
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 현재 위치가 변경때마다 PolylineUpdate
        if !viewModel.isLoading {
            context.coordinator.updatePolyLine()
            // TODO: Gesture로 지도 이동 시, Camera update 를 일정시간 막아두기
            // 현재 위치의 변경때마다 카메라 follow
            context.coordinator.updateAnnotations()
            context.coordinator.userTrackingMode()
        }
    }
    
    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RouteNavigationMapView
        var close: CloseAnnotation = .init(coordinate: CLLocationCoordinate2D())
        var user: UserAnnotation = .init(coordinate: CLLocationCoordinate2D())
        
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
            
            if !parent.viewModel.isFinished {
                addPolyLine()
            }
        }
        
        func updateAnnotations() {
            parent.mapView.removeAnnotation(close)
            parent.mapView.removeAnnotation(user)
            
            close.coordinate = parent.viewModel.closePoint
            user.coordinate = parent.viewModel.currentLocation?.coordinate ?? CLLocationCoordinate2D()
            
            parent.mapView.addAnnotation(close)
            parent.mapView.addAnnotation(user)
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
                let camera = MKMapCamera()
                camera.centerCoordinate = location.coordinate
                camera.heading = location.course
                camera.centerCoordinateDistance = location.altitude * 3
                parent.mapView.camera = camera
            }
        }
        
        func userTrackingMode() {
            if parent.viewModel.userTrackingMode, let coordinator = parent.viewModel.currentLocation {
                let camera = MKMapCamera()
                camera.centerCoordinate = coordinator.coordinate
                camera.heading = coordinator.course
                camera.centerCoordinateDistance = 500
                parent.mapView.camera = camera
            }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
            switch annotation {
            case let goal as GoalAnnotation:
                let view = MKAnnotationView(frame: .init(x: 0, y: 0, width: 40, height: 40))
                view.image = UIImage(systemName: goal.imageName)
                return view
            case let close as CloseAnnotation:
                let view = MKAnnotationView(frame: .init(x: 0, y: 0, width: 40, height: 40))
                view.image = UIImage(systemName: close.imageName)
                return view
            case let user as UserAnnotation:
                let view = MKAnnotationView(frame: .init(x: 0, y: 0, width: 40, height: 40))
                view.image = UIImage(systemName: user.imageName)
                return view
            default:
                return nil
            }
        
            
        }
    }
}


class GoalAnnotation: NSObject, MKAnnotation {
    let imageName: String = "house.circle"
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}

class CloseAnnotation: NSObject, MKAnnotation {
    let imageName: String = "person.crop.circle.dashed"
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}

class UserAnnotation: NSObject, MKAnnotation {
    let imageName: String = "figure.walk"
    var coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}

