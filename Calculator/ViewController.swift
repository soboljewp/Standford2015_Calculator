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
    
    var opStack: [Double] = []
    
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
            if digit == "." && display.text?.rangeOfString(".") != nil {
                return
            }
            
            display.text = display.text! + digit
        }
        else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }

    @IBAction func operatorTouched(sender: UIButton) {
        let operation = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            if operation != "±" {
                enterTouched()
            }
            else {
                display.text! = "-" + display.text!
                return
            }
            
        }
        
        history.text! += "\(operation)\n"
        
        switch operation {
        case "×": performOperation { $0 * $1 }
        case "÷": performOperation { $1 / $0 }
        case "+": performOperation { $0 + $1 }
        case "−": performOperation { $1 - $0 }
        case "√": performOperation { sqrt($0) }
        case "sin": performOperation { sin($0) }
        case "cos": performOperation { cos($0) }
        case "π": performOperation { M_PI }
        case "±": performOperation { -1 * $0 }
        default: break
        }
    }
    
    @IBAction func enterTouched() {
        userIsInTheMiddleOfTyping = false
        if let value = displayValue {
            opStack.append(value)
            println(opStack)
            
            markDisplayAsResult(false)
            
            history.text! += "\(display.text!)\n"
        }

    }
    
    @IBAction func clearTouched() {
        history.text = ""
        displayValue = nil
        opStack.removeAll(keepCapacity: true)
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
    func performOperation(operation: (Double, Double) -> Double) {
        if opStack.count >= 2 {
            displayValue = operation(opStack.removeLast(),opStack.removeLast())
            enterTouched()
            markDisplayAsResult(true)
        }
    }
    
    func performOperation(operation: (Double) -> Double) {
        if opStack.count >= 1 {
            displayValue = operation(opStack.removeLast())
            enterTouched()
            markDisplayAsResult(true)
        }
    }
    
    func performOperation(operation: () -> Double) {
        displayValue = operation()
        enterTouched()
    }
    
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

