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
    
    @IBOutlet weak var yearsToggle: UISwitch!
    // TODO: set/ update this from user defaults, when the screen loads
        // TODO: positive/ negative needs to be saved and updated in the keyboard as well, based on the text in the textfield (+ or - number)
//     check the value of this when calling functions, to determine what to display
    
    @IBOutlet weak var timeNumPaymentsLabel: UILabel!
    
    var lastCalculatedTfTag:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        keyboard.deligate = self
        
        textFields.forEach{textField in
//            prevent default keyboard from opening
            textField.inputView = UIView()
            textField.inputAccessoryView = UIView()
        }
        
//         TODO: set label & placeholder of time input based on yearsToggle value loaded from user defaults, if saved
    }
    
    @IBAction func didYearsToggle(_ sender: UISwitch) {
    // Update label text, textField text & placeholder text, depending on the toggle
        
        let textField = textFields.filter { tf in
            return tf.tag == 4 // this may change based on the view
        }.first
        
        // if show years on
        if sender.isOn {
            timeNumPaymentsLabel.text = "Number of Years"
            textField?.placeholder = "Number of Years"
            
            // TODO: convert & update value if it exists
        } else{
            timeNumPaymentsLabel.text = "Number of Payments"
            textField?.placeholder = "Number of Payments"
            
            // TODO: convert & update value if it exists
        }
        
//         TODO: save value to user defaults
    }
    
    /// Check if all fields except one have been filled - to identify whether to autogenerate the result
    /// - Returns: Bool
    func isAllButOneFilled() -> Bool{
        return ( textFields.filter { tf in
            // get all textfields that have at least one character filled
            return tf.text?.count != 0
            }.count < textFields.count )
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
            if inputTfTag == lastCalculatedTfTag{
                // alert user that at least one field has to be empty to make an estimation

                // return without calculating
                return
            } else{
                // calculate the new estimation & update the value of the lastCalculatedField
            }
        }
        
        // check if one textfield is empty
//        let isAllButOneFilled = isAllButOneFilled
        
        if (isAllButOneFilled()) {
            // identify the missing field
            let unfilledTextField = textFields.filter { tf in
                return tf.text?.count == 0
            }.first
            
            print("empty textfield: \(String(describing: unfilledTextField?.tag)) \(String(describing: unfilledTextField?.placeholder))")
            lastCalculatedTfTag = unfilledTextField!.tag  // this might cause the program to crash, recheck later
            
            // calculate the missing field
//            switch <#value#> {
//            case <#pattern#>:
//                <#code#>
//            default:
//                <#code#>
//            }
            
            // display the calculated missing value
            
            
            // highlight UI of textfield with estimated value/ change label font color
        }
    }
}

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
