//
//  Controller.swift
//  Translator
//
//  Created by Artem Tverdokhlebov on 5/18/16.
//  Copyright © 2016 Artem Tverdokhlebov. All rights reserved.
//

import Cocoa
import Foundation

class Controller {
    
    var listing : String = ""
    
    var lexAnalyser : LexAnalyser? = nil
    var syntaxAnalyser : SyntaxAnalyser? = nil
    var rpnGenerator : RPNGenerator? = nil
    
    var outputTextView : NSTextView? = nil
    
    func setListing(listing : String) {
        self.listing = listing
    }
    
    func setOutputTextView(output : NSTextView) {
        outputTextView = output
    }
    
    func start() {
        lexAnalyser = LexAnalyser(listing: self.listing)
        
        if lexAnalyser!.errors.count > 0 {
            print(lexAnalyser!.errors)
            
            outputTextView!.string = outputTextView!.string! + "Lexeme analyser errors:\n"
            
            for e in lexAnalyser!.errors {
                outputTextView!.string = outputTextView!.string! + "\n" + e
            }
        }
        
        if lexAnalyser!.errors.count == 0 {
            syntaxAnalyser = SyntaxAnalyser(lexemes: lexAnalyser!.lexemes)
            
            if syntaxAnalyser!.errors.count > 0 {
                outputTextView!.string = outputTextView!.string! + "Syntax analyser errors:\n"
                
                for e in syntaxAnalyser!.errors {
                    outputTextView!.string = outputTextView!.string! + "\n" + e
                }
            }
            
            if syntaxAnalyser!.errors.count == 0 {
                rpnGenerator = RPNGenerator(lexemes: lexAnalyser!.lexemes)
                
                var poliz = ""
                
                for item in rpnGenerator!.RPNstack {
                    poliz += " " + item.substring
                }
            }
        }
    }
    
    func operations() {
        var stack : [Lexeme] = [Lexeme]()
        var realValue : Float = 0.0
        var boolValue : Bool = false
        
        for entry in rpnGenerator!.RPNstack {
            if LexTable.isIDN(entry) || LexTable.isCON(entry) {
                stack.append(entry)
            } else {
                switch entry.name {
                case ">":
                
                    break
                default:
                    break
                }
            }
            
            
        }
    }
}