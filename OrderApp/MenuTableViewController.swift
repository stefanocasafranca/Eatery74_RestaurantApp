//
//  MenuTableViewController.swift
//  OrderApp
//
//  Created by Stefano Casafranca on 5/3/25.
//

import UIKit

@MainActor
class MenuTableViewController: UITableViewController {
    
    
    
    let category: String
    //Create an instance of the class in MenuController.swift
    let menuController = MenuController()
    // MARK: For image load task we create a dictionary to store the keys and values.After doing this in Override didEndDisplaying:forRowAt we need to cancel the appropiate tasks
    var imageLoadTasks: [IndexPath: Task<Void, Never>] = [:]
    
  

    
    //  MARK: 1.    Initially empty so the table view starts with no rows.
    
    //Create an instance of the struct in MenuItem.swift
    var menuItems = [MenuItem]()
    
    init?(coder: NSCoder, category: String) {
        self.category = category
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Header of the new Screen that displays the menu within a category
        title = category.capitalized
        
        //  MARK: 2. Proper Network (JSON) Request inheriting the context where it is called
        Task.init {
            do{
                let menuItems = try await menuController.fetchMenuItems(forCategory: category)
                updateUI(with: menuItems)
            } catch {
                displayError(error, title: "Failed to fetch Menu Items for \(self.category)")
            }
        }
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // Cancel image fetching tasks that are no longer needed
        imageLoadTasks.forEach { _, task in
            task.cancel()
        }
    }
    
    
    //  MARK: 3. Patterns that will be repeated in other View Controllers
    func updateUI(with menuItems: [MenuItem]) {
        self.menuItems = menuItems
        self.tableView.reloadData()
    }
    
    
    //  MARK: 4. Display Error Func
    //Display and Error if needed
    func displayError(_ error: Error, title: String) {
        
        //This way you don't try to post an alert on a view that is not visible
        guard let _ = viewIfLoaded?.window else { return }
        
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
//  MARK: 5. Table View Methods and func used for displaying

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menuItems.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Using the Reusable Identifier MenuItem set in Main.Storyboard cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItem", for: indexPath)
        //using the function created
        configure(cell, forItemAt: indexPath)
        return cell
    }
    
    
    
    /*BEFORE THE IMAGES RETRIEVAL
    //Function to let the content change depending on the JSON file names and prices
    func configure(_ cell: UITableViewCell, forItemAt indexPath: IndexPath){
        
        //For the images and using the MenuItemCell...
        guard let cell = cell as? MenuItemCell else { return }
        
    
        //This stays like before
        let menuItem = menuItems[indexPath.row]
        
        
        //This goes away
        var content = cell.defaultContentConfiguration()
        content.text = menuItem.name
        content.secondaryText = menuItem.price.formatted(.currency(code: "usd"))
        //Adding a placeholder image
        content.image = UIImage(systemName: "photo.on.rectangle.angled.fill")
        cell.contentConfiguration = content
        
        //Task for returning an image before
        /*
        Task {
            if let image = try? await MenuController.shared.fetchImage(from: menuItem.imageURL) {
                // Image was returned
            }
        }*/
        //Task for returning an image complete and final

        Task {
            if let image = try? await MenuController.shared.fetchImage(from: menuItem.imageURL) {
                if let currentIndexPath = self.tableView.indexPath(for: cell),
                   currentIndexPath == indexPath {
                    var content = cell.defaultContentConfiguration()
                    content.text = menuItem.name
                    content.secondaryText = menuItem.price.formatted(.currency(code: "usd"))
                    content.image = image
                    cell.contentConfiguration = content
                }
            }
        }
        
        
    }*/
    
    
    func configure(_ cell: UITableViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MenuItemCell else { return }
        
        let menuItem = menuItems[indexPath.row]
        
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
    
    //Action coming from the Segue that goes from this screen to the UIViewController (Detail)
    @IBSegueAction func showMenuItem(_ coder: NSCoder, sender: Any?) -> MenuItemDetailViewController? {
        //Same stuff from CategoryTVC
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
            return nil
        }
        
        let menuItem = menuItems[indexPath.row]
        return MenuItemDetailViewController(coder: coder, menuItem: menuItem)
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // cancel the image fetching task if we no longer need it
        imageLoadTasks[indexPath]?.cancel()
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
