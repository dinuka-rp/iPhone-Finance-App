//
//  SimpleSavings.swift
//  FinCal
//
//  Created by Dinuka Piyadigama on 2022-03-10.
//

import UIKit
import Foundation

extension UIViewController {
    // MARK: savings with no monthly contributions (fixed sum)
    
    // for all - convert number of payments to number of years if the number of years toggle isn't on - do this in the controller
        // all payments and compound interest and be considered to be monthly. So, for example 60 payments is equivalent to 5 years
    // when displaying the amount, this needs to be multiplied by 12, if the toggle for years was off.
        
    /// Calculate the estimation of Principle investment amount (Present Value) , without monthly contributions (fixed sum)
    /// - Returns: Principle Investment value (Present Value): Double
    func estimatePrincpleAmountFS(futureValue: Double, interest: Double, timeInYears: Double, compoundsPerYear: Double) -> Double {

        let A = futureValue // FV
        let r = interest / 100  // I
        let t = timeInYears   // N
        let CpY = compoundsPerYear  // CPY or n same as PayPY?
        let P = A / pow(1 + (r / CpY), CpY * t)

        return P.toFixed(2)
    }

    /// Calculate the estimation of Interest, without monthly contributions (fixed sum)
    /// - Returns: Interest Rate: Double
    func estimateInterestFS(presentValue: Double, futureValue: Double, timeInYears: Double, compoundsPerYear: Double) -> Double {

        let P = presentValue //PV
        let A = futureValue
        let CpY = compoundsPerYear
        let t = timeInYears
        let r = CpY * (pow(A / P, (1 / (CpY * t))) - 1)

        return (r * 100).toFixed(2)
    }
    
    /// Calculate the estimated time in years,  without monthly contributions (fixed sum)
    /// convert to number of payments if the "show years" toggle is off
    /// - Returns: Time in Years: Double
    func estimateTimeInYearsFS(presentValue: Double, interest: Double, futureValue: Double, compoundsPerYear: Double) -> Double {

        let P = presentValue
        let A = futureValue
        let r = interest / 100
        let CpY = compoundsPerYear
        let t = log(A / P) / (CpY * log(1 + (r / CpY)))

        return t.toFixed(2)
    }
    
    /// Calculate the Future value,  without monthly contributions (fixed sum)
    /// - Returns: Future Value: Double
    func estimateFutureValueFS(presentValue: Double, interest: Double, timeInYears: Double, compoundsPerYear: Double) -> Double {

        let P = presentValue
        let r = interest / 100
        let t = timeInYears
        let CpY = compoundsPerYear
        let A = P * (pow((1 + r / CpY), CpY * t))

       return A.toFixed(2)
    }
}
