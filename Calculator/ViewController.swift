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
            display.text = display.text! + digit
        }
        else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }

    @IBAction func operatorTouched(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            enterTouched()
        }
        
        let operation = sender.currentTitle!
        switch operation {
        case "×": performOperation { $0 * $1 }
        case "÷": performOperation { $1 / $0 }
        case "+": performOperation { $0 + $1 }
        case "−": performOperation { $1 - $0 }
        case "√": performOperation { sqrt($0) }
        default: break
        }
    }
    
    func performOperation(operation: (Double, Double) -> Double) {
        if opStack.count >= 2 {
            displayValue = operation(opStack.removeLast(),opStack.removeLast())
            enterTouched()
        }
    }
    
    func performOperation(operation: (Double) -> Double) {
        if opStack.count >= 1 {
            displayValue = operation(opStack.removeLast())
            enterTouched()
        }
    }
    
    @IBAction func enterTouched() {
        userIsInTheMiddleOfTyping = false
        opStack.append(displayValue)
        println(opStack)
    }
    
    var displayValue: Double {
        get{
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTyping = false
        }
    }
}

