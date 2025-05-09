//
//  CategoryTableTableViewController.swift
//  OrderApp
//
//  Created by Stefano Casafranca on 5/3/25.
//

import UIKit



@MainActor
class CategoryTableTableViewController: UITableViewController {
    
    
    //  MARK: 1.    Initially empty so the table view starts with no rows.
    
    //Instance of the class that works with network code
    //[String]() is shorthand for an empty array of type String.
    var categories = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  MARK: 2. Proper Network (JSON) Request inheriting the context where it is called
        
        //Calling the "GET call for Categories JSON" (MenuController.swift)
        
        Task.init {
            do {
                //Access the MenuController file to then access the "shared" static const to then access the "fetchCategories" function
                let categories = try await MenuController.shared.fetchCategories()
                updateUI(with: categories)
            } catch {
                displayError(error, title: "Failed to Fetch Categories")
            }
        }
    }
    
    
    //  MARK: 3. Patterns that will be repeated in other View Controllers
    func updateUI(with categories: [String]) {
        self.categories = categories
        self.tableView.reloadData()
    }
    
    
    //Display and Error if needed
    func displayError(_ error: Error, title: String) {
        
        //This way you don't try to post an alert on a view that is not visible
        guard let _ = viewIfLoaded?.window else { return }
        
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    //Cast the sender argument to a UITableViewCell and then you look up its Index Path and use to determine the category that was selected
    @IBSegueAction func showMenu(_ coder: NSCoder, sender: Any?) -> MenuTableViewController? {
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            return nil
        }
        
        let category = categories[indexPath.row]
        return MenuTableViewController(coder: coder, category: category)
    }
    
    
    //  MARK: 4. Table View Methods used for displaying
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        //0 -> 1
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        //0 -> categories.count
        return categories.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //"reuseIdentifier" --> "Category" (identifier from Main)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Category", for: indexPath)
        
        // Configure the cell...
        configureCell(cell, forCategoryAt: indexPath)
        
        return cell
        
    }
    
    //Added Function
    // Uses modern cell configuration with defaultContentConfiguration to safely set the category label
    
    func configureCell(_ cell: UITableViewCell, forCategoryAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = category.capitalized
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
    

