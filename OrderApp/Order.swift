//
//  Order.swift
//  OrderApp
//
//  Created by Stefano Casafranca on 5/3/25.
//

import Foundation


//Order model object will contain a simple list of the items the user has added to their "bag".

struct Order: Codable {
    var menuItems: [MenuItem]
    
    init(menuItems: [MenuItem]) {
        self.menuItems = menuItems
    }
}
