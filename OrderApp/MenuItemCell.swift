//
//  MenuItemCell.swift
//  OrderApp
//
//  Created by Stefano Casafranca on 5/15/25.
//

//Adding an image by changing the class of the reusable cell in MenuTableViewController to MenuItemCell

import Foundation
import UIKit

class MenuItemCell: UITableViewCell {
    var itemName: String? = nil {
        didSet {
            if oldValue != itemName {
                setNeedsUpdateConfiguration()
            }
        }
    }

    var price: Double? = nil {
        didSet {
            if oldValue != price {
                setNeedsUpdateConfiguration()
            }
        }
    }

    var image: UIImage? = nil {
        didSet {
            if oldValue != image {
                setNeedsUpdateConfiguration()
            }
        }
    }
    
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var content = defaultContentConfiguration().updated(for: state)
        content.text = itemName
        content.secondaryText = price?.formatted(.currency(code: "usd"))
        content.prefersSideBySideTextAndSecondaryText = true

        // Add these three lines in the updateConfiguration method just before setting the image
        content.imageProperties.maximumSize = CGSize(width: 60, height: 60)
        content.imageProperties.reservedLayoutSize = CGSize(width: 60, height: 60)
        content.imageProperties.cornerRadius = 5

        // And add this line for better margins
        content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        if let image = image {
            content.image = image
        } else {
            content.image = UIImage(systemName: "photo.on.rectangle")
        }

        self.contentConfiguration = content
    }
    
    
    
    
    
    
}
