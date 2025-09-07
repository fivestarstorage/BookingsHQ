//
//  BookingDetailView.swift
//  BookingsHQ
//
//  Created by Riley Martin on 4/9/2025.
//

import SwiftUI
import MapKit

// map annotation for pickup and dropoff pins
struct LocationAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let isPinP: Bool
}

// view to edit booking details
struct BookingDetailView: View {
    @ObservedObject var booking: Booking
    @State private var editedName: String = ""
    @State private var editedDescription: String = ""
    @State private var region = MKCoordinateRegion()
    
    var body: some View {
        VStack(spacing: 20) {
            // name field
            VStack(alignment: .leading, spacing: 8) {
                Text("Customer Name")
                    .font(.headline)
                TextField("Enter name", text: $editedName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // description field
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.headline)
                TextField("Enter description", text: $editedDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // map view
            VStack(alignment: .leading, spacing: 8) {
                Text("Pickup/Dropoff Locations")
                    .font(.headline)
                Map(coordinateRegion: $region, annotationItems: mapAnnotations()) { annotation in
                    MapAnnotation(coordinate: annotation.coordinate) {
                        ZStack {
                            Circle()
                                .fill(annotation.isPinP ? Color.green : Color.red)
                                .frame(width: 30, height: 30)
                            Text(annotation.isPinP ? "P" : "D")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(height: 200)
                .cornerRadius(10)
            }
            
            // save button
            Button("Save Changes") {
                booking.customerName = editedName
                booking.description = editedDescription
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Edit Booking")
        .onAppear {
            editedName = booking.customerName
            editedDescription = booking.description
            setupMapRegion()
        }
    }
    
    // create map annotations for pickup and dropoff
    private func mapAnnotations() -> [LocationAnnotation] {
        var annotations: [LocationAnnotation] = []
        
        if let pickup = booking.pickupLocation {
            annotations.append(LocationAnnotation(coordinate: pickup.coordinate, isPinP: true))
        }
        
        if let dropoff = booking.dropoffLocation {
            annotations.append(LocationAnnotation(coordinate: dropoff.coordinate, isPinP: false))
        }
        
        return annotations
    }
    
    // setup map region to show both pickup and dropoff
    private func setupMapRegion() {
        guard let pickup = booking.pickupLocation,
              let dropoff = booking.dropoffLocation else {
            return
        }
        
        let centerLat = (pickup.coordinate.latitude + dropoff.coordinate.latitude) / 2
        let centerLon = (pickup.coordinate.longitude + dropoff.coordinate.longitude) / 2
        
        let latDelta = abs(pickup.coordinate.latitude - dropoff.coordinate.latitude) * 1.5
        let lonDelta = abs(pickup.coordinate.longitude - dropoff.coordinate.longitude) * 1.5
        
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: max(latDelta, 0.01), longitudeDelta: max(lonDelta, 0.01))
        )
    }
}
