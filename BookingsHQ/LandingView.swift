//
//  LandingView.swift
//  BookingsHQ
//
//  Created by Riley Martin on 4/9/2025.
//

import SwiftUI

// main landing page view
struct LandingView: View {
    @StateObject private var bookingViewModel = BookingViewModel()
    @State private var showBookings = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // app title and description
            VStack(spacing: 20) {
                Text("BookingsHQ")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Book and manage removal jobs with transparent quotes and real-time tracking")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // action buttons
            VStack(spacing: 16) {
                // button to show bookings list
                Button(action: {
                    showBookings = true
                }) {
                    Text("View Bookings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showBookings) {
                    BookingsListView(bookingViewModel: bookingViewModel)
                }
                
                // placeholder button for creating bookings
                Button(action: {
                }) {
                    Text("Create Booking")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .background(Color(.systemBackground))
    }
}
