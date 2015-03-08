//
//  ViewController.swift
//  Calculator
//
//  Created by Patrick Dawson on 16.02.15.
//  Copyright (c) 2015 Patrick Dawson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTyping: Bool = false
    
    var brain = CalculatorBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func numberTouched(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            if digit != "." || (digit == "." && !isDisplayValueDecimal()) {
                display.text = display.text! + digit
            }
        }
        else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
            history.text = " "
        }
    }

    @IBAction func operatorTouched(sender: UIButton) {
        
        if let operation = sender.currentTitle {
            if userIsInTheMiddleOfTyping {
                if operation == "±" {
                    display.text! = "-" + display.text!
                    return
                }
                else {
                    enterTouched()
                }
            }
            
            displayValue = brain.performOperation(operation)
            history.text = brain.description
        }
    }
    
    @IBAction func enterTouched() {
        userIsInTheMiddleOfTyping = false
        if let value = displayValue {
            displayValue = brain.pushOperand(value)
            history.text = brain.description
        }
    }
    
    @IBAction func clearTouched() {
        displayValue = 0
        history.text = " "
        
        brain.clearStack()
        brain.clearVariables()
    }
    
    @IBAction func backTouched() {
        if userIsInTheMiddleOfTyping {
            let characters = countElements(display.text!)
            if characters > 1 {
                display.text! = dropLast(display.text!)
            }
            else {
                displayValue = 0
            }
        }
        else {
            brain.popOperandFromStack()
            updateDisplay()
        }
    }
    @IBAction func storeDisplayIntoVariable() {
        if let value = displayValue {
            brain.variableValues["M"] = value
            updateDisplay()
        }
    }

    @IBAction func pushVariable() {
        displayValue = brain.pushOperand("M")
        history.text = brain.description
    }
    
    // MARK:- Helpers
    func isDisplayValueDecimal() -> Bool {
        return display.text?.rangeOfString(".") != nil
    }
    
    func updateDisplay() {
        displayValue = brain.evaluate()
        history.text = brain.description
    }
    
    var displayValue: Double? {
        get{
            let result = NSNumberFormatter().numberFromString(display.text!)?.doubleValue
            return result
        }
        
        set {
            if let value = newValue {
                display.text! = "\(value)"
            }
            else {
                display.text! = " "
            }
            userIsInTheMiddleOfTyping = false
        }
    }
}

