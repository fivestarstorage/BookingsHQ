//
//  BookingDetailView.swift
//  BookingsHQ
//
//  Created by Riley Martin on 4/9/2025.
//

import SwiftUI
import MapKit

struct LocationAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let isPinP: Bool
}
struct BookingDetailView: View {
    @ObservedObject var booking: Booking
    @State private var editedDescription: String = ""
    @State private var region = MKCoordinateRegion()
    @State private var selectedPinDescription: String = ""
    @State private var showPinDescription = false
    @State private var showCompletionNotes = false
    @State private var completionNotes = ""
    
    var body: some View {
        // put it in  a scrollview so it doesnt go off the page.
        ScrollView {
            VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(booking.title.isEmpty ? "Untitled Booking" : booking.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                
                Text(booking.customerName)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                Text(booking.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(booking.status == .pending ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                    .cornerRadius(12)
            }
   
            
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.headline)
                TextEditor(text: $editedDescription)
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
                        Button(action: {
                            if annotation.isPinP {
                                selectedPinDescription = booking.pickupLocation?.description ?? "Pickup location"
                            } else {
                                selectedPinDescription = booking.dropoffLocation?.description ?? "Dropoff location"
                            }
                            showPinDescription = true
                        }) {
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
                }
                .frame(height: 200)
                .cornerRadius(10)
            }
            //accidentally made the buttons appear for wrong status.
            if booking.status == .pending {
                VStack(spacing: 12) {
                    Button("Confirm Booking") {
                        booking.description = editedDescription
                        booking.updateStatus(.confirmed)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                    
                    Button("Decline Booking") {
                        booking.description = editedDescription
                        booking.updateStatus(.cancelled)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                }
            }
            
            if booking.status == .confirmed {
                Button("Start Job") {
                    booking.description = editedDescription
                    booking.updateStatus(.inProgress)
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
            
            if booking.status == .inProgress {
                Button("Complete Job") {
                    showCompletionNotes = true
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
            }
            
            if booking.status == .completed && !booking.completionNotes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Completion Notes")
                        .font(.headline)
                    Text(booking.completionNotes)
                        .frame(height: 200, alignment: .topLeading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                }
            }
            
            }
            .padding()
        }
        .navigationTitle("Edit Booking")
        .onAppear {
            editedDescription = booking.description
            setupMapRegion()
        }
        .alert("Location Details", isPresented: $showPinDescription) {
            Button("OK") { }
        } message: {
            Text(selectedPinDescription)
        }
        .sheet(isPresented: $showCompletionNotes) {
            CompletionNotesView(
                completionNotes: $completionNotes,
                onSave: {
                    booking.description = editedDescription
                    booking.completionNotes = completionNotes
                    booking.updateStatus(.completed)
                },
                onCancel: {
                    completionNotes = ""
                }
            )
        }
    }
    
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
