//
//  BookingDetailView.swift
//  BookingsHQ
//
//  Created by Riley Martin on 4/9/2025.
//

import SwiftUI

// view to edit booking details
struct BookingDetailView: View {
    @ObservedObject var booking: Booking
    @State private var editedName: String = ""
    @State private var editedDescription: String = ""
    
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
        }
    }
}
