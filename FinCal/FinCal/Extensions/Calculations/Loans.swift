//
//  Loans.swift
//  FinCal
//
//  Created by Dinuka Piyadigama on 2022-03-30.
//

import UIKit
import Foundation

extension UIViewController {
    // MARK: savings with regular monthly contributions

    /// Calculate the estimation of Principle investment amount (Present Value/ Loan Amount)  for a Loan
    /// - Returns: Principle Investment value (Present Value/ Loan Amount): Double
    func estimateLoanPrincpleAmount(interest: Double, noOfPayments: Double, monthlyPayment:Double) -> Double {
        let r = interest / 100  // I
        let N = noOfPayments
        let PMT = monthlyPayment
        
        let P = (PMT / r) * (1 - (1 / pow(1 + r, N)))

        return P.toFixed(2)
    }
    
    //  TODO: show an alert that this is not possible - not required according to CW spec
    //      - You only need to solve for interest rate in problems where there is no monthly payments. For example, simple lump sum investments.
    /// Calculate the estimation for the loan interest
    /// - Returns: Interest: Double
    func estimateLoanInterest(presentValue: Double,  noOfPayments: Double, monthlyPayment: Double) -> Double {
        // not exactly sure what's going on with the calculation here, got it from Dilum's
        
        // TODO: Assign to local variables before calculating
        
        /// initial calculation
        var x = 1 + (((monthlyPayment * noOfPayments / presentValue) - 1) / 12)
        /// var x = 0.1;
        let FINANCIAL_PRECISION = Double(0.000001) // 1e-6
        
        func F(_ x: Double) -> Double { // f(x)
            /// (loan * x * (1 + x)^n) / ((1+x)^n - 1) - pmt
            return Double(presentValue * x * pow(1+x, noOfPayments) / (pow(1+x, noOfPayments) - 1) - monthlyPayment);
        }
        
        func FPrime(_ x: Double) -> Double { // f'(x)
            /// (loan * (x+1)^(n-1) * ((x*(x+1)^n + (x+1)^n-n*x-x-1)) / ((x+1)^n - 1)^2)
            let c_derivative = pow(x+1 , noOfPayments)
            
            return Double(presentValue * pow(x+1, noOfPayments-1) *
                (x * c_derivative + c_derivative - (noOfPayments * x) - x - 1)) / pow(c_derivative - 1, 2)
        }
        
        while(abs(F(x)) > FINANCIAL_PRECISION) {
            x = x - F(x) / FPrime(x)
        }
        
        /// Convert to annual interest percentage
        let R = Double(12 * x * 100)
        
        return R.toFixed(2)
    }
    
    /// Calculate the estimation of monthly payment value,
    /// - Returns: Monthly Payment: Double
    func estimateLoanMonthlyPayment(presentValue: Double, interest: Double, noOfPayments: Double) -> Double {
        let r = (interest / 100.0) / 12
        let P = presentValue
        let N = noOfPayments
        
        let PMT = (r * P) / (1 - pow(1 + r, -N))
        
        return PMT.toFixed(2)
    }
    
    /// To call runtime errors during the calculations
    enum calculationErr: Error {
        case runtimeError(String)
    }
    
    /// Calculate the estimation for the number of payments left in a loan
    /// - Returns: Number of payments: Int
    func estimateLoanNumOfPayments(presentValue: Double, interest: Double, monthlyPayment: Double) throws -> Int {
        // TODO: check what the hell is happening here
        /// find the minimum monthly payment
        let minMonthlyPayment = estimateLoanMonthlyPayment(presentValue: presentValue, interest: interest, noOfPayments: 1) - presentValue
        
        if Int(monthlyPayment) <= Int(minMonthlyPayment) {
            // TODO: show an alert instead of throwing an error?
            //  OR try, catch wherever called
            throw calculationErr.runtimeError("Invalid monthly payment")
        }
        
        let PMT = monthlyPayment
        let P = presentValue
        let rM = (interest / 100.0) / 12 // monthly interest
        let k = PMT / rM
        let N = (log(k / (k - P)) / log(1 + rM))
        return Int(N)
    }

}
