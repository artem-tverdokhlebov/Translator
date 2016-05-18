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
        let lexAnalyser : LexAnalyser = LexAnalyser(listing: textView.string!)
        
        print(lexAnalyser.errors)
        
        let syntaxAnalyser = SyntaxAnalyser(lexemes: lexAnalyser.lexemes)
        
        print(syntaxAnalyser.errors)
        
        let rpnGenerator = RPNGenerator(lexemes: lexAnalyser.lexemes)
        
        var poliz = ""
        
        for item in rpnGenerator.RPNstack {
            poliz += " " + item.substring
        }
        
        print(poliz)
        
        //print(lexAnalyser.lexemes)
    }
    
}

