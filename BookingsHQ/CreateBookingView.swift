//
//  CreateBookingView.swift
//  BookingsHQ
//
//  Created by Riley Martin on 4/9/2025.
//

import SwiftUI
import MapKit

struct CreateBookingView: View {
    @ObservedObject var bookingViewModel: BookingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var customerName = ""
    @State private var title = ""
    @State private var description = ""
    @State private var pickupAddress = ""
    @State private var dropoffAddress = ""
    @State private var region = MKCoordinateRegion()
    @State private var pickupLocation: BookingLocation?
    @State private var dropoffLocation: BookingLocation?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Customer Name")
                            .font(.headline)
                        TextField("Enter customer name", text: $customerName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Booking Title")
                            .font(.headline)
                        TextField("Enter booking title", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pickup Address")
                            .font(.headline)
                        TextField("Enter pickup address", text: $pickupAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: pickupAddress) { newValue in
                                geocodeAddress(newValue, isPickup: true)
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dropoff Address")
                            .font(.headline)
                        TextField("Enter dropoff address", text: $dropoffAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: dropoffAddress) { newValue in
                                geocodeAddress(newValue, isPickup: false)
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        TextEditor(text: $description)
                            .frame(height: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pickup/Dropoff Locations")
                            .font(.headline)
                        Map(coordinateRegion: $region, interactionModes: [], annotationItems: mapAnnotations()) { annotation in
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
                    
                    Button("Create Booking") {
                        createBooking()
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(customerName.isEmpty || title.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(10)
                    .disabled(customerName.isEmpty || title.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Create Booking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                setupDefaultRegion()
            }
        }
    }
    
    private func mapAnnotations() -> [LocationAnnotation] {
        var annotations: [LocationAnnotation] = []
        
        if let pickup = pickupLocation {
            annotations.append(LocationAnnotation(coordinate: pickup.coordinate, isPinP: true))
        }
        
        if let dropoff = dropoffLocation {
            annotations.append(LocationAnnotation(coordinate: dropoff.coordinate, isPinP: false))
        }
        
        return annotations
    }
    
    private func geocodeAddress(_ address: String, isPickup: Bool) {
        guard !address.isEmpty else {
            if isPickup {
                pickupLocation = nil
            } else {
                dropoffLocation = nil
            }
            updateMapRegion()
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard let placemark = placemarks?.first,
                  let coordinate = placemark.location?.coordinate else {
                return
            }
            
            let location = BookingLocation(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                description: address
            )
            
            if isPickup {
                pickupLocation = location
            } else {
                dropoffLocation = location
            }
            
            updateMapRegion()
        }
    }
    
    private func updateMapRegion() {
        if let pickup = pickupLocation, let dropoff = dropoffLocation {
            let centerLat = (pickup.coordinate.latitude + dropoff.coordinate.latitude) / 2
            let centerLon = (pickup.coordinate.longitude + dropoff.coordinate.longitude) / 2
            
            let latDelta = abs(pickup.coordinate.latitude - dropoff.coordinate.latitude) * 1.5
            let lonDelta = abs(pickup.coordinate.longitude - dropoff.coordinate.longitude) * 1.5
            
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                span: MKCoordinateSpan(latitudeDelta: max(latDelta, 0.01), longitudeDelta: max(lonDelta, 0.01))
            )
        } else if let pickup = pickupLocation {
            region = MKCoordinateRegion(
                center: pickup.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        } else if let dropoff = dropoffLocation {
            region = MKCoordinateRegion(
                center: dropoff.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    private func setupDefaultRegion() {
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
    
    private func createBooking() {
        let booking = Booking(
            customerName: customerName,
            taskType: .transport,
            title: title,
            description: description,
            pickupLocation: pickupLocation,
            dropoffLocation: dropoffLocation
        )
        bookingViewModel.bookings.append(booking)
    }
}
