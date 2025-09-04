//
//  Protocols.swift
//  BookingsHQ
//
//  Created by Riley Martin on 4/9/2025.
//

import Foundation

// protocol for booking functionality
protocol Bookable {
    var id: UUID { get }
    var customerName: String { get set }
    var status: BookingStatus { get set }
    var createdDate: Date { get }
    func updateStatus(_ newStatus: BookingStatus)
}

// protocol for quote calculations
protocol Quotable {
    var estimatedCost: Double { get set }
    var isConfirmed: Bool { get set }
    func calculateQuote() -> Double
    func confirmQuote()
}

// different states a booking can be in
enum BookingStatus: String, CaseIterable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case inProgress = "In Progress"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

// types of tasks available
enum TaskType: String, CaseIterable {
    case removal = "Removal"
    case delivery = "Delivery"
    case transport = "Transport"
}
