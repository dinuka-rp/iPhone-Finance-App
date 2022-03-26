//
//  DoubleExtension.swift
//  FinCal
//
//  Created by Dinuka Piyadigama on 2022-03-10.
//

import Foundation

extension Double {
    func toFixed(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))     // identify the power of 10 to divide from (to get the required decimal)
        return (divisor*self).rounded() / divisor   // round the multiple to an integer, to consider correct bounds in rounding
    }
}

// reference: https://stackoverflow.com/a/32581409/11005638
