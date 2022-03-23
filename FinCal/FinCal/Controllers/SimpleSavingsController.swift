//
//  SimpleSavingsController.swift
//  FinCal
//
//  Created by Dinuka Piyadigama on 2022-03-10.
//

import UIKit

class SimpleSavingsController: UIViewController {
    @IBOutlet weak var keyboard: CustomKeyboard!
    
    @IBOutlet var textFields: [UITextField]!
    
    //     check the value of this when calling functions, to determine what to display
    @IBOutlet weak var yearsToggle: UISwitch!
    
    // TODO: positive/ negative needs to be saved and updated in the keyboard as well?, based on the text in the textfield (+ or - number)
    
    @IBOutlet weak var timeNumPaymentsLabel: UILabel!
    
    var lastCalculatedTfTag:Int?
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        keyboard.deligate = self
        
        textFields.forEach{textField in
            // prevent default keyboard from opening for all textFields
            textField.inputView = UIView()
            textField.inputAccessoryView = UIView()
        }
        
        let isYearsToggleOn = defaults.bool(forKey: "YearsToggled")
        yearsToggle.isOn = isYearsToggleOn
        
        // set label & placeholder of time input based on yearsToggle value loaded from user defaults, if saved
        let timeNumPaymentsTextField = getTextFieldByTag(tag: 4)
        updateUIForYearsToggle(isYearsToggleOn: isYearsToggleOn, textField: timeNumPaymentsTextField!)
        
        // load textfield values from user defaults
        
    }
    
    @IBAction func didYearsToggle(_ sender: UISwitch) {
        let isYearsToggleOn = sender.isOn
        
        let timeNumPaymentsTextField = getTextFieldByTag(tag: 4)
        updateUIForYearsToggle(isYearsToggleOn: isYearsToggleOn, textField: timeNumPaymentsTextField!)
        
        if isYearsToggleOn {
            if let numOfYears = timeNumPaymentsTextField?.text{
                // convert & update value if it exists
                let numOfPayments = (Double(numOfYears) ?? 0) / 12
                timeNumPaymentsTextField?.text = "\(numOfPayments)"
            }
        } else{
            if let numOfYears = timeNumPaymentsTextField?.text{
                // convert & update value if it exists
                let numOfPayments = (Double(numOfYears) ?? 0) * 12
                timeNumPaymentsTextField?.text = "\(numOfPayments)"
            }
        }
        
        // save value to user defaults
        defaults.set(isYearsToggleOn, forKey: "YearsToggled")
    }
    
    /// Update label text, textField text & placeholder text, depending on the toggle
    func updateUIForYearsToggle(isYearsToggleOn: Bool, textField: UITextField){
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
    func isAllButOneFilled() -> Bool{
        let isSatisfied = textFields.filter { tf in
            // get all textfields that have at least one character filled
            return (tf.text?.isEmpty)!
            }.count == 1
        
        return isSatisfied
    }
    
    // TODO: check how to handle this properly
    /// Check if all fields except two have been filled - to identify whether to allow entering another value to perform a new calculation
    /// either this needs to be recorded in a queue, better to make the user remove 2 spots and fill up
    /// - Returns: Bool
//    func isAllButTwoFilled() -> Bool{
//        return ( textFields.filter { tf in
//            // get all textfields that have at least one character filled
//            return tf.text?.count != 0
//            }.count == textFields.count - 2 )
//    }
    
    /// Check if all fields have been filled - to identify whether to autogenerate the result
    /// - Returns: Bool
    func isAllFilled() -> Bool{
        return ( textFields.filter { tf in
            // get all textfields that have at least one character filled
            return tf.text?.count != 0
            }.count == textFields.count )
    }
    
    func changeInput(textField: UITextField) {
        let inputTfTag = textField.tag
        
        // check if all textfields have been filled
        if isAllFilled() {
            // check if the lastCalculatedField was the one that was updated
            if inputTfTag == lastCalculatedTfTag {
                // alert user that at least one field has to be empty to make an estimation

                // return without calculating
                return
            } else {
                // calculate the new estimation & update the value of the lastCalculatedField
            }
        }
        
//        FIXME: this logic will run once, then when all the fields get filled, it won't run afterwords - have an or condition to omit the field that was calculated/ estimated.
//        pass through if the input wasn't given from the already estimated field
        
        // check if one textfield is empty
        let isAllButOneFilled = isAllButOneFilled()
                
        if (isAllButOneFilled) {
            // identify the missing field
            let unfilledTextField = textFields.filter { tf in
                return tf.text?.count == 0  // can use isEmpty as well
            }.first

            print("empty textfield: \(String(describing: unfilledTextField?.tag)) \(String(describing: unfilledTextField?.placeholder))")
            if unfilledTextField != nil{
                lastCalculatedTfTag = unfilledTextField!.tag
            }

            // get all values in textfields and assign to relevant variables, to pass into functions
            let presentValue = Double((getTextFieldByTag(tag: 1)?.text)!)
            let interest = Double((getTextFieldByTag(tag: 2)?.text)!)
            let futureValue = Double((getTextFieldByTag(tag: 3)?.text)!)
            let timeNumPayments = Double((getTextFieldByTag(tag: 3)?.text)!)

            let compoundsPerYear = 12.0  // hard code this as a global variable somewhere else?

            // calculate & display the missing field
            switch lastCalculatedTfTag {
            case 1:
                // principle amount
                let timeInYears = getTimeInYears(timeNumPayments:timeNumPayments!, compoundsPerYear:compoundsPerYear)
                let calculatedEstimate = estimatePrincpleAmountFS(futureValue: futureValue!, interest: interest!, timeInYears: timeInYears, compoundsPerYear: compoundsPerYear)
                unfilledTextField?.text = "\(calculatedEstimate)"
            case 2:
                // interest
                let timeInYears = getTimeInYears(timeNumPayments:timeNumPayments!, compoundsPerYear:compoundsPerYear)
                let calculatedEstimate = estimateInterestFS(presentValue: presentValue!, futureValue: futureValue!, timeInYears: timeInYears, compoundsPerYear: compoundsPerYear)
                unfilledTextField?.text = "\(calculatedEstimate)"
            case 3:
                // future value
                let timeInYears = getTimeInYears(timeNumPayments:timeNumPayments!, compoundsPerYear:compoundsPerYear)
                let calculatedEstimate = estimateFutureValueFS(presentValue: presentValue!, interest: interest!, timeInYears: timeInYears, compoundsPerYear: compoundsPerYear)
                unfilledTextField?.text = "\(calculatedEstimate)"
            case 4:
                // num of payments
                let timeEstimationInYears = estimateTimeInYearsFS(presentValue: presentValue!, interest: interest!, futureValue: futureValue!, compoundsPerYear: compoundsPerYear)

                // convert this to Integer before displaying
                if yearsToggle.isOn {
                    let timeEstimationInYearsInt = Int(timeEstimationInYears)
                    unfilledTextField?.text = "\(timeEstimationInYearsInt)"
                } else {
                    let timeEstimationInNumPaymentsInt = Int(timeEstimationInYears * compoundsPerYear)
                    unfilledTextField?.text = "\(timeEstimationInNumPaymentsInt)"
                }
            default:
                return
            }

            // highlight UI of textfield with estimated value/ change label font color
        }
    }
    
    func getTextFieldByTag(tag: Int) -> UITextField? {
        let textField = textFields.filter { tf in
            return tf.tag == tag
        }.first
        return textField
    }
    
    func getTimeInYears(timeNumPayments:Double, compoundsPerYear:Double) -> Double {
        var timeInYears = 0.0
        if yearsToggle.isOn {
            timeInYears = timeNumPayments
        } else {
            timeInYears = timeNumPayments / compoundsPerYear
        }
        
        return timeInYears
    }
}

