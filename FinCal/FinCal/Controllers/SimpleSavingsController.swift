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
    // TODO: implement a reset button - to clear all input text fields at once

    @IBOutlet weak var timeNumPaymentsLabel: UILabel!

    var lastCalculatedTfTag:Int?
    
    let defaults = UserDefaults.standard
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("FinCal.plist")
//    TODO: (Extra) check if using a custom plist file will allow us to see all the properties of the dictionary separately - no advantage from the app's functional pov
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    // user defaults keys
    let SIMPLE_SAVINGS_UD_KEY = "SimpleSaving"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        keyboard.deligate = self
        
        textFields.forEach{textField in
            // prevent default keyboard from opening for all textFields
            textField.inputView = UIView()
            textField.inputAccessoryView = UIView()
        }
        
        let isYearsToggleOn = defaults.bool(forKey: GlobalConstants.YEARS_TOGGLED_UD_KEY)
        yearsToggle.isOn = isYearsToggleOn
        
        // set label & placeholder of time input based on yearsToggle value loaded from user defaults, if saved
        let timeNumPaymentsTextField = getTextFieldByTag(tag: 4, textFields: textFields)
        updateUIForYearsToggle(isYearsToggleOn: isYearsToggleOn, textField: timeNumPaymentsTextField!, timeNumPaymentsLabel: timeNumPaymentsLabel)
        
        // load textfield values from user defaults
        // Read/Get Data
        if let data = UserDefaults.standard.data(forKey: SIMPLE_SAVINGS_UD_KEY) {
            do {
                // Decode Note
                let simpleSaving = try decoder.decode(SimpleSaving.self, from: data)

                // display values in respective text fields
                if simpleSaving.presentValue != nil{
                    let presentValueTf =  getTextFieldByTag(tag: 1, textFields: textFields)
                    presentValueTf?.text = "\(simpleSaving.presentValue!)"
                }
                if simpleSaving.interest != nil{
                    let interestTf =  getTextFieldByTag(tag: 2, textFields: textFields)
                    interestTf?.text = "\(simpleSaving.interest!)"
                }
                if simpleSaving.futureValue != nil{
                    let futureValueTf =  getTextFieldByTag(tag: 3, textFields: textFields)
                    futureValueTf?.text = "\(simpleSaving.futureValue!)"
                }
                if simpleSaving.timeInYears != nil{
                    let timeNumPaymentsTf =  getTextFieldByTag(tag: 4, textFields: textFields)
                    let timeInYears = simpleSaving.timeInYears
                    if yearsToggle.isOn {
                        timeNumPaymentsTf?.text = "\(timeInYears!)"
                    } else{
                        let timeInNumPayments = timeInYears! * GlobalConstants.COMPOUNDS_PER_YEAR
                        timeNumPaymentsTf?.text = "\(timeInNumPayments)"
                    }
                }
                // MARK: load lastCalculatedTfTag of SimpleSavings
                lastCalculatedTfTag = simpleSaving.lastCalculatedTag
            } catch {
                print("Unable to Decode object (\(error))")
            }
        }
    }
    
    @IBAction func didYearsToggle(_ sender: UISwitch) {
        let isYearsToggleOn = sender.isOn
        
        let timeNumPaymentsTextField = getTextFieldByTag(tag: 4, textFields: textFields)
        updateUIForYearsToggle(isYearsToggleOn: isYearsToggleOn, textField: timeNumPaymentsTextField!, timeNumPaymentsLabel: timeNumPaymentsLabel)
        
        if isYearsToggleOn {
            if let numOfYears = timeNumPaymentsTextField?.text{
                // convert & update value if it exists
                let numOfYears = (Double(numOfYears) ?? 0) / 12
                
                // round number off to 2 decimal places
                timeNumPaymentsTextField?.text = "\(numOfYears.toFixed(2))"
            }
        } else{
            if let numOfYears = timeNumPaymentsTextField?.text{
                // convert & update value if it exists
                let numOfPayments = (Double(numOfYears) ?? 0) * 12
                
                // show number as integer - show as a rounded decimal (incase there're half payments when converted from years)
                timeNumPaymentsTextField?.text = "\(numOfPayments.toFixed(2))"
            }
        }
        
        // save value to user defaults
        defaults.set(isYearsToggleOn, forKey: GlobalConstants.YEARS_TOGGLED_UD_KEY)
    }

    
    /// Check whether all conditions are satisfied to autogenerate the result
    /// - Returns: Bool
