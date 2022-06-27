//
//  WeatherEntry+CoreDataProperties.swift
//  P5_weather_app
//
//  Created by Alvaro Choque on 26/6/22.
//
//

import Foundation
import CoreData


extension WeatherEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeatherEntry> {
        return NSFetchRequest<WeatherEntry>(entityName: "WeatherEntry")
    }

    @NSManaged public var id: Int16
    @NSManaged public var index: Int32
    @NSManaged public var searchDate: Date?
    @NSManaged public var urlSearch: String?
    @NSManaged public var place: String?

}

extension WeatherEntry : Identifiable {

}
