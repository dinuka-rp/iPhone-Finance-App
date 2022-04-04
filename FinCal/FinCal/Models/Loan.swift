//
//  Loan.swift
//  FinCal
//
//  Created by Dinuka Piyadigama on 2022-03-20.
//

import Foundation

struct Loan: Codable {
    // Encodable & Decodable - used to save the object in user-defaults
    
    var principleAmount: Double
    var interest: Double
//    var timeInYears: Double  // this is always saved as timeInYears (need to check toggle for years, if off - convert and show in number of payments)
    var numOfPayments: Double  // (need to check toggle for years, if on - convert and show in number of payments)
    var monthlyPayment: Double
    
    var lastCalculatedTag: Int
}
