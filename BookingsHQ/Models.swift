//
//  Models.swift
//  BookingsHQ
//
//  Created by Riley Martin on 4/9/2025.
//

import Foundation
import Combine
import CoreLocation

// location of pickup or dropoff with coordinates and description
struct BookingLocation {
    var coordinate: CLLocationCoordinate2D
    var description: String
    
    init(latitude: Double, longitude: Double, description: String) {
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.description = description
    }
}

// base booking class that implements both protocols
class Booking: Bookable, Quotable, ObservableObject {
    let id = UUID()
    @Published var customerName: String
    @Published var status: BookingStatus
    @Published var estimatedCost: Double
    @Published var isConfirmed: Bool
    let createdDate = Date()
    
    var taskType: TaskType
    var title: String
    var description: String
    @Published var pickupLocation: BookingLocation?
    @Published var dropoffLocation: BookingLocation?
    
    // add new bookings
    init(customerName: String, taskType: TaskType, title: String = "", description: String = "", pickupLocation: BookingLocation? = nil, dropoffLocation: BookingLocation? = nil) {
        self.customerName = customerName
        self.taskType = taskType
        self.title = title
        self.description = description
        self.pickupLocation = pickupLocation
        self.dropoffLocation = dropoffLocation
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
    init(customerName: String, fromAddress: String, toAddress: String, itemCount: Int, title: String = "", pickupLocation: BookingLocation? = nil, dropoffLocation: BookingLocation? = nil) {
        self.fromAddress = fromAddress
        self.toAddress = toAddress
        self.itemCount = itemCount
        super.init(customerName: customerName, taskType: .removal, title: title, pickupLocation: pickupLocation, dropoffLocation: dropoffLocation)
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
    init(customerName: String, deliveryAddress: String, packageSize: String, title: String = "", pickupLocation: BookingLocation? = nil, dropoffLocation: BookingLocation? = nil) {
        self.deliveryAddress = deliveryAddress
        self.packageSize = packageSize
        super.init(customerName: customerName, taskType: .delivery, title: title, pickupLocation: pickupLocation, dropoffLocation: dropoffLocation)
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
    
    // sample bookings with fake data
    func createSampleBookings() -> [Booking] {
        let pickup1 = BookingLocation(latitude: -33.8688, longitude: 151.2093, description: "123 George St, Sydney CBD")
        let dropoff1 = BookingLocation(latitude: -33.8650, longitude: 151.2094, description: "456 Pitt St, Sydney CBD")
        
        let pickup2 = BookingLocation(latitude: -33.8700, longitude: 151.2070, description: "Circular Quay")
        let dropoff2 = BookingLocation(latitude: -33.8620, longitude: 151.2110, description: "789 Market St, Sydney CBD")
        
        let pickup3 = BookingLocation(latitude: -33.8730, longitude: 151.2065, description: "Opera House")
        let dropoff3 = BookingLocation(latitude: -33.8600, longitude: 151.2120, description: "Town Hall")
        
        let bookings = [
            RemovalBooking(customerName: "Riley Martin", fromAddress: "123 Main St", toAddress: "456 Oak Ave", itemCount: 5, title: "House Removal - CBD to Suburbs", pickupLocation: pickup1, dropoffLocation: dropoff1),
            DeliveryBooking(customerName: "Firas Al-Doghman", deliveryAddress: "789 Pine St", packageSize: "Large", title: "Large Package Delivery", pickupLocation: pickup2, dropoffLocation: dropoff2),
            Booking(customerName: "Mike Tyson", taskType: .transport, title: "Piano Transport Service", description: "Professional piano transport from Opera House to Town Hall. Requires specialized equipment and careful handling. Piano is a Steinway grand piano weighing approximately 480kg. Access via stairs at pickup location.", pickupLocation: pickup3, dropoffLocation: dropoff3)
        ]
        
        // add descriptions to bookings
        bookings[0].description = "Complete house removal service from CBD apartment to suburban home. Items include furniture, appliances, and personal belongings. Requires 2-3 movers and large truck. Special care needed for antique dining table and fragile items."
        
        bookings[1].description = "Large package delivery containing office equipment and supplies. Package dimensions: 2m x 1.5m x 1m. Weight approximately 85kg. Requires careful handling and may need assistance at delivery location."
        
        // set one booking to inProgress for testing
        bookings[1].updateStatus(.inProgress)
        
        // calculate quotes for all bookings
        bookings[0].calculateQuote()
        bookings[1].calculateQuote()
        bookings[2].calculateQuote()
        
        return bookings
    }
}
