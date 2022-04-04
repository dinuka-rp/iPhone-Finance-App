//
//  LoanController.swift
//  FinCal
//
//  Created by Dinuka Piyadigama on 2022-03-10.
//

import UIKit

class LoanController: UIViewController {
    @IBOutlet weak var keyboard: CustomKeyboard!
    
    @IBOutlet var textFields: [UITextField]!
    
    //     check the value of this when calling functions, to determine what to display
    @IBOutlet weak var yearsToggle: UISwitch!
    
    @IBOutlet weak var timeNumPaymentsLabel: UILabel!

    var lastCalculatedTfTag:Int?
    
    let defaults = UserDefaults.standard
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    // user defaults keys
    let LOAN_UD_KEY = "Loan"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
    
//    redundant across 3 screens
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
    
//    TODO: Update this to match with loan requirement
//    func changeInput(textField: UITextField) {
//        let inputTfTag = textField.tag
//
//        let isAllButOneFilled  = isAllButOneFilled(textFields: textFields)
//        let isAllFilled = isAllFilled(textFields: textFields)
//        let isCalculatable = isAllButOneFilled || (isAllFilled && inputTfTag != lastCalculatedTfTag)
//
//
//        // check if it's possible to make a calculation
//        if (isCalculatable) {
//            // identify the missing field/ tf to be calculateed
//            var textFieldTBC = textFields.filter { tf in
//                return tf.text?.count == 0  // can use isEmpty as well
//            }.first
//
////            print("empty textfield: \(String(describing: textFieldTBC?.tag)) \(String(describing: textFieldTBC?.placeholder))")
//            if textFieldTBC?.tag != nil {
//                lastCalculatedTfTag = textFieldTBC!.tag
//            } else {
//                textFieldTBC = getTextFieldByTag(tag: lastCalculatedTfTag!, textFields: textFields)
//            }
//
//            // get all values in textfields and assign to relevant variables, to pass into functions
//            let presentValue = Double((getTextFieldByTag(tag: 1, textFields: textFields)?.text)!)
//            let interest = Double((getTextFieldByTag(tag: 2, textFields: textFields)?.text)!)
//            let futureValue = Double((getTextFieldByTag(tag: 3, textFields: textFields)?.text)!)
//            let timeNumPayments = Double((getTextFieldByTag(tag: 4, textFields: textFields)?.text)!)
//
//            var timeInYears: Double? = nil
//
//            if timeNumPayments != nil{
//            // convert time to years
//                timeInYears = getTimeInYears(timeNumPayments:timeNumPayments!, yearsToggle: yearsToggle)
//            }
//
//            let simpleSaving = SimpleSaving(presentValue: presentValue, interest: interest, futureValue: futureValue, timeInYears: timeInYears, lastCalculatedTag: lastCalculatedTfTag)
//
//            do {
//                // encode & save object in user defaults
//                let encodedData = try encoder.encode(simpleSaving)
//                defaults.set(encodedData, forKey: LOAN_UD_KEY)
//            } catch {
//                print("Error encoding simple saving, \(error)")
//            }
//
//            let calculatedEstimate: Double
//
//            // calculate & display the missing field
//            switch lastCalculatedTfTag {
//            case 1:
//                // principle amount
//                calculatedEstimate = estimatePrincpleAmountFS(futureValue: futureValue!, interest: interest!, timeInYears: timeInYears!, compoundsPerYear: GlobalConstants.COMPOUNDS_PER_YEAR)
//                textFieldTBC?.text = "\(calculatedEstimate)"
//            case 2:
//                // interest
//                calculatedEstimate = estimateInterestFS(presentValue: presentValue!, futureValue: futureValue!, timeInYears: timeInYears!, compoundsPerYear: GlobalConstants.COMPOUNDS_PER_YEAR)
//                textFieldTBC?.text = "\(calculatedEstimate)"
//            case 3:
//                // future value
//                calculatedEstimate = estimateFutureValueFS(presentValue: presentValue!, interest: interest!, timeInYears: timeInYears!, compoundsPerYear: GlobalConstants.COMPOUNDS_PER_YEAR)
//                textFieldTBC?.text = "\(calculatedEstimate)"
//            case 4:
//                // num of payments
//                let timeEstimationInYears = estimateTimeInYearsFS(presentValue: presentValue!, interest: interest!, futureValue: futureValue!, compoundsPerYear: GlobalConstants.COMPOUNDS_PER_YEAR)
//
//                // convert this to Integer before displaying
//                if yearsToggle.isOn {
//                    let timeEstimationInYearsInt = Int(timeEstimationInYears)
//                    textFieldTBC?.text = "\(timeEstimationInYearsInt)"
//                } else {
//                    let timeEstimationInNumPaymentsInt = Int(timeEstimationInYears * GlobalConstants.COMPOUNDS_PER_YEAR)
//                    textFieldTBC?.text = "\(timeEstimationInNumPaymentsInt)"
//                }
//            default:
//                return
//            }
//            // highlight UI of textfield with estimated value/ change label font color
//
//        } else if (isAllFilled && inputTfTag == lastCalculatedTfTag) {
//            // if the lastCalculatedTf was altered, show that another field has to be deleted, to generate an estimation
//            // TODO: alert user that at least one field has to be empty to make an estimation
//            print("Delete another field to make an estimation. At least one field needs to be empty for an estimation.")
//        }
////     TODO:   else if {
////            // 2 or more fields empty - reset the lastCalculatedTfTag
////            lastCalculatedTfTag = nil
////            // save lastCalculatedTfTag to user defaults
////            defaults.set(lastCalculatedTfTag, forKey: "lastCalculatedTfTagSimpleSavings")
////        }
//    }
}


//TODO: update this with latest after fixing +/- in SimpleSavingsController
//extension LoanController: CustomKeyboardProtocol{
//
//}
