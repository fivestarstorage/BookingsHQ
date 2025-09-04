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
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            // list of all bookings
            List(bookingViewModel.bookings, id: \.id) { booking in
                VStack(alignment: .leading, spacing: 8) {
                    // customer name and task type
                    HStack {
                        Text(booking.customerName)
                            .font(.headline)
                        Spacer()
                        Text(booking.taskType.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    // booking description
                    Text(booking.description.isEmpty ? "No description" : booking.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // status and cost
                    HStack {
                        Text("Status: \(booking.status.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("$\(booking.estimatedCost, specifier: "%.0f")")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Bookings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
