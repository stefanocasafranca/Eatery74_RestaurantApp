//
//  OrderTableViewController.swift
//  OrderApp
//
//  Created by Stefano Casafranca on 5/3/25.
//

import UIKit

@MainActor
class OrderTableViewController: UITableViewController {
    
    // ------------Step 9 ---------------
    var minutesToPrepareOrder = 0
    // ------------Step 10 ---------------
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]

        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Making the edit button available
        navigationItem.leftBarButtonItem = editButtonItem
        
        
        
        //For Adding and order and bringing the notification from MenuController.swift
        NotificationCenter.default.addObserver(tableView!, selector: #selector(UITableView.reloadData), name: MenuController.orderUpdatedNotification,object:nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // cancel the image fetching tasks that are no longer needed
        imageLoadTasks.forEach { key, value in value.cancel() }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MenuController.shared.order.menuItems.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Using the Reusable Identifier MenuItem set in Main.Storyboard cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "order", for: indexPath)
        //using the function created
        configure(cell, forItemAt: indexPath)
        return cell
    }
    
    /*Before
    //Function to let the content change depending on the JSON file names and prices
    func configure(_ cell: UITableViewCell, forItemAt indexPath: IndexPath){
        let menuItem = MenuController.shared.order.menuItems[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = menuItem.name
        content.secondaryText = menuItem.price.formatted(.currency(code:"usd"))
        
        //Adding a placeholder image
        content.image = UIImage(systemName: "photo.on.rectangle.angled.fill")
        
        cell.contentConfiguration = content
    }*/
    
    func configure(_ cell: UITableViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MenuItemCell else { return }
        
        let menuItem = MenuController.shared.order.menuItems[indexPath.row]
        
        cell.itemName = menuItem.name
        cell.price = menuItem.price
        cell.image = nil
        
        imageLoadTasks[indexPath] = Task.init {
            if let image = try? await MenuController.shared.fetchImage(from: menuItem.imageURL) {
                if let currentIndexPath = self.tableView.indexPath(for: cell),
                    currentIndexPath == indexPath {
                    cell.image = image
                }
            }
            imageLoadTasks[indexPath] = nil
        }
    }
    
    //Making the swipe left to delete option
    // Override? to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override? to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            MenuController.shared.order.menuItems.remove(at: indexPath.row)
        }
    }
    
   
    
    
    
    @IBSegueAction func confirmOrder(_ coder: NSCoder) -> OrderConfirmationViewController? {
        return OrderConfirmationViewController(coder: coder, minutesToPrepare: minutesToPrepareOrder)
    }
    
    //Create this method before the control drag to "Exit" or unwind the screen
    @IBAction func unwindToOrderList(segue: UIStoryboardSegue){
        if segue.identifier == "DismissConfirmation" {
            MenuController.shared.order.menuItems.removeAll()
        }
        
    }
    
    
    @IBAction func submitTapped(_ sender: Any) {
        let orderTotal = MenuController.shared.order.menuItems.reduce(0.0)
        { (result, menuItem) -> Double in return result + menuItem.price
            
        }
  
    
    let formattedTotal = orderTotal.formatted(.currency(code: "usd"))
    
    let alertController = UIAlertController(title: "Confirm Order", message: "You are about to submit your order with a total of \(formattedTotal)", preferredStyle: .actionSheet)
        
        //Use the function Upload Order and it's tasks: Get the minutes to prepare an order
        alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { _ in self.uploadOrder() }))
    
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    present(alertController, animated: true, completion: nil)
        
    
        
        
}
    
    // Add this code to OrderTableViewController.swift
    // This should go in the uploadOrder() method just before the performSegue line

    // Inside uploadOrder() function in OrderTableViewController.swift
    // Add this code right before the performSegue line:

    func uploadOrder() {
        let menuIds = MenuController.shared.order.menuItems.map { $0.id }

        Task.init {
            do {
                //Constant of min to prepare the dishes that access the menuIDs inside Menu Controller
                let minutesToPrepare = try await
                    MenuController.shared.submitOrder(forMenuIDs: menuIds)
                minutesToPrepareOrder = minutesToPrepare
                
                // Create and save the past order
                let currentOrder = MenuController.shared.order.menuItems
                let pastOrder = PastOrder(menuItems: currentOrder, minutesToPrepare: minutesToPrepare)
                OrderHistory.shared.addOrder(pastOrder)
                
                performSegue(withIdentifier: "confirmOrder", sender: nil)
            } catch {
                displayError(error, title: "Order Submission Failed")
            }
        }
    }
    
   /* BEFORE -> func uploadOrder() {
        let menuIds = MenuController.shared.order.menuItems.map { $0.id }

        Task.init {
            do {
                //Constant of min to prepare the dishes that access the menuIDs inside Menu Controller
                let minutesToPrepare = try await
                    MenuController.shared.submitOrder(forMenuIDs: menuIds)
                minutesToPrepareOrder = minutesToPrepare
                performSegue(withIdentifier: "confirmOrder", sender: nil)
            } catch {
                displayError(error, title: "Order Submission Failed")
            }
        }
    }*/
    
    func displayError(_ error: Error, title: String) {
        guard let _ = viewIfLoaded?.window else { return }
        let alert = UIAlertController(
            title: title,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
   
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // cancel the image fetching task if we no longer need it
        imageLoadTasks[indexPath]?.cancel()
    }
}
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


