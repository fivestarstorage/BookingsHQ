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
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var geocodeTask: Task<Void, Never>?
    
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
                                geocodeAddressWithDebounce(newValue, isPickup: true)
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dropoff Address")
                            .font(.headline)
                        TextField("Enter dropoff address", text: $dropoffAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: dropoffAddress) { newValue in
                                geocodeAddressWithDebounce(newValue, isPickup: false)
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
                        validateAndCreateBooking()
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
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
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
    
    private func geocodeAddressWithDebounce(_ address: String, isPickup: Bool) {
        geocodeTask?.cancel()
        geocodeTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)  //added 5s delay before refresh
            if !Task.isCancelled {
                geocodeAddress(address, isPickup: isPickup)
            }
        }
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
            DispatchQueue.main.async {
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
    }
    
    private func updateMapRegion() {
        if let pickup = pickupLocation, let dropoff = dropoffLocation {
            let centerLat = (pickup.coordinate.latitude + dropoff.coordinate.latitude) / 2
            let centerLon = (pickup.coordinate.longitude + dropoff.coordinate.longitude) / 2

            let latDelta = abs(pickup.coordinate.latitude - dropoff.coordinate.latitude)
            let lonDelta = abs(pickup.coordinate.longitude - dropoff.coordinate.longitude)

            let safeLatDelta = max(latDelta * 1.5, 0.01)
            let safeLonDelta = max(lonDelta * 1.5, 0.01)

            let maxDelta: CLLocationDegrees = 180.0
            let clampedLatDelta = min(safeLatDelta, maxDelta)
            let clampedLonDelta = min(safeLonDelta, maxDelta)

            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                span: MKCoordinateSpan(latitudeDelta: clampedLatDelta, longitudeDelta: clampedLonDelta)
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
    
    private func validateAndCreateBooking() {
        guard let pickup = pickupLocation else {
            showError(message: "Please enter a valid pickup address")
            return
        }
        
        guard let dropoff = dropoffLocation else {
            showError(message: "Please enter a valid dropoff address")
            return
        }
        
        guard isLocationInAustralia(pickup.coordinate) else {
            showError(message: "Pickup address must be within Australia")
            return
        }
        
        guard isLocationInAustralia(dropoff.coordinate) else {
            showError(message: "Dropoff address must be within Australia")
            return
        }
        
        createBooking()
        dismiss()
    }
    
    private func isLocationInAustralia(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        // Australia bounds: roughly -44 to -10 latitude, 113 to 154 longitude
        return latitude >= -44.0 && latitude <= -10.0 && 
               longitude >= 113.0 && longitude <= 154.0
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
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
