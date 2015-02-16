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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func numberTouched(sender: UIButton) {
        if (userIsInTheMiddleOfTyping) {
            display.text! += sender.currentTitle!
        }
        else {
            display.text = sender.currentTitle
            userIsInTheMiddleOfTyping = true
        }
    }

}

