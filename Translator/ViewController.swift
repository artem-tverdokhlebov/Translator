//
//  ViewController.swift
//  Translator
//
//  Created by Artem Tverdokhlebov on 4/27/16.
//  Copyright © 2016 Artem Tverdokhlebov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func buttonClicked(sender: NSButton) {
        let lexAnalyser : LexAnalyser = LexAnalyser( listing: textView.string!)
        
        let syntaxAnalyser = SyntaxAnalyser(lexemes: lexAnalyser.lexemes)

        print(lexAnalyser.errors)
        print(syntaxAnalyser.errors)
    }
    
}

