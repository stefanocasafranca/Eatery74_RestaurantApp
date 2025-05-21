//
//  OrderedFoodTableViewController.swift
//  OrderApp
//
//  Created on 5/17/25.
//

import UIKit

class OrderedFoodTableViewController: UITableViewController {
    
    // Grab the shared order history instance shared inside the class OrderHistory.
    let orderHistory = OrderHistory.shared
    // Keep track of async image loads so we can cancel when needed.
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Listen for new orders to reload the table.
        NotificationCenter.default.addObserver(
            tableView!,
            selector: #selector(UITableView.reloadData),
            name: .pastOrderAdded,
            object: nil
        )
    }
    
    // When this view goes away, cancel all image loads.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Cancel any image loading tasks when the view disappears
        imageLoadTasks.forEach { _, task in task.cancel() }
    }
    
    // Data source methods below.
    // MARK: - Table view data source
    
    // One section per past order.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return orderHistory.pastOrders.count
    }
    
    // Rows equal number of items in the order.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderHistory.pastOrders[section].menuItems.count
    }
    
    // Build cell: name, price, and async image.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue reusable cell for menu item.
        let cell = tableView.dequeueReusableCell(withIdentifier: "PastOrderItem", for: indexPath)
        
        // Ensure cell is our custom MenuItemCell.
        guard let cell = cell as? MenuItemCell else { return cell }
        
        // Pull the right order and item for this row.
        // Configure the cell with the menu item
        let pastOrder = orderHistory.pastOrders[indexPath.section]
        let menuItem = pastOrder.menuItems[indexPath.row]
        
        // Set the item name label.
        cell.itemName = menuItem.name
        // Set the price label.
        cell.price = menuItem.price
        // Reset image before loading.
        cell.image = nil
        
        // Kick off async image fetch.
        imageLoadTasks[indexPath] = Task.init {
            if let image = try? await MenuController.shared.fetchImage(from: menuItem.imageURL) {
                if let currentIndexPath = self.tableView.indexPath(for: cell),
                    currentIndexPath == indexPath {
                    cell.image = image
                }
            }
            imageLoadTasks[indexPath] = nil
        }
        
        return cell
    }
    
    // Header title shows date and prep time.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let pastOrder = orderHistory.pastOrders[section]
        // Format date display.
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let dateString = dateFormatter.string(from: pastOrder.date)
        // Format total cost as currency (unused here).
        _ = pastOrder.total.formatted(.currency(code: "usd"))
        // Build the header string.
        return "Order from \(dateString) - \(pastOrder.minutesToPrepare) min"
    }
    
    // Cleanup: cancel image load for off-screen cells.
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Cancel image loading tasks for cells that are no longer visible
        imageLoadTasks[indexPath]?.cancel()
    }
}
