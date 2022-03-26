//
//  SimpleSaving.swift
//  FinCal
//
//  Created by Dinuka Piyadigama on 2022-03-20.
//

import Foundation

struct SimpleSaving: Codable {
    // Encodable & Decodable - used to save the object in user-defaults
    
    var presentValue: Double? // A.k.a: principle amount
    var interest: Double?
    var futureValue: Double?
    var timeInYears: Double?  // this is always saved as timeInYears (need to check toggle for years, if off - convert and show in number of payments)
    
    var lastCalculatedTag: Int?
}
