//
//  CoreMotionTestView.swift
//  iOS-PedestrianNavigationSampleApp
//
//  Created by Sooik Kim on 10/7/24.
//

import SwiftUI
import MapKit

struct CoreMotionTestView: View {
    
    @StateObject var viewModel: CoremotionViewModel = .init()
    @State private var mapView: MKMapView = .init(frame: .zero)
    
    var body: some View {
        ZStack {
            CoreMotionTestMapView(viewModel: viewModel, mapView: $mapView)
            VStack {
                VStack {
                    Text("\(Int((viewModel.currentLocation?.speed ?? 0) * 3.6)) km/h")
                    Text("Accuracy: \(viewModel.currentLocation?.horizontalAccuracy ?? 0)")
                    Text("annotaion Count: \(viewModel.addAnnotationCount)")
                }
                
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 8)
                        .fill(viewModel.isCurrentLocationReliable ? .blue : .red)
                }
                Spacer()
            }
            .padding()
        }
        
    }
}

struct CoreMotionTestMapView: UIViewRepresentable {
    @ObservedObject var viewModel: CoremotionViewModel
    @Binding var mapView: MKMapView
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel, mapView: $mapView)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        context.coordinator.updateAnnotation()
    }
    
    final class Coordinator: NSObject, MKMapViewDelegate {
        @ObservedObject var viewModel: CoremotionViewModel
        @Binding var mapView: MKMapView
        
        var expectedAnnotation: MKAnnotation?
        var currentAnnotation: UserAnnotation?
        
        init(viewModel: CoremotionViewModel, mapView: Binding<MKMapView>) {
            self.viewModel = viewModel
            self._mapView = mapView
        }
        
        func updateAnnotation() {
            if let expectedLocation = viewModel.exepectedLocation {
                if let expectedAnnotation {
                    mapView.removeAnnotation(expectedAnnotation)
                }
                let newAnnotation = MKPointAnnotation()
                newAnnotation.coordinate = expectedLocation.coordinate
                newAnnotation.title = "Customized Location"
                self.expectedAnnotation = newAnnotation
                mapView.addAnnotation(self.expectedAnnotation!)
                print("exepected annotation 추가 \(expectedLocation.coordinate), \(viewModel.currentLocation?.coordinate)")
            }
        }
    }
}

#Preview {
    CoreMotionTestView()
}
