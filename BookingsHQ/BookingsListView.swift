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
    @State private var selectedStatus: BookingStatus? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // filter tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // all bookings tab
                    Button("All") {
                        selectedStatus = nil
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(selectedStatus == nil ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(selectedStatus == nil ? .white : .primary)
                    .cornerRadius(20)
                    
                    // status filter tabs
                    ForEach(BookingStatus.allCases, id: \.self) { status in
                        Button(status.rawValue) {
                            selectedStatus = status
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedStatus == status ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(selectedStatus == status ? .white : .primary)
                        .cornerRadius(20)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
            
            // filtered list of bookings
            List(filteredBookings, id: \.id) { booking in
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
        }
        .navigationTitle("Bookings")
    }
    
    // filter bookings based on selected status
    private var filteredBookings: [Booking] {
        if let selectedStatus = selectedStatus {
            return bookingViewModel.bookings.filter { $0.status == selectedStatus }
        } else {
            return bookingViewModel.bookings
        }
    }
}