//    func isCalculatable(inputTag: Int) -> Bool{
//        let isAllButOneFilled  = isAllButOneFilled()
//        let isAllFilled = isAllFilled()
//        let isSatisfied = isAllButOneFilled || (isAllFilled && inputTag != lastCalculatedTfTag)
//
//        return isSatisfied
//    }

    
    func changeInput(textField: UITextField) {
        let inputTfTag = textField.tag

        let isAllButOneFilled  = isAllButOneFilled(textFields: textFields)
        let isAllFilled = isAllFilled(textFields: textFields)
        let isCalculatable = isAllButOneFilled || (isAllFilled && inputTfTag != lastCalculatedTfTag)

        
        // check if it's possible to make a calculation
        if (isCalculatable) {
            // identify the missing field/ tf to be calculateed
            var textFieldTBC = textFields.filter { tf in
                return tf.text?.count == 0  // can use isEmpty as well
            }.first

//            print("empty textfield: \(String(describing: textFieldTBC?.tag)) \(String(describing: textFieldTBC?.placeholder))")
            if textFieldTBC?.tag != nil {
                lastCalculatedTfTag = textFieldTBC!.tag
            } else {
                textFieldTBC = getTextFieldByTag(tag: lastCalculatedTfTag!, textFields: textFields)
            }

            // get all values in textfields and assign to relevant variables, to pass into functions
            let presentValue = Double((getTextFieldByTag(tag: 1, textFields: textFields)?.text)!)
            let interest = Double((getTextFieldByTag(tag: 2, textFields: textFields)?.text)!)
            let futureValue = Double((getTextFieldByTag(tag: 3, textFields: textFields)?.text)!)
            let timeNumPayments = Double((getTextFieldByTag(tag: 4, textFields: textFields)?.text)!)
            
            var timeInYears: Double? = nil
            
            if timeNumPayments != nil{
            // convert time to years
                timeInYears = getTimeInYears(timeNumPayments:timeNumPayments!, yearsToggle: yearsToggle)
            }
            
            let simpleSaving = SimpleSaving(presentValue: presentValue, interest: interest, futureValue: futureValue, timeInYears: timeInYears, lastCalculatedTag: lastCalculatedTfTag)
            
            do {
                // encode & save object in user defaults
                let encodedData = try encoder.encode(simpleSaving)
                defaults.set(encodedData, forKey: SIMPLE_SAVINGS_UD_KEY)
            } catch {
                print("Error encoding simple saving, \(error)")
            }

            let calculatedEstimate: Double
            
            // calculate & display the missing field
            switch lastCalculatedTfTag {
            case 1:
                // principle amount
                calculatedEstimate = estimatePrincpleAmountFS(futureValue: futureValue!, interest: interest!, timeInYears: timeInYears!, compoundsPerYear: GlobalConstants.COMPOUNDS_PER_YEAR)
                textFieldTBC?.text = "\(calculatedEstimate)"
            case 2:
                // interest
                calculatedEstimate = estimateInterestFS(presentValue: presentValue!, futureValue: futureValue!, timeInYears: timeInYears!, compoundsPerYear: GlobalConstants.COMPOUNDS_PER_YEAR)
                textFieldTBC?.text = "\(calculatedEstimate)"
            case 3:
                // future value
                calculatedEstimate = estimateFutureValueFS(presentValue: presentValue!, interest: interest!, timeInYears: timeInYears!, compoundsPerYear: GlobalConstants.COMPOUNDS_PER_YEAR)
                textFieldTBC?.text = "\(calculatedEstimate)"
            case 4:
                // num of payments
                let timeEstimationInYears = estimateTimeInYearsFS(presentValue: presentValue!, interest: interest!, futureValue: futureValue!, compoundsPerYear: GlobalConstants.COMPOUNDS_PER_YEAR)

                // convert this to Integer before displaying
                if yearsToggle.isOn {
                    let timeEstimationInYearsInt = Int(timeEstimationInYears)
                    textFieldTBC?.text = "\(timeEstimationInYearsInt)"
                } else {
                    let timeEstimationInNumPaymentsInt = Int(timeEstimationInYears * GlobalConstants.COMPOUNDS_PER_YEAR)
                    textFieldTBC?.text = "\(timeEstimationInNumPaymentsInt)"
                }
            default:
                return
            }
            // highlight UI of textfield with estimated value/ change label font color
            
        } else if (isAllFilled && inputTfTag == lastCalculatedTfTag) {
            // if the lastCalculatedTf was altered, show that another field has to be deleted, to generate an estimation
            // TODO: alert user that at least one field has to be empty to make an estimation
            print("Delete another field to make an estimation. At least one field needs to be empty for an estimation.")
        }
//     TODO:   else if {
//            // 2 or more fields empty - reset the lastCalculatedTfTag
//            lastCalculatedTfTag = nil
//            // save lastCalculatedTfTag to user defaults
//            defaults.set(lastCalculatedTfTag, forKey: "lastCalculatedTfTagSimpleSavings")
//        }
    }

}

// TODO: create a delegate here and implement in in CustomKeyboard
//      use a function in that delegate to display +/- toggle appropriately in the keyboard, when a textfield is brought into focus - have an IBAction that triggers on focus?

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
//                        changeInput(textField: tf) // not required since a number needs to be added after the . to have an impact on the  calculation
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
                changeInput(textField: tf)
            }
        }
    }
    
    func didToggleNegative() {
        
//         MARK: This is only needed for compound savings/ loans? to show money taken out
        
        // check if this textfield can be made negative (only payments going out need a negative value) - only applied for compound savings?
        let tfTagsAllowed: [Int] = []
        
        let textField = textFields.filter { tf in
            return tf.isFirstResponder
        }.first
        
        if let tf = textField {
            let tfTag = tf.tag
            if tfTagsAllowed.contains(tfTag) {
                var tfText: Double = NSString(string: tf.text ?? "0").doubleValue
                
                if tf.text?.first == "-" {
                    tfText = abs(tfText)  // make positive
                    tf.text! = "\(tfText)"
                } else{
                    tf.text! = "-\(tfText)"
                }
            }
        }
    }
}


//references: https://cocoacasts.com/ud-5-how-to-store-a-custom-object-in-user-defaults-in-swift
// https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types
