//
//  CommonFunctions.swift
//  FinCal
//
//  Created by Dinuka Piyadigama on 2022-04-04.
//

import UIKit
import Foundation

extension UIViewController {
    /// <#Description#>
    /// - Parameters:
    ///   - tag: <#tag description#>
    ///   - textFields: <#textFields description#>
    /// - Returns: <#description#>
    func getTextFieldByTag(tag: Int, textFields: [UITextField]) -> UITextField? {
        let textField = textFields.filter { tf in
            return tf.tag == tag
        }.first
        return textField
    }
    
    /// <#Description#>
    /// not used in Loans calculations - this uses num of payments
    /// - Parameter timeNumPayments: <#timeNumPayments description#>
    /// - Returns: <#description#>
    func getTimeInYears(timeNumPayments:Double, yearsToggle:UISwitch) -> Double? {
        var timeInYears: Double?
        if yearsToggle.isOn {
            timeInYears = timeNumPayments
        } else {
            timeInYears = timeNumPayments / GlobalConstants.COMPOUNDS_PER_YEAR
        }
        
        return timeInYears
    }
    
    /// Update label text, textField text & placeholder text, depending on the toggle
    func updateUIForYearsToggle(isYearsToggleOn: Bool, textField: UITextField, timeNumPaymentsLabel: UILabel){
        // if show years on
        if isYearsToggleOn {
            timeNumPaymentsLabel.text = "Number of Years"
            textField.placeholder = "Number of Years"
        } else{
            timeNumPaymentsLabel.text = "Number of Payments"
            textField.placeholder = "Number of Payments"
        }
    }

    /// Check if all fields except one have been filled - to identify whether to autogenerate the result
    /// - Returns: Bool
    func isAllButOneFilled(textFields: [UITextField]) -> Bool{
        let isSatisfied = textFields.filter { tf in
            // get all textfields that have at least one character filled
            return (tf.text?.isEmpty)!
            }.count == 1
        
        return isSatisfied
    }

    /// Check if all fields have been filled - to identify whether to autogenerate the result
    /// - Returns: Bool
    func isAllFilled(textFields: [UITextField]) -> Bool{
        return ( textFields.filter { tf in
            // get all textfields that have at least one character filled
            return tf.text?.count != 0
            }.count == textFields.count )
    }
}
