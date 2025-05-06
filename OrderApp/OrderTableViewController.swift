//
//  OrderTableViewController.swift
//  OrderApp
//
//  Created by Stefano Casafranca on 5/3/25.
//

import UIKit

class OrderTableViewController: UITableViewController {


    override func viewDidLoad() {
        super.viewDidLoad()

        
        //For Adding and order and bringing the notification from MenuController.swift
        NotificationCenter.default.addObserver(tableView!, selector: #selector(UITableView.reloadData), name: MenuController.orderUpdatedNotification,object:nil)
        
    
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MenuController.shared.order.menuItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Using the Reusable Identifier MenuItem set in Main.Storyboard cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Order", for: indexPath)
        //using the function created
        configure(cell, forItemAt: indexPath)
        return cell
    }
    
    //Function to let the content change depending on the JSON file names and prices
    func configure(_ cell: UITableViewCell, forItemAt indexPath: IndexPath){
        let menuItem = MenuController.shared.order.menuItems[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = menuItem.name
        //The other .currency is not working :/
        content.secondaryText = String(format: "$%.2f", menuItem.price)
        cell.contentConfiguration = content
    }
}
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

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


