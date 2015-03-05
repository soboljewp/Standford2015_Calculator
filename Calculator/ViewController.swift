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
            
            history.text! += "\(operation)\n"
            
            if let result = brain.performOperation(operation) {
                displayValue = result
                history.text! += "\(result)\n"
            }
            else {
                displayValue = 0
                history.text! += "\(0)\n"
            }
        }
    }
    
    @IBAction func enterTouched() {
        userIsInTheMiddleOfTyping = false
        if let value = displayValue {
            let result = brain.pushOperand(value)
            displayValue = result
            markDisplayAsResult(false)
            
            history.text! += "\(display.text!)\n"
        }
    }
    
    @IBAction func clearTouched() {
        displayValue = 0
        history.text = ""
        displayValue = nil
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
    }
    
    // MARK:- Helpers
    func markDisplayAsResult(mark: Bool) {
        if mark {
            history.text! += "="
        }
        else {
            if history.text!.rangeOfString("=") != nil {
                history.text! = history.text!.stringByReplacingOccurrencesOfString("=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            }
        }
    }
    
    func isDisplayValueDecimal() -> Bool {
        return display.text?.rangeOfString(".") != nil
    }
    
    var displayValue: Double? {
        get{
            return NSNumberFormatter().numberFromString(display.text!)?.doubleValue
        }
        
        set {
            if let value = newValue {
                display.text! = "\(value)"
            }
            else {
                display.text! = "0"
            }
            userIsInTheMiddleOfTyping = false
        }
    }
}

