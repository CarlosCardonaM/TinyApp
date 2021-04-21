//
//  Total+CoreDataProperties.swift
//  TinyApp
//
//  Created by Carlos Cardona on 12/04/21.
//
//

import Foundation
import CoreData


extension Total {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Total> {
        return NSFetchRequest<Total>(entityName: "Total")
    }

    @NSManaged public var ahorroMeta: Double
    @NSManaged public var totalAhorrado: Double
    @NSManaged public var totalGastado: Double

}

extension Total : Identifiable {

}
