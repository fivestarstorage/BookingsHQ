//
//  Models.swift
//  BookingsHQ
//
//  Created by Riley Martin on 4/9/2025.
//

import Foundation

// base booking class that implements both protocols
class Booking: Bookable, Quotable, ObservableObject {
    let id = UUID()
    @Published var customerName: String
    @Published var status: BookingStatus
    @Published var estimatedCost: Double
    @Published var isConfirmed: Bool
    let createdDate = Date()
    
    var taskType: TaskType
    var description: String
    
    // initialize a new booking
    init(customerName: String, taskType: TaskType, description: String = "") {
        self.customerName = customerName
        self.taskType = taskType
        self.description = description
        self.status = .pending
        self.estimatedCost = 0.0
        self.isConfirmed = false
    }
    
    // change the booking status
    func updateStatus(_ newStatus: BookingStatus) {
        status = newStatus
    }
    
    // calculate a random quote
    func calculateQuote() -> Double {
        estimatedCost = Double.random(in: 100...500)
        return estimatedCost
    }
    
    // confirm the quote and update status
    func confirmQuote() {
        isConfirmed = true
        status = .confirmed
    }
}

// removal booking with specific properties
class RemovalBooking: Booking {
    var fromAddress: String
    var toAddress: String
    var itemCount: Int
    
    // initialize removal booking with addresses
    init(customerName: String, fromAddress: String, toAddress: String, itemCount: Int) {
        self.fromAddress = fromAddress
        self.toAddress = toAddress
        self.itemCount = itemCount
        super.init(customerName: customerName, taskType: .removal)
    }
    
    // calculate quote based on item count
    override func calculateQuote() -> Double {
        estimatedCost = Double(itemCount) * 25.0 + 100.0
        return estimatedCost
    }
}

// delivery booking with package details
class DeliveryBooking: Booking {
    var deliveryAddress: String
    var packageSize: String
    
    // initialize delivery booking with address and size
    init(customerName: String, deliveryAddress: String, packageSize: String) {
        self.deliveryAddress = deliveryAddress
        self.packageSize = packageSize
        super.init(customerName: customerName, taskType: .delivery)
    }
    
    // calculate quote based on package size
    override func calculateQuote() -> Double {
        let baseCost = packageSize == "Large" ? 150.0 : 75.0
        estimatedCost = baseCost
        return estimatedCost
    }
}

// manages fake data for testing
class FakeDataManager {
    static let shared = FakeDataManager()
    
    private init() {}
    
    // create sample bookings with fake data
    func createSampleBookings() -> [Booking] {
        let bookings = [
            RemovalBooking(customerName: "Riley Martin", fromAddress: "123 Main St", toAddress: "456 Oak Ave", itemCount: 5),
            DeliveryBooking(customerName: "Firas Al-Doghman", deliveryAddress: "789 Pine St", packageSize: "Large"),
            Booking(customerName: "Mike Tyson", taskType: .transport, description: "Piano transport")
        ]
        
        // calculate quotes for all bookings
        bookings[0].calculateQuote()
        bookings[1].calculateQuote()
        bookings[2].calculateQuote()
        
        return bookings
    }
}
