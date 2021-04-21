//
//  Item+CoreDataProperties.swift
//  TinyApp
//
//  Created by Carlos Cardona on 13/04/21.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var ahorro: Double
    @NSManaged public var gasto: Double
    @NSManaged public var nombre: String?
    @NSManaged public var totalAhorrado: Double

}

extension Item : Identifiable {

}
