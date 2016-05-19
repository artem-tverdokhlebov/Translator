//
//  Controller.swift
//  Translator
//
//  Created by Artem Tverdokhlebov on 5/18/16.
//  Copyright © 2016 Artem Tverdokhlebov. All rights reserved.
//

import Foundation

class Controller {
    
    var listing : String = ""
    
    var lexAnalyser : LexAnalyser? = nil
    var syntaxAnalyser : SyntaxAnalyser? = nil
    var rpnGenerator : RPNGenerator? = nil
    
    func setListing(listing : String) {
        self.listing = listing
    }
    
    func start() {
        lexAnalyser = LexAnalyser(listing: self.listing)
        
        if lexAnalyser!.errors.count > 0 {
            print(lexAnalyser!.errors)
        }
        
        if lexAnalyser!.errors.count == 0 {
            syntaxAnalyser = SyntaxAnalyser(lexemes: lexAnalyser!.lexemes)
            
            if syntaxAnalyser!.errors.count > 0 {
                print(syntaxAnalyser!.errors)
            }
            
            if syntaxAnalyser!.errors.count == 0 {
                rpnGenerator = RPNGenerator(lexemes: lexAnalyser!.lexemes)
                
                var poliz = ""
                
                for item in rpnGenerator!.RPNstack {
                    poliz += " " + item.substring
                }
                
                print(poliz)
            }
        }
    }
    
}