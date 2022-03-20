//
//  CustomKeyboard.swift
//  FinCal
//
//  Created by Dinuka Piyadigama on 2022-03-10.
//

import UIKit

protocol CustomKeyboardProtocol {
//     to notify whatever class that implements this protocol to listen to these functions/ button clicks (it's like an event listener)
    func didPressNumber(_ number: String)
    func didPressDecimal()
    func didPressDelete()
    func didToggleNegative(_ bool: Bool)
}

class CustomKeyboard: UIView {
    //    apply the protocol to this view using a deligate
    var deligate: CustomKeyboardProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        // fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        // if loadFromNib() == nil{ return }
        guard let view = loadFromNib() else {
            return
        }
        
        // set width & height of the view
        view.frame = self.bounds
        
        // embedding a generated view in this reusable view
        self.addSubview(view)
    }
    
    private func loadFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        
        let nib = UINib(nibName: "CustomKeyboard", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
        // if this can't return a UIView, it'll return a nil - optional UIView is the return type
    }
    
    // MARK: validating keyboard inputs & calling relevant delegated functions
    
    @IBAction func didPressNumber(_ sender: UIButton) {
//        print("Did press number")
        if let number = sender.titleLabel?.text{
            deligate?.didPressNumber(number)
        }
    }
    
    
    @IBAction func didPressDecimal(_ sender: UIButton) {
//        print("Did press Decimal")
        deligate?.didPressDecimal()
    }
    
    
    @IBAction func didPressDelete(_ sender: UIButton) {
//        print("Did press Delete")
        deligate?.didPressDelete()
    }
    
    @IBAction func didToggleNegativity(_ sender: UISegmentedControl) {
//        TODO: get tid of this toggle and have a button instead - easier to manage multiple input textfields
        
//        print("Did press Delete")
        print(sender.selectedSegmentIndex)
        
        if sender.selectedSegmentIndex == 1 {
            // negative value
            deligate?.didToggleNegative(true)
            
    // TODO: change selected tint in UI
        } else{
            // positive value
//            selectedSegmentIndex == 0
            deligate?.didToggleNegative(false)
        }
    }
    
}
