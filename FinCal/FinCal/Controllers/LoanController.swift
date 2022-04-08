//
//  LoanController.swift
//  FinCal
//
//  Created by Dinuka Piyadigama on 2022-03-10.
//

import UIKit

class LoanController: UIViewController {
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
    let LOAN_UD_KEY = "Loan"
    
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
        if let data = UserDefaults.standard.data(forKey: LOAN_UD_KEY) {
            do {
                // Decode Note
                let loan = try decoder.decode(Loan.self, from: data)

                // display values in respective text fields
                if loan.presentValue != nil{
                    let presentValueTf =  getTextFieldByTag(tag: 1, textFields: textFields)
                    presentValueTf?.text = "\(loan.presentValue!)"
                }
                if loan.interest != nil{
                    let interestTf =  getTextFieldByTag(tag: 2, textFields: textFields)
                    interestTf?.text = "\(loan.interest!)"
                }
                if loan.monthlyPayment != nil{
                    let monthlyPaymentTf =  getTextFieldByTag(tag: 3, textFields: textFields)
                    monthlyPaymentTf?.text = "\(loan.monthlyPayment!)"
                }
                if loan.numOfPayments != nil{
                    let timeNumPaymentsTf =  getTextFieldByTag(tag: 4, textFields: textFields)
                    
                    let numOfPayments = loan.numOfPayments
                    if yearsToggle.isOn {
                        let timeInNumPayments = numOfPayments! / GlobalConstants.COMPOUNDS_PER_YEAR
                        timeNumPaymentsTf?.text = "\(timeInNumPayments)"
                    } else{
                        timeNumPaymentsTf?.text = "\(numOfPayments!)"
                    }
                }
                // MARK: load lastCalculatedTfTag of SimpleSavings
                lastCalculatedTfTag = loan.lastCalculatedTag
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
    
    @IBAction func clearAllTextFields(_ sender: UIButton) {
        textFields.forEach{textField in
           // clear each textField
            textField.text = ""
        }
        
        let loan = Loan(presentValue: nil, interest: nil, monthlyPayment: nil, numOfPayments: nil, lastCalculatedTag: nil)

        saveObjInUserDefaults(loan: loan)   // update UserDefaults value
        
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
            var presentValue = Double((getTextFieldByTag(tag: 1, textFields: textFields)?.text)!)
            var interest = Double((getTextFieldByTag(tag: 2, textFields: textFields)?.text)!)
            var monthlyPayment = Double((getTextFieldByTag(tag: 3, textFields: textFields)?.text)!)
            let timeNumPayments = Double((getTextFieldByTag(tag: 4, textFields: textFields)?.text)!)

            var numOfPayments: Double? = nil

            if timeNumPayments != nil{
                // convert timeNumPayments to num of payments
                numOfPayments = getTimeInNumOfPayments(timeNumPayments:timeNumPayments!, yearsToggle: yearsToggle)
            }

            var loan = Loan(presentValue: presentValue, interest: interest, monthlyPayment: monthlyPayment, numOfPayments: numOfPayments, lastCalculatedTag: lastCalculatedTfTag)

            saveObjInUserDefaults(loan: loan)   // update UserDefaults value

            let calculatedEstimate: Double

            // calculate & display the missing field
            switch lastCalculatedTfTag {
            case 1:
                // principle amount - loan amount
                calculatedEstimate = estimateLoanPrincpleAmount(interest: interest!, noOfPayments: numOfPayments!, monthlyPayment: monthlyPayment!)
                textFieldTBC?.text = "\(calculatedEstimate)"
                presentValue = calculatedEstimate
            case 2:
                // interest
                calculatedEstimate = estimateLoanInterest(presentValue: presentValue!, noOfPayments: numOfPayments!, monthlyPayment: monthlyPayment!)
                textFieldTBC?.text = "\(calculatedEstimate)"
                interest = calculatedEstimate
            case 3:
                // monthly payment
                calculatedEstimate = estimateLoanMonthlyPayment(presentValue: presentValue!, interest: interest!, noOfPayments: numOfPayments!)
                textFieldTBC?.text = "\(calculatedEstimate)"
                monthlyPayment = calculatedEstimate
            case 4:
                // num of payments
                do {
                    let timeEstimationInNumOfPayments = try estimateLoanNumOfPayments(presentValue: presentValue!, interest: interest!, monthlyPayment: monthlyPayment!)

                    // convert this to Integer before displaying
                    if yearsToggle.isOn {
                        let timeEstimationInYearsInt = Int(Double(timeEstimationInNumOfPayments) / GlobalConstants.COMPOUNDS_PER_YEAR)
                        textFieldTBC?.text = "\(timeEstimationInYearsInt)"
                    } else {
                        let timeEstimationInNumPaymentsInt = Int(timeEstimationInNumOfPayments)
                        textFieldTBC?.text = "\(timeEstimationInNumPaymentsInt)"
                    }
                    
                    numOfPayments = Double(timeEstimationInNumOfPayments)
                } catch{
                 // TODO: show alert?
                    print(error)
                }
            default:
                return
            }
            
            // save this after calculation in all screens!! The calculated field won't be saved otherwise
            loan = Loan(presentValue: presentValue, interest: interest, monthlyPayment: monthlyPayment, numOfPayments: numOfPayments, lastCalculatedTag: lastCalculatedTfTag)

            saveObjInUserDefaults(loan: loan)   // update UserDefaults value
            
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
        else{
            // update UserDefaults value with whatever that's available
//            FIXME: this is a problem - JSONEncoder error if nil values are there?
//        debugDescription: "Unable to encode Double.nan directly in JSON. Use JSONEncoder.NonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded.", underlyingError: nil))
            
            // get all values in textfields and assign to relevant variables, to pass into functions
//            let presentValue = Double((getTextFieldByTag(tag: 1, textFields: textFields)?.text)!)
//            let interest = Double((getTextFieldByTag(tag: 2, textFields: textFields)?.text)!)
//            let monthlyPayment = Double((getTextFieldByTag(tag: 3, textFields: textFields)?.text)!)
//            let timeNumPayments = Double((getTextFieldByTag(tag: 4, textFields: textFields)?.text)!)
//
//            var numOfPayments: Double? = nil
//
//            if timeNumPayments != nil{
//                // convert timeNumPayments to num of payments
//                numOfPayments = getTimeInNumOfPayments(timeNumPayments:timeNumPayments!, yearsToggle: yearsToggle)
//            }
//
//            let loan = Loan(presentValue: presentValue, interest: interest, monthlyPayment: monthlyPayment, numOfPayments: numOfPayments, lastCalculatedTag: lastCalculatedTfTag)
//
//            saveObjInUserDefaults(loan: loan)   // update UserDefaults value
        }
    }
    
    func getTimeInNumOfPayments(timeNumPayments:Double, yearsToggle:UISwitch) -> Double? {
        var timeInNumOfPayments: Double?
        if yearsToggle.isOn {
            timeInNumOfPayments = timeNumPayments * GlobalConstants.COMPOUNDS_PER_YEAR
        } else {
            timeInNumOfPayments = timeNumPayments
        }
        
        return timeInNumOfPayments
    }
    
    func saveObjInUserDefaults(loan:Loan) {
        do {
            // encode & save object in user defaults
            let encodedData = try encoder.encode(loan)
            defaults.set(encodedData, forKey: LOAN_UD_KEY)
        } catch {
            print("Error encoding simple saving, \(error)")
        }
    }
}


// MARK: Implementation of the CustomKeyboardProtocol methods
extension LoanController: CustomKeyboardProtocol{
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
//
////         MARK: This is only needed for compound savings to show money taken out in monthly payments
//
//        // check if this textfield can be made negative (only payments going out need a negative value) - only applied for compound savings?
//        let tfTagsAllowed: [Int] = []
//
//        let textField = textFields.filter { tf in
//            return tf.isFirstResponder
//        }.first
//
//        if let tf = textField {
//            let tfTag = tf.tag
//            if tfTagsAllowed.contains(tfTag) {
//                var tfText: Double = NSString(string: tf.text ?? "0").doubleValue
//
//                if tf.text?.first == "-" {
//                    tfText = abs(tfText)  // make positive
//                    tf.text! = "\(tfText)"
//                } else{
//                    tf.text! = "-\(tfText)"
//                }
//            }
//        }
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
