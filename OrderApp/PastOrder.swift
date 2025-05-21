//
//  PastOrder.swift
//  OrderApp
//
//  Created on 5/17/25.
//

import Foundation

// A model representing a completed order.
// Conforms to Codable for persistence and Identifiable for use in SwiftUI lists.
struct PastOrder: Codable, Identifiable {
    // A unique identifier for this order.
    let id: UUID
    // The menu items included in the order.
    let menuItems: [MenuItem]
    let minutesToPrepare: Int
    let date: Date
  
    let total: Double
    
    //Initializes a new PastOrder with given items and preparation time.
    init(menuItems: [MenuItem], minutesToPrepare: Int) {
        
        // Generates a unique id and captures the current date, also calculates total.
        self.id = UUID()
        self.menuItems = menuItems
        self.minutesToPrepare = minutesToPrepare
        self.date = Date()
        self.total = menuItems.reduce(0.0) { $0 + $1.price }
    }
}

// Manages the persistence and retrieval of past orders: Uses an instance for global access.
class OrderHistory {
    // Shared as instance to access order history.
    static let shared = OrderHistory()
    
    // UserDefaults key for storing the array of past orders.
    private let pastOrdersKey = "pastOrders"
    
    // In-memory cache of past orders; saving occurs on change.
    private(set) var pastOrders: [PastOrder] = [] {
        didSet {
            savePastOrders()
        }
    }
    
    // Loads saved past orders when the manager is initialized.
    init() {
        loadPastOrders()
    }
    
    // Adds a new order to the beginning of the history and posts a notification.
    func addOrder(_ order: PastOrder) {
        pastOrders.insert(order, at: 0) // Add to beginning so newest is first
        NotificationCenter.default.post(name: .pastOrderAdded, object: nil)
    }
    
    // Attempts to load past orders from UserDefaults.
    private func loadPastOrders() {
        guard let data = UserDefaults.standard.data(forKey: pastOrdersKey) else { return }
        
        do {
            let decoder = JSONDecoder()
            pastOrders = try decoder.decode([PastOrder].self, from: data)
        } catch {
            print("Error loading past orders: \(error.localizedDescription)")
        }
    }
    
    // Encodes and saves the current past orders to UserDefaults.
    private func savePastOrders() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(pastOrders)
            UserDefaults.standard.set(data, forKey: pastOrdersKey)
        } catch {
            print("Error saving past orders: \(error.localizedDescription)")
        }
    }
}

// Notification names used within the OrderApp.
extension Notification.Name {
    // Posted when a new past order is added to history.
    static let pastOrderAdded = Notification.Name("pastOrderAdded")
}
