//
//  CompoundSavingsController.swift
//  FinCal
//
//  Created by Dinuka Piyadigama on 2022-03-10.
//

import UIKit

class CompoundSavingsController: UIViewController {
    @IBOutlet weak var keyboard: CustomKeyboard!
    
    @IBOutlet weak var keyboardBottomConstraint: NSLayoutConstraint!

    @IBOutlet var textFields: [UITextField]!
    
    //     check the value of this when calling functions, to determine what to display
    @IBOutlet weak var yearsToggle: UISwitch!
    
    @IBOutlet weak var timeNumPaymentsLabel: UILabel!

    @IBOutlet weak var clearAllButton: UIButton!
    
    var lastCalculatedTfTag:Int?
    
    let defaults = UserDefaults.standard
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    // user defaults keys
    let COMPOUND_SAVINGS_UD_KEY = "CompoundSaving"
    
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
        let timeNumPaymentsTextField = getTextFieldByTag(tag: 5, textFields: textFields)
        updateUIForYearsToggle(isYearsToggleOn: isYearsToggleOn, textField: timeNumPaymentsTextField!, timeNumPaymentsLabel: timeNumPaymentsLabel)
        
        // load textfield values from user defaults
        // Read/Get Data
        if let data = UserDefaults.standard.data(forKey: COMPOUND_SAVINGS_UD_KEY) {
            do {
                // Decode Note
                let compoundSaving = try decoder.decode(CompoundSaving.self, from: data)

                // display values in respective text fields
                if compoundSaving.presentValue != nil{
                    let presentValueTf =  getTextFieldByTag(tag: 1, textFields: textFields)
                    presentValueTf?.text = "\(compoundSaving.presentValue!)"
                }
                if compoundSaving.interest != nil{
                    let interestTf =  getTextFieldByTag(tag: 2, textFields: textFields)
                    interestTf?.text = "\(compoundSaving.interest!)"
                }
                if compoundSaving.monthlyPayment != nil{
                    let monthlyPaymentTf =  getTextFieldByTag(tag: 3, textFields: textFields)
                    monthlyPaymentTf?.text = "\(compoundSaving.monthlyPayment!)"
                }
                if compoundSaving.futureValue != nil{
                    let futureValueTf =  getTextFieldByTag(tag: 4, textFields: textFields)
                    futureValueTf?.text = "\(compoundSaving.futureValue!)"
                }
                if compoundSaving.timeInYears != nil{
                    let timeNumPaymentsTf =  getTextFieldByTag(tag: 5, textFields: textFields)
                    let timeInYears = compoundSaving.timeInYears
                    if yearsToggle.isOn {
                        timeNumPaymentsTf?.text = "\(timeInYears!)"
                    } else{
                        let timeInNumPayments = timeInYears! * GlobalConstants.COMPOUNDS_PER_YEAR
                        timeNumPaymentsTf?.text = "\(timeInNumPayments)"
                    }
                }
                // MARK: load lastCalculatedTfTag of SimpleSavings
                lastCalculatedTfTag = compoundSaving.lastCalculatedTag
                
                if lastCalculatedTfTag != nil{
                    let lastCalculatedTf = getTextFieldByTag(tag: lastCalculatedTfTag!, textFields: textFields)
                    // highlight UI of textfield with estimated value/ change label font color
                    if let highlightableTF = lastCalculatedTf {
                        highlightLastCalculatedTF(textFieldTBC: highlightableTF)
                    }
                }
            } catch {
                print("Unable to Decode object (\(error))")
            }
        }
    }
    
