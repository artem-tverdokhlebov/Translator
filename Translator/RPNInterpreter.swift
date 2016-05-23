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
    
    var viewController : ViewController
    
    internal var IDNs : [String : (index: Int, name: String, value: Float?)] = [String : (index: Int, name: String, value: Float?)]()
    internal var CONs : [String : (index: Int, name: String, value: Float)] = [String : (index: Int, name: String, value: Float)]()
    
    func setListing(listing : String) {
        self.listing = listing
    }
    
    init(viewController : ViewController) {
        self.viewController = viewController
        viewController.outputTextView.string = ""
    }
    
    func start() {
        viewController.lexIndicator.startAnimation(self)
        
        lexAnalyser = LexAnalyser(listing: self.listing)
        
        viewController.lexIndicator.stopAnimation(self)
        
        if lexAnalyser!.errors.count > 0 {
            print(lexAnalyser!.errors)
            
            viewController.outputTextView!.string = viewController.outputTextView!.string! + "Lexeme analyser errors:\n"
            
            for e in lexAnalyser!.errors {
                viewController.outputTextView!.string = viewController.outputTextView!.string! + "\n" + e
            }
        }
        
        if lexAnalyser!.errors.count == 0 {
            viewController.syntaxIndicator.startAnimation(self)
            
            syntaxAnalyser = SyntaxAnalyser(lexemes: lexAnalyser!.lexemes)
            
            viewController.syntaxIndicator.stopAnimation(self)
            
            if syntaxAnalyser!.errors.count > 0 {
                viewController.outputTextView!.string = viewController.outputTextView!.string! + "Syntax analyser errors:\n"
                
                for e in syntaxAnalyser!.errors {
                    viewController.outputTextView!.string = viewController.outputTextView!.string! + "\n" + e
                }
            }
            
            if syntaxAnalyser!.errors.count == 0 {
                viewController.rpnInterpreterIndicator.startAnimation(self)
                
                rpnGenerator = RPNGenerator(lexemes: lexAnalyser!.lexemes)
                
                for item in lexAnalyser!.IDNs {
                    IDNs[item.name] = (index: item.index, name: item.name, value: 0)
                }
                
                IDNs["r1"] = (index: LexTable.getCode("idn"), name: "r1", value: 0)
                IDNs["r2"] = (index: LexTable.getCode("idn"), name: "r2", value: 0)
                
                operations()
                
                viewController.rpnInterpreterIndicator.stopAnimation(self)
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
        
        for(var i : Int = 0; i < rpnGenerator!.RPNstack.count; i += 1) {
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
                    print(stack)
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
                    realValue = (((stack.first?.name)! == "con") ? (stack.removeFirst().substring as NSString).floatValue : IDNs[stack.removeFirst().substring]!.value!)
                    
                    IDNs[stack.removeFirst().substring]!.value = realValue
                    
                    break
                case "read":
                    IDNs[stack.first!.substring]!.value = inputReal(stack.removeFirst().substring)
                    
                    break
                case "write":
                    viewController.outputTextView!.string = viewController.outputTextView!.string! + "\n\(stack.first!.substring) = \(String(format: "%.5f", IDNs[stack.removeFirst().substring]!.value!))"
                    
                    break
                case "УПЛ":
                    let label = stack.removeFirst()
                    
                    if !((stack.removeFirst().substring as NSString).boolValue) {
                        i = (rpnGenerator!.labels[label.substring + ":"]?.address)! - 1
                    }
                    
                    break
                    
                case "БП":
                    let label = stack.removeFirst()
                    
                    i = (rpnGenerator!.labels[label.substring + ":"]?.address)! - 1
                    
                    break
                default:
                    stack.insert(entry, atIndex: 0)
                    
                    break
                }
            }
            
            
            
        }
    }
}