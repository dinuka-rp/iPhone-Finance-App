//
//  CompoundSavings.swift
//  FinCal
//
//  Created by Dinuka Piyadigama on 2022-03-12.
//

import UIKit
import Foundation

extension UIViewController {
    // MARK: savings with regular monthly contributions
    
//    TODO: prettify equation of calculations
    
    /// Calculate the estimation of Principle investment amount (Present Value) , with regular monthly contributions
    /// - Returns: Principle Investment value (Present Value)
    func estimatePrincpleAmountRC(futureValue: Double, interest: Double, timeInYears: Double, monthlyPayment:Double, compoundsPerYear: Double) -> Double {

        let A = futureValue // FV
        let r = interest / 100  // I
        let t = timeInYears   // N
        let CpY = compoundsPerYear  // CPY or n same as PayPY?
        let PMT = monthlyPayment
        
        let P = (A - (PMT * (pow((1 + r / CpY), CpY * t) - 1) / (r / CpY))) / pow((1 + r / CpY), CpY * t)

        return P.toFixed(2)
    }
    
    //  TODO: show an alert that this is not possible? according to Dilum's CW
//    func estimateInterestRC(presentValue: Double, futureValue: Double, timeInYears: Double, compoundsPerYear: Double) -> Double {
//        let P = presentValue //PV
//        let A = futureValue
//        let CpY = compoundsPerYear
//        let t = timeInYears
//        let r = CpY * (pow(A / P, (1 / (CpY * t))) - 1)
    
//    return r.toFixed(2)
//    }
    
    
    /// Calculate the estimated time in years,  with  regular monthly contributions
    /// convert to number of payments if the "show years" toggle is off
    /// - Returns: Time in Years: Double
    func estimateTimeInYearsRC(presentValue: Double, interest: Double, futureValue: Double, monthlyPayment: Double, compoundsPerYear: Double) -> Double {

        let P = presentValue
        let A = futureValue
        let r = interest / 100
        let CpY = compoundsPerYear
        let PMT = monthlyPayment

        var t: Double = 0;
        
        t = (log(A + ((PMT * CpY) / r)) - log(((r * P) + (PMT * CpY)) / r)) / (CpY * log(1 + (r / CpY)))
        
        // what's the purpose of using this logic?
        if t.isNaN || t.isInfinite {
            return 0.0
        } else {
            return t.toFixed(2)
        }
    }
    
    /// Calculate the Future value,  with  regular monthly contributions
    /// - Returns: Future Value: Double
    func estimateFutureValueRC(presentValue: Double, interest: Double, timeInYears: Double, monthlyPayment: Double, compoundsPerYear: Double) -> Double {

        let P = presentValue
        let r = interest / 100
        let t = timeInYears
        let CpY = compoundsPerYear
        let PMT = monthlyPayment

        let A = P * pow((1 + r / CpY), CpY * t) + (PMT * (pow((1 + r / CpY), CpY * t) - 1) / (r / CpY))

       return A.toFixed(2)
    }
    
    /// Calculate the estimation of monthly payment value, with regular monthly contributions
    /// - Returns: Monthly Payment Value: Double
    func estimateMonthlyPaymentValueRC(futureValue: Double, presentValue: Double, interest: Double, timeInYears: Double, compoundsPerYear: Double) -> Double {

        let A = futureValue // FV
        let P = presentValue
        let r = interest / 100
        let t = timeInYears
        let CpY = compoundsPerYear
//        let PMT = monthlyPayment

        let PMT = (P - (A * pow((1 + r / CpY), CpY * t))) / ((pow((1 + r / CpY), CpY * t) - 1) / (r / CpY)) / (1 + r / CpY)

       return PMT.toFixed(2)
    }
}
