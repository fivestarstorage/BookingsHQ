//
//  ViewModels.swift
//  BookingsHQ
//
//  Created by Riley Martin on 4/9/2025.
//

import Foundation
import SwiftUI

// viewmodel for managing bookings data
class BookingViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var showError = false
    @Published var errorMessage = ""
    
    // initialize with fake data
    init() {
        loadFakeData()
    }
    
    // load sample bookings from fake data manager
    private func loadFakeData() {
        bookings = FakeDataManager.shared.createSampleBookings()
    }
    
    // create a new booking and add to list
    func createBooking(customerName: String, type: TaskType) {
        let booking = Booking(customerName: customerName, taskType: type)
        bookings.append(booking)
    }
    
    // update the status of an existing booking
    func updateBookingStatus(booking: Booking, status: BookingStatus) {
        booking.updateStatus(status)
        objectWillChange.send()
    }
    
    // calculate quote for a booking
    func calculateQuote(for booking: Booking) {
        let quote = booking.calculateQuote()
        objectWillChange.send()
    }
}
