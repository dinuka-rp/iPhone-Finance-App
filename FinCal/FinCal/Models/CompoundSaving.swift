//
//  CompoundSaving.swift
//  FinCal
//
//  Created by Dinuka Piyadigama on 2022-03-20.
//

import Foundation

class CompoundSaving: Codable {
    // Encodable & Decodable - used to save the object in user-defaults
    
    var principleAmount: Double
    var interest: Double
    var futureValue: Double
    var timeInYears: Double  // this is always saved as timeInYears (need to check toggle for years, if off - convert and show in number of payments)
    var monthlyPayment: Double
    
    var lastUpdatedTag: Int
}
