//
//  ViewController.swift
//  Lab2
//
//  Created by Artem Tverdokhlebov on 5/25/16.
//  Copyright © 2016 Artem Tverdokhlebov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var resultLabel: NSTextField!
    @IBOutlet weak var listingTextField: NSTextField!
    
    @IBAction func stackClicked(sender: NSButton) {
        
        let rpn = RPN(listing: listingTextField.stringValue + ";")
        
        resultLabel.stringValue = String(rpn.result!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

