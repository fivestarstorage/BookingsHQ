//
//  BookingsHQTests.swift
//  BookingsHQTests
//
//  Created by Riley Martin on 4/9/2025.
//

import Testing
@testable import BookingsHQ
import CoreLocation

struct BookingsHQTests {

    @Test func testBookingLocationInit() {
        let location = BookingLocation(latitude: 1.0, longitude: 2.0, description: "Test")
        #expect(location.coordinate.latitude == 1.0)
        #expect(location.coordinate.longitude == 2.0)
        #expect(location.description == "Test")
    }

    @Test func testBookingInit() {
        let booking = Booking(customerName: "Riley", taskType: .removal)
        #expect(booking.customerName == "Riley")
        #expect(booking.taskType == .removal)
        #expect(booking.status == .pending)
        #expect(booking.estimatedCost == 0.0)
        #expect(booking.isConfirmed == false)
    }

    @Test func testBookingUpdateStatus() {
        let booking = Booking(customerName: "Riley", taskType: .removal)
        booking.updateStatus(.confirmed)
        #expect(booking.status == .confirmed)
    }

    @Test func testBookingCalculateQuote() {
        let booking = Booking(customerName: "Riley", taskType: .removal)
        let quote = booking.calculateQuote()
        #expect(quote >= 100.0)
        #expect(quote <= 500.0)
        #expect(booking.estimatedCost == quote)
    }

    @Test func testBookingConfirmQuote() {
        let booking = Booking(customerName: "Riley", taskType: .removal)
        booking.confirmQuote()
        #expect(booking.isConfirmed == true)
        #expect(booking.status == .confirmed)
    }

    @Test func testRemovalBookingInit() {
        let booking = RemovalBooking(customerName: "Riley", fromAddress: "A", toAddress: "B", itemCount: 5)
        #expect(booking.customerName == "Riley")
        #expect(booking.fromAddress == "A")
        #expect(booking.toAddress == "B")
        #expect(booking.itemCount == 5)
        #expect(booking.taskType == .removal)
    }

    @Test func testRemovalBookingCalculateQuote() {
        let booking = RemovalBooking(customerName: "Riley", fromAddress: "A", toAddress: "B", itemCount: 5)
        let quote = booking.calculateQuote()
        #expect(quote == 225.0)
    }

    @Test func testDeliveryBookingInit() {
        let booking = DeliveryBooking(customerName: "Riley", deliveryAddress: "Address", packageSize: "Large")
        #expect(booking.customerName == "Riley")
        #expect(booking.deliveryAddress == "Address")
        #expect(booking.packageSize == "Large")
        #expect(booking.taskType == .delivery)
    }

    @Test func testDeliveryBookingCalculateQuoteLarge() {
        let booking = DeliveryBooking(customerName: "Riley", deliveryAddress: "Address", packageSize: "Large")
        let quote = booking.calculateQuote()
        #expect(quote == 150.0)
    }

    @Test func testDeliveryBookingCalculateQuoteSmall() {
        let booking = DeliveryBooking(customerName: "Riley", deliveryAddress: "Address", packageSize: "Small")
        let quote = booking.calculateQuote()
        #expect(quote == 75.0)
    }

    @Test func testFakeDataManagerCreateSampleBookings() {
        let bookings = FakeDataManager.shared.createSampleBookings()
        #expect(bookings.count == 3)
    }

    @Test func testBookingViewModelInit() {
        let viewModel = BookingViewModel()
        #expect(viewModel.bookings.count == 3)
        #expect(viewModel.showError == false)
        #expect(viewModel.errorMessage == "")
    }

    @Test func testBookingViewModelCreateBooking() {
        let viewModel = BookingViewModel()
        let initialCount = viewModel.bookings.count
        viewModel.createBooking(customerName: "New Customer", type: .delivery)
        #expect(viewModel.bookings.count == initialCount + 1)
    }

    @Test func testBookingViewModelUpdateBookingStatus() {
        let viewModel = BookingViewModel()
        let booking = viewModel.bookings[0]
        viewModel.updateBookingStatus(booking: booking, status: .confirmed)
        #expect(booking.status == .confirmed)
    }

}
