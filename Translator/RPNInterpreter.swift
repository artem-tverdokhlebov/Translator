//
//  Controller.swift
//  Translator
//
//  Created by Artem Tverdokhlebov on 5/18/16.
//  Copyright © 2016 Artem Tverdokhlebov. All rights reserved.
//

import Cocoa
import Foundation

enum InterpreterError: ErrorType {
    case NilException(variable: String)
}

class RPNInterpreter {
    
    var listing : String = ""
    
    var lexAnalyser : LexAnalyser? = nil
    var syntaxAnalyser : SyntaxAnalyser? = nil
    var rpnGenerator : RPNGenerator? = nil
    
    var viewController : ViewController
    
    var output : String = ""
    
    internal var IDNs : [String : (index: Int, name: String, value: Float?)] = [String : (index: Int, name: String, value: Float?)]()
    internal var CONs : [String : (index: Int, name: String, value: Float)] = [String : (index: Int, name: String, value: Float)]()
    
    func setListing(listing : String) {
        self.listing = listing
    }
    
    init(viewController : ViewController) {
        self.viewController = viewController
        output = ""
    }
    
    func start() {
        lexAnalyser = LexAnalyser(listing: self.listing)
        
        if lexAnalyser!.errors.count > 0 {
            output += "\nLexeme analyser errors:\n" + (lexAnalyser!.errors).joinWithSeparator("\n")
        }
        
        if lexAnalyser!.errors.count == 0 {
            syntaxAnalyser = SyntaxAnalyser(lexemes: lexAnalyser!.lexemes)
            
            if syntaxAnalyser!.errors.count > 0 {
                output += "\nSyntax analyser errors:\n" + (syntaxAnalyser!.errors).joinWithSeparator("\n")
            }
            
            if syntaxAnalyser!.errors.count == 0 {
                rpnGenerator = RPNGenerator(lexemes: lexAnalyser!.lexemes)
                
                for item in lexAnalyser!.IDNs {
                    IDNs[item.name] = (index: item.index, name: item.name, value: nil)
                }
                
                IDNs["r1"] = (index: LexTable.getCode("idn"), name: "r1", value: 0)
                IDNs["r2"] = (index: LexTable.getCode("idn"), name: "r2", value: 0)
                
                do {
                    try operations()
                } catch InterpreterError.NilException(let variable) {
                    output += "\nError: \(variable) wasn't initialized"
                } catch {
                    output += "Unknown error"
                }
            }
        }
    }
    
    
    private func inputReal(IDN : String) -> Float {
        let alert: NSAlert = NSAlert()
        alert.icon = nil
        alert.messageText = "Input value of \(IDN):"
        alert.addButtonWithTitle("OK")
        let input: NSTextField = NSTextField(frame: NSMakeRect(0, 0, 200, 24))
        input.stringValue = ""
        
        alert.accessoryView = input
        let button: Int = alert.runModalSheet()
        if button == NSAlertFirstButtonReturn {
            return input.floatValue
        } else {
            return inputReal(IDN)
        }
    }
    
    func operations() throws {
        var stack : [Lexeme] = [Lexeme]()
        var boolValue : Bool = false
        
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = 1
        formatter.minimumSignificantDigits = 1
        formatter.numberStyle = .DecimalStyle
        
        for(var i : Int = 0; i < rpnGenerator!.RPNstack.count; i += 1) {
            let entry = rpnGenerator!.RPNstack[i]
            
            if LexTable.isIDN(entry) || LexTable.isCON(entry) {
                stack.insert(entry, atIndex: 0)
            } else {
                switch entry.name {
                case ">":
                    guard let r2 : Float? = ((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value where r2 != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    guard let r1 : Float? = ((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value where r1 != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    boolValue = r1! > r2!
                    stack.insert((lineNumber: -1, name: boolValue.description, substring: boolValue.description, index: 0), atIndex: 0)
                    
                    break
                case "<":
                    guard let r2 : Float? = ((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value where r2 != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    guard let r1 : Float? = ((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value where r1 != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    boolValue = r1! < r2!
                    stack.insert((lineNumber: -1, name: boolValue.description, substring: boolValue.description, index: 0), atIndex: 0)
                    
                    break
                case "<=":
                    guard let r2 : Float? = ((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value where r2 != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    guard let r1 : Float? = ((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value where r1 != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    boolValue = r1! <= r2!
                    stack.insert((lineNumber: -1, name: boolValue.description, substring: boolValue.description, index: 0), atIndex: 0)
                    
                    break
                case ">=":
                    guard let r2 : Float? = ((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value where r2 != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    guard let r1 : Float? = ((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value where r1 != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    boolValue = r1! >= r2!
                    stack.insert((lineNumber: -1, name: boolValue.description, substring: boolValue.description, index: 0), atIndex: 0)
                    
                    break
                case "=":
                    guard let r2 : Float? = ((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value where r2 != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    guard let r1 : Float? = ((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value where r1 != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    boolValue = r1! == r2!
                    stack.insert((lineNumber: -1, name: boolValue.description, substring: boolValue.description, index: 0), atIndex: 0)
                    
                    break
                case "!=":
                    guard let r2 : Float? = ((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value where r2 != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    guard let r1 : Float? = ((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value where r1 != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    boolValue = r1! != r2!
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
                    guard let r2 : Float? = ((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value where r2 != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    guard var realValue : Float? = ((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value where realValue != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    realValue = realValue! + r2!
                    stack.insert((lineNumber: -1, name: "con", substring: realValue!.description, index: LexTable.getCode("con")), atIndex: 0)
                    
                    break
                case "-":
                    guard let r2 : Float? = ((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value where r2 != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    guard var realValue : Float? = (((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value) where realValue != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    realValue = realValue! - r2!
                    stack.insert((lineNumber: -1, name: "con", substring: realValue!.description, index: LexTable.getCode("con")), atIndex: 0)
                    
                    break
                case "*":
                    guard let r2 : Float? = ((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value where r2 != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    guard var realValue : Float? = (((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value) where realValue != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    realValue = realValue! * r2!
                    stack.insert((lineNumber: -1, name: "con", substring: realValue!.description, index: LexTable.getCode("con")), atIndex: 0)
                    
                    break
                case "/":
                    guard let r2 : Float? = ((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value where r2 != nil else  {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    guard var realValue : Float? = (((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value) where realValue != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    realValue = realValue! / r2!
                    stack.insert((lineNumber: -1, name: "con", substring: realValue!.description, index: LexTable.getCode("con")), atIndex: 0)
                    
                    break
                case "@":
                    guard let realValue : Float? = (((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value) where realValue != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    stack.insert((lineNumber: -1, name: "con", substring: (-realValue!).description, index: LexTable.getCode("con")), atIndex: 0)
                    
                    break
                case ":=":
                    guard let realValue : Float? = (((stack.first?.name)! == "con") ? (stack.first!.substring as NSString).floatValue : IDNs[stack.first!.substring]!.value) where realValue != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    stack.removeFirst()
                    
                    IDNs[stack.removeFirst().substring]!.value = realValue!
                    
                    break
                case "read":
                    IDNs[stack.first!.substring]!.value = inputReal(stack.removeFirst().substring)
                    
                    break
                case "write":
                    guard let floatValue : Float? = IDNs[stack.first!.substring]!.value where floatValue != nil else {
                        throw InterpreterError.NilException(variable: stack.first!.substring)
                    }
                    
                    output += "\n\(stack.first!.substring) = "
                    
                    stack.removeFirst()
                    
                    output += formatter.stringFromNumber(floatValue!)!
                    
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