//
//  BookingsListView.swift
//  BookingsHQ
//
//  Created by Riley Martin on 4/9/2025.
//

import SwiftUI

// view to display list of bookings
struct BookingsListView: View {
    @ObservedObject var bookingViewModel: BookingViewModel
    
    var body: some View {
        // list of all bookings
        List(bookingViewModel.bookings, id: \.id) { booking in
            NavigationLink(destination: BookingDetailView(booking: booking)) {
                VStack(alignment: .leading, spacing: 8) {
                    // customer name and status
                    HStack {
                        Text(booking.customerName)
                            .font(.headline)
                        Spacer()
                        Text(booking.status.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(booking.status == .pending ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    // booking description
                    Text(booking.description.isEmpty ? "No description" : booking.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // cost
                    HStack {
                        Text("$\(booking.estimatedCost, specifier: "%.0f")")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Bookings")
    }
}
