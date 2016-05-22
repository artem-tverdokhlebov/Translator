//
//  Controller.swift
//  Translator
//
//  Created by Artem Tverdokhlebov on 5/18/16.
//  Copyright © 2016 Artem Tverdokhlebov. All rights reserved.
//

import Cocoa
import Foundation

class RPNInterpreter {
    
    var listing : String = ""
    
    var lexAnalyser : LexAnalyser? = nil
    var syntaxAnalyser : SyntaxAnalyser? = nil
    var rpnGenerator : RPNGenerator? = nil
    
    var outputTextView : NSTextView? = nil
    
    internal var IDNs : [String : (index: Int, name: String, value: Float?)] = [String : (index: Int, name: String, value: Float?)]()
    internal var CONs : [String : (index: Int, name: String, value: Float)] = [String : (index: Int, name: String, value: Float)]()
    
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
                
                //print(poliz)
                
                for item in lexAnalyser!.IDNs {
                    IDNs[item.name] = (index: item.index, name: item.name, value: 0)
                }
                
                /*for item in lexAnalyser!.CONs {
                 CONs[item.name] = (index: item.index, name: item.name, value: (item.name as NSString).floatValue)
                 }*/
                
                operations()
            }
        }
    }
    
    func inputReal(IDN : String) -> Float {
        let alert: NSAlert = NSAlert()
        alert.icon = nil
        alert.messageText = "Input value of \(IDN):"
        alert.addButtonWithTitle("OK")
        let input: NSTextField = NSTextField(frame: NSMakeRect(0, 0, 200, 24))
        input.stringValue = ""
        
        alert.accessoryView = input
        let button: Int = alert.runModal()
        if button == NSAlertFirstButtonReturn {
            return input.floatValue
        } else {
            return inputReal(IDN)
        }
    }
    
    func operations() {
        var stack : [Lexeme] = [Lexeme]()
        var realValue : Float = 0.0
        var boolValue : Bool = false
        
        for var i : Int in 0 ..< rpnGenerator!.RPNstack.count {
            let entry = rpnGenerator!.RPNstack[i]
            
            if LexTable.isIDN(entry) || LexTable.isCON(entry) {
                stack.insert(entry, atIndex: 0)
            } else {
                switch entry.name {
                case ">":
                    let r2 : Float? = ((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value
                    let r1 : Float? = ((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value
                    
                    boolValue = r1 > r2
                    stack.insert((lineNumber: -1, name: boolValue.description, substring: boolValue.description, index: 0), atIndex: 0)
                    
                    break
                case "<":
                    let r2 : Float? = ((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value
                    let r1 : Float? = ((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value
                    
                    boolValue = r1 < r2
                    stack.insert((lineNumber: -1, name: boolValue.description, substring: boolValue.description, index: 0), atIndex: 0)
                    
                    break
                case "<=":
                    let r2 : Float? = ((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value
                    let r1 : Float? = ((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value
                    
                    boolValue = r1 <= r2
                    stack.insert((lineNumber: -1, name: boolValue.description, substring: boolValue.description, index: 0), atIndex: 0)
                    
                    break
                case ">=":
                    let r2 : Float? = ((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value
                    let r1 : Float? = ((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value
                    
                    boolValue = r1 >= r2
                    stack.insert((lineNumber: -1, name: boolValue.description, substring: boolValue.description, index: 0), atIndex: 0)
                    
                    break
                case "=":
                    let r2 : Float? = ((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value
                    let r1 : Float? = ((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value
                    
                    boolValue = r1 == r2
                    stack.insert((lineNumber: -1, name: boolValue.description, substring: boolValue.description, index: 0), atIndex: 0)
                    
                    break
                case "!=":
                    let r2 : Float? = ((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value
                    let r1 : Float? = ((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value
                    
                    boolValue = r1 != r2
                    stack.insert((lineNumber: -1, name: boolValue.description, substring: boolValue.description, index: 0), atIndex: 0)
                    
                    break
                case "not":
                    boolValue = (stack.removeFirst().name as NSString).boolValue
                    
                    stack.insert((lineNumber: -1, name: (!boolValue).description, substring: (!boolValue).description, index: 0), atIndex: 0)
                    
                    break
                case "and":
                    let b1 : Bool = (stack.removeFirst().name as NSString).boolValue
                    let b2 : Bool = (stack.removeFirst().name as NSString).boolValue
                    
                    boolValue = b1 && b2
                    stack.insert((lineNumber: -1, name: boolValue.description, substring: boolValue.description, index: 0), atIndex: 0)
                    
                    break
                case "or":
                    let b1 : Bool = (stack.removeFirst().name as NSString).boolValue
                    let b2 : Bool = (stack.removeFirst().name as NSString).boolValue
                    
                    boolValue = b1 || b2
                    stack.insert((lineNumber: -1, name: boolValue.description, substring: boolValue.description, index: 0), atIndex: 0)
                    
                    break
                case "+":
                    let r2 : Float = ((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value!
                    
                    realValue = (((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value!)
                    
                    realValue += r2
                    stack.insert((lineNumber: -1, name: "con", substring: realValue.description, index: LexTable.getCode("con")), atIndex: 0)
                    
                    break
                case "-":
                    let r2 : Float = ((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value!
                    
                    realValue = (((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value!)
                    
                    realValue -= r2
                    stack.insert((lineNumber: -1, name: "con", substring: realValue.description, index: LexTable.getCode("con")), atIndex: 0)
                    
                    break
                case "*":
                    let r2 : Float = ((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value!
                    
                    realValue = (((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value!)
                    
                    realValue *= r2
                    stack.insert((lineNumber: -1, name: "con", substring: realValue.description, index: LexTable.getCode("con")), atIndex: 0)
                    
                    break
                case "/":
                    let r2 : Float = ((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value!
                    
                    realValue = (((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value!)
                    
                    realValue /= r2
                    stack.insert((lineNumber: -1, name: "con", substring: realValue.description, index: LexTable.getCode("con")), atIndex: 0)
                    
                    break
                case "@":
                    realValue = (((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value!)
                    
                    stack.insert((lineNumber: -1, name: "con", substring: (-realValue).description, index: LexTable.getCode("con")), atIndex: 0)
                    
                    break
                case ":=":
                    print(stack)
                    realValue = (((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value!)
                    
                    IDNs[stack.removeFirst().substring]!.value = realValue
                    
                    break
                case "read":
                    IDNs[stack.first!.substring]!.value = inputReal(stack.removeFirst().substring)
                    
                    break
                case "write":
                    outputTextView!.string = outputTextView!.string! + "\n\(stack.first!.substring) = \(IDNs[stack.removeFirst().substring]!.value)"
                    
                    break
                case "УПЛ":
                    if !((stack.removeLast().substring as NSString).boolValue) {
                        i = 0
                        //jump
                    }
                    
                    break
                    
                default:
                    if entry.substring.containsString(":") {
                        stack = stack.filter({ (item) -> Bool in
                            return item.index != -3
                        })
                    }
                    
                    break
                }
            }
            
            
        }
    }
}