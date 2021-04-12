//
//  Total+CoreDataProperties.swift
//  TinyApp
//
//  Created by Carlos Cardona on 05/04/21.
//
//

import Foundation
import CoreData


extension Total {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Total> {
        return NSFetchRequest<Total>(entityName: "Total")
    }

    @NSManaged public var totalAhorrado: Double
    @NSManaged public var totalGastado: Double
    @NSManaged public var ahorroMeta: Double

}

extension Total : Identifiable {

}