// MARK: Implementation of the CustomKeyboardProtocol methods
extension SimpleSavingsController: CustomKeyboardProtocol{
    func didPressNumber(_ number: String) {
        let textField = textFields.filter { tf in
            return tf.isFirstResponder
        }.first
        
        if let tf = textField {
            tf.text! += "\(number)"
            
            changeInput(textField: tf)
        }
    }
    
    func didPressDecimal() {
        let textField = textFields.filter { tf in
            return tf.isFirstResponder
        }.first
        
        if let tf = textField {
            // check if numbers have been entered before the decimal point
            if (tf.text?.count ?? 0) > 0 {
                
                if let tfText = tf.text{
                    // check if the number is already decimal (if . was added to the text before)
                    if tfText.contains("."){
                        return
                    }
                    else{
                        tf.text! += "."
                    }
                }
            } else{
                // alert: a number can't start with a decimal point
            }
        }
    }
    
    func didPressDelete() {
        let textField = textFields.filter { tf in
            return tf.isFirstResponder
        }.first
        
        if let tf = textField {
            if (tf.text?.count ?? 0) > 0 {
                //  remove last character
                tf.text!.removeLast()
            }
        }
    }
    
    func didToggleNegative(_ bool: Bool) {
        
//         MARK: This is only needed for compound savings/ loans? to show money taken out
        
        // TODO: check if this textfield can be made negative (only payments going out need a negative value)
        
        
//        if bool{
//            let textField = textFields.filter { tf in
//                return tf.isFirstResponder
//            }.first
//
//            if let tf = textField {
//                if (tf.text?.count ?? 0) > 0 {
//                    tf.text = "-\(tf.text ?? "0")"
//                }
//            }
//
//        } else{
////            make it positive, if it's already negative
//        }
    }
}
