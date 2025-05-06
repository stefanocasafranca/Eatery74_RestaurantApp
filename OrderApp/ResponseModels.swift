//
//  ResponseModels.swift
//  OrderApp
//
//  Created by Stefano Casafranca on 5/3/25.
//

import Foundation


// This is for the /menu endpoint to return an object with and "items" key that contains the "MenuItems"
struct MenuResponse: Codable {
    let items: [MenuItem]
}

// This is for the /categories endpoint
struct CategoriesResponse: Codable {
    let categories: [String]
}

// This is for the /order endpoint which needs a custom key
struct OrderResponse: Codable {
    let prepTime: Int
    
    enum CodingKeys: String, CodingKey {
        case prepTime = "preparation_time"
    }
}