//    redundant across 3 screens - required because IBActions
    
    @IBAction func didTouchTextField(_ sender: UITextField) {
//        print("\(sender.tag) touched")
        showKeyboard()
    }
    
    @IBAction func didTouchOutsideTextField(_ sender: UITapGestureRecognizer) {
        // get active textfield - to remove first responder when hiding keyboard
        let textField = textFields.filter { tf in
            return tf.isFirstResponder
        }.first
        
        hideKeyboard(textField)
    }
    
    @IBAction func didYearsToggle(_ sender: UISwitch) {
        let isYearsToggleOn = sender.isOn
        
        let timeNumPaymentsTextField = getTextFieldByTag(tag: 5, textFields: textFields)
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
    
    
    @IBAction func clearAllTextFields(_ sender: UIButton) {
        textFields.forEach{textField in
           // clear each textField
            textField.text = ""
        }
        
        let compoundSaving = CompoundSaving(presentValue: nil, interest: nil, monthlyPayment: nil, futureValue: nil, timeInYears: nil, lastCalculatedTag: nil)
        saveObjInUserDefaults(compoundSaving: compoundSaving)   // update UserDefaults value
        
        if lastCalculatedTfTag != nil {
            let lastCalculatedTf = getTextFieldByTag(tag: lastCalculatedTfTag!, textFields: textFields)
        
            // reset border of last calculated textfield was changed and all fields aren't full
            lastCalculatedTf?.layer.borderColor = nil
            lastCalculatedTf?.layer.borderWidth = 0
        }
        
        // hide clear all button
        clearAllButton.isHidden = true
    }
    
    func changeInput(textField: UITextField) {
        let inputTfTag = textField.tag
        
        if clearAllButton.isHidden {
            clearAllButton.isHidden = false // show clear btn
        }
        
        let isAllButOneFilled  = isAllButOneFilled(textFields: textFields)
        let isAllFilled = isAllFilled(textFields: textFields)
        let isLastCalculatedTfSame = isLastCalculatedTfSame(inputTfTag: inputTfTag, lastCalculatedTfTag: lastCalculatedTfTag)
        
        let isCalculatable = isAllButOneFilled || (isAllFilled && !isLastCalculatedTfSame)
        
        if isAllButOneFilled{
            textFields.forEach{textField in
                // remove border from all textFields
                textField.layer.borderColor = nil
                textField.layer.borderWidth = 0
            }
        }

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
            var presentValue = Double((getTextFieldByTag(tag: 1, textFields: textFields)?.text)!)
            let interest = Double((getTextFieldByTag(tag: 2, textFields: textFields)?.text)!)
            var monthlyPayment = Double((getTextFieldByTag(tag: 3, textFields: textFields)?.text)!)
            var futureValue = Double((getTextFieldByTag(tag: 4, textFields: textFields)?.text)!)
            let timeNumPayments = Double((getTextFieldByTag(tag: 5, textFields: textFields)?.text)!)

            var timeInYears: Double? = nil

            if timeNumPayments != nil{
            // convert time to years
                timeInYears = getTimeInYears(timeNumPayments:timeNumPayments!, yearsToggle: yearsToggle)
            }

            var compoundSaving = CompoundSaving(presentValue: presentValue, interest: interest, monthlyPayment: monthlyPayment, futureValue: futureValue, timeInYears: timeInYears, lastCalculatedTag: lastCalculatedTfTag)

            saveObjInUserDefaults(compoundSaving: compoundSaving)   // update UserDefaults value

            let calculatedEstimate: Double

            // calculate & display the missing field
            switch lastCalculatedTfTag {
            case 1:
                // principle amount
                calculatedEstimate = estimatePrincpleAmountRC(futureValue: futureValue!, interest: interest!, timeInYears: timeInYears!, monthlyPayment: monthlyPayment!, compoundsPerYear: GlobalConstants.COMPOUNDS_PER_YEAR)
                textFieldTBC?.text = "\(calculatedEstimate)"
                presentValue = calculatedEstimate
            case 2:
                // interest
                // TODO: show alert?
//                print("Cannot calculate interest?")
                dispalyOKAlert(message: "The app does not support the calculation of interest for compounds at the moment.", title: "Unsupported estimate calculation request")
//                textFieldTBC?.text = "\(calculatedEstimate)"
//                interest = calculatedEstimate
            case 3:
                // monthly payment
                calculatedEstimate = estimateMonthlyPaymentValueRC(futureValue: futureValue!, presentValue: presentValue!, interest: interest!, timeInYears: timeInYears!, compoundsPerYear: GlobalConstants.COMPOUNDS_PER_YEAR)
                textFieldTBC?.text = "\(calculatedEstimate)"
                monthlyPayment = calculatedEstimate
            case 4:
                // future value
                calculatedEstimate = estimateFutureValueRC(presentValue: presentValue!, interest: interest!, timeInYears: timeInYears!, monthlyPayment: monthlyPayment!, compoundsPerYear: GlobalConstants.COMPOUNDS_PER_YEAR)
                textFieldTBC?.text = "\(calculatedEstimate)"
                futureValue = calculatedEstimate
            case 5:
                // num of payments
                let timeEstimationInYears = estimateTimeInYearsRC(presentValue: presentValue!, interest: interest!, futureValue: futureValue!, monthlyPayment: monthlyPayment!, compoundsPerYear: GlobalConstants.COMPOUNDS_PER_YEAR)

                // convert this to Integer before displaying
                if yearsToggle.isOn {
                    let timeEstimationInYearsInt = Int(timeEstimationInYears)
                    textFieldTBC?.text = "\(timeEstimationInYearsInt)"
                } else {
                    let timeEstimationInNumPaymentsInt = Int(timeEstimationInYears * GlobalConstants.COMPOUNDS_PER_YEAR)
                    textFieldTBC?.text = "\(timeEstimationInNumPaymentsInt)"
                }
                timeInYears = timeEstimationInYears
            default:
               return
            }
            
            // save this after calculation in all screens. The calculated field won't be saved otherwise
            compoundSaving = CompoundSaving(presentValue: presentValue, interest: interest, monthlyPayment: monthlyPayment, futureValue: futureValue, timeInYears: timeInYears, lastCalculatedTag: lastCalculatedTfTag)

            saveObjInUserDefaults(compoundSaving: compoundSaving)   // update UserDefaults value
            
            // highlight UI of textfield with estimated value/ change label font color
            if let highlightableTF = textFieldTBC {
                highlightLastCalculatedTF(textFieldTBC: highlightableTF)
            }
            
        } else if (isAllFilled && inputTfTag == lastCalculatedTfTag) {
            // if the lastCalculatedTf was altered, show that another field has to be deleted, to generate an estimation
            // alert user that at least one field has to be empty to make an estimation
            dispalyOKAlert(message: "Clear one field to make an estimation. At least one field needs to be empty to generate an estimation.", title: "Too many fields filled")
        }
        else{
            let isAllButTwoFilled = isAllButTwoFilled(textFields: textFields)

            if isAllButTwoFilled {
                // 2 or more fields empty - reset the lastCalculatedTfTag
                
                if lastCalculatedTfTag != nil{
                    let lastCalculatedTf = getTextFieldByTag(tag: lastCalculatedTfTag!, textFields: textFields)
                    
                    lastCalculatedTf?.layer.borderColor = nil
                    lastCalculatedTf?.layer.borderWidth = 0
                    
                    lastCalculatedTfTag = nil
                    // save lastCalculatedTfTag to user defaults
                    defaults.set(lastCalculatedTfTag, forKey: "lastCalculatedTfTagSimpleSavings")
                }
            }
            
            // update UserDefaults value with whatever that's available

            // get all values in textfields and assign to relevant variables, to pass into functions
            var presentValue: Double? = nil
            if let tfText = getTextFieldByTag(tag: 1, textFields: textFields)?.text {
                presentValue = Double(tfText)
            }
            var interest: Double? = nil
            if let tfText = getTextFieldByTag(tag: 2, textFields: textFields)?.text {
                interest = Double(tfText)
            }
            var monthlyPayment: Double? = nil
            if let tfText = getTextFieldByTag(tag: 3, textFields: textFields)?.text {
                monthlyPayment = Double(tfText)
            }
            var futureValue: Double? = nil
            if let tfText = getTextFieldByTag(tag: 4, textFields: textFields)?.text {
                futureValue = Double(tfText)
            }
            var timeNumPayments: Double? = nil
            if let tfText = getTextFieldByTag(tag: 5, textFields: textFields)?.text {
                timeNumPayments = Double(tfText)
            }

            var timeInYears: Double? = nil

            if timeNumPayments != nil{
            // convert time to years
                timeInYears = getTimeInYears(timeNumPayments:timeNumPayments!, yearsToggle: yearsToggle)
            }

            let compoundSaving = CompoundSaving(presentValue: presentValue, interest: interest, monthlyPayment: monthlyPayment, futureValue: futureValue, timeInYears: timeInYears, lastCalculatedTag: lastCalculatedTfTag)

            saveObjInUserDefaults(compoundSaving: compoundSaving)   // update UserDefaults value
        }
    }

    func saveObjInUserDefaults(compoundSaving: CompoundSaving) {
        do {
            // encode & save object in user defaults
            let encodedData = try encoder.encode(compoundSaving)
            defaults.set(encodedData, forKey: COMPOUND_SAVINGS_UD_KEY)
        } catch {
            print("Error encoding simple saving, \(error)")
        }
    }
}


