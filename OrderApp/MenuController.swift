//
//  MenuController.swift
//  OrderApp
//
//  Created by Stefano Casafranca on 5/3/25.
//

import Foundation
import UIKit


class MenuController {
    
    enum MenuControllerError: Error, LocalizedError {
        case categoriesNotFound
        case menuItemsNotFound
        case orderRequestFailed
        case imageDataMissing
    }
    
    //Adding an image
    func fetchImage(from url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MenuControllerError.imageDataMissing
        }

        guard let image = UIImage(data: data) else {
            throw MenuControllerError.imageDataMissing
        }

        return image
    }

    //For Adding and order notification and the order itself
    static let orderUpdatedNotification = Notification.Name("MenuController.orderUpdated")
    
    //Line added so CategoryTableVC can
    //Properly make the task of Network Request + inheriting the context where it is called
    
    //static make it possible to reuse the constant anywhere in the program...it's declared "outside" of the class but impicitly is always on a bigger class
    static let shared = MenuController()

    
    let baseURL = URL(string: "http://localhost:8080/")!
    
    

    //For Adding and order
    var order = Order() {
        
        didSet {
            NotificationCenter.default.post(name:MenuController.orderUpdatedNotification, object: nil)
        }
    }
    

    //Notification on the bag order
   /* var order = Order() {
        didSet {
            NotificationCenter.default.post(name: MenuController.orderUpdatedNotification, object: nil)
        }
    }*/
    
//--------STEP FOUR: ADD NETWORKING CODE---------
    
    //MARK: GET call for Categories JSON
    func fetchCategories() async throws -> [String] {
        let categoriesURL = baseURL.appendingPathComponent("categories")
        
        
        //ERROR CATCHING

        let (data, response) = try await URLSession.shared.data(from: categoriesURL)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MenuControllerError.categoriesNotFound
        }

        let decoder = JSONDecoder()
        let categoriesResponse = try decoder.decode(CategoriesResponse.self,from:data)
        return categoriesResponse.categories
    }
   
    
    //MARK: GET items JSON within a category
    func fetchMenuItems(forCategory categoryName: String) async throws -> [MenuItem] {
        
        let initialMenuURL = baseURL.appendingPathComponent("menu")
        var components = URLComponents(url: initialMenuURL, resolvingAgainstBaseURL: true)!
        components.queryItems = [URLQueryItem(name: "category", value: categoryName)]
        let menuURL = components.url!

        
        //ERROR CATCHING

        let (data, response) = try await URLSession.shared.data(from: menuURL)
    
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MenuControllerError.menuItemsNotFound
        }

        let decoder = JSONDecoder()
        let menuResponse = try decoder.decode(MenuResponse.self, from:data)
        return menuResponse.items
    }
    
    
    //MARK: POST JSON file containing user Order
    
    typealias MinutesToPrepare = Int

    func submitOrder(forMenuIDs menuIDs: [Int]) async throws -> MinutesToPrepare {
        let orderURL = baseURL.appendingPathComponent("order")
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let menuIdsDict = ["menuIds": menuIDs]
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(menuIdsDict)
        request.httpBody = jsonData
    
        
        //ERROR CATCHING
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MenuControllerError.orderRequestFailed
        }
        let decoder = JSONDecoder()
        let orderResponse = try decoder.decode(OrderResponse.self, from:data)
        return orderResponse.prepTime
    }
    
    
    //func fetchImage(from url: URL) async throws -> UIImage {}
}