// MARK: Implementation of the CustomKeyboardProtocol methods
extension CompoundSavingsController: CustomKeyboardProtocol{
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
            var tfCharCount = tf.text?.count ?? 0
            if (tfCharCount) > 0 {
                //  remove last character
                tf.text!.removeLast()
                tfCharCount -= 1
                
                // run this only if the input field has any numbers
                if tfCharCount > 0 {
                    changeInput(textField: tf)
                }
            }
        }
    }
    
    func didToggleNegative() {

//         MARK: This is only needed for compound savings to show money taken out in monthly payments

        // check if this textfield can be made negative (only payments going out need a negative value) - only applied for compound savings?
        let tfTagsAllowed: [Int] = [3]

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
                
                changeInput(textField: tf)
            }
        }
    }
    
    // MARK: show/ hide keyboard
    private func showKeyboard() {
         self.keyboard.isHidden = false
         keyboardBottomConstraint.constant = 0
         UIView.animate(
             withDuration: 0.3,
             delay: 0,
             options: [.curveEaseInOut]) {
                 self.view.layoutIfNeeded()
                 self.keyboard.alpha = 1
             }
     }

     private func hideKeyboard(_ sender: UITextField?) {
         keyboardBottomConstraint.constant = keyboard.bounds.height + self.view.safeAreaInsets.bottom
         UIView.animate(
             withDuration: 0.3,
             delay: 0,
             options: [.curveEaseInOut]) {
                 self.view.layoutIfNeeded()
                 self.keyboard.alpha = 0
             } completion: { _ in
                 self.keyboard.isHidden = true
                 sender?.resignFirstResponder()
             }
     }
}
