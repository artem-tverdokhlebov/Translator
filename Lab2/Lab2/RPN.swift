//
//  RPN.swift
//  Lab2
//
//  Created by Artem Tverdokhlebov on 5/26/16.
//  Copyright © 2016 Artem Tverdokhlebov. All rights reserved.
//

import Cocoa

class RPN {
    var relationTable : RelationTable = RelationTable()
    var lexAnalyser : LexAnalyser?
    
    var lexemes : [Lexeme] = [Lexeme]()
    
    var stack : [String] = [String]()
    var RPNstack : [Lexeme] = [Lexeme]()
    
    var polizRules : [String : [[String]]] = [String : [[String]]]()
    
    var result : Float? = nil
    
    var outputTable : [(String, String, String, String)] = [(String, String, String, String)]()
    
    init(listing : String) {
        lexAnalyser = LexAnalyser(listing: listing)
        lexemes = lexAnalyser!.lexemes
        
        outputTable = [(String, String, String, String)]()
        
        polizRules["/"] = [[ "term", "/", "mult1" ]]
        polizRules["*"] = [[ "term", "*", "mult1" ]]
        polizRules["@"] = [[ "-", "term1" ]]
        polizRules["-"] = [[ "expr", "-", "term1" ]]
        polizRules["+"] = [[ "expr", "+", "term1" ]]
        polizRules[""] = [["idn"], ["con"]]
        
        analyze()
        interpretate()
    }
    
    func push() {
        stack.append(lexemes[0].name)
        
        if LexTable.isCON(lexemes[0]) {
            RPNstack.append(lexemes[0])
        }
        
        lexemes.removeFirst()
        
        print("\(stack.joinWithSeparator(", "))\t|\tpush\t|\t\(lexemes.map { $0.name }.joinWithSeparator(", "))")
    }
    
    func getPolizRuleResult(key : [String]) -> String {
        for V in polizRules {
            for B in V.1 {
                if B == key {
                    return V.0
                }
            }
        }
        
        return ""
    }
    
    func GetKeyByValue(key : [String]) -> String {
        for rule in relationTable.grammar.rules {
            for E in rule.1 {
                if E == key {
                    return rule.0
                }
            }
        }
        
        return ""
    }
    
    func analyze() {
        push()
        
        while lexemes.count > 0 {
            switch relationTable.table[RelationKey(stack.last!, lexemes[0].name)]! {
            case "<":
                
                outputTable.append((stack.joinWithSeparator(" "), "<", lexemes.map { $0.name }.joinWithSeparator(" "), RPNstack.map { $0.substring }.joinWithSeparator(" ")))
                
                push()
                break
            case "=":
                
                outputTable.append((stack.joinWithSeparator(" "), "=", lexemes.map { $0.name }.joinWithSeparator(" "), RPNstack.map { $0.substring }.joinWithSeparator(" ")))
                push()
                break
            case ">":
                
                outputTable.append((stack.joinWithSeparator(" "), ">", lexemes.map { $0.name }.joinWithSeparator(" "), RPNstack.map { $0.substring }.joinWithSeparator(" ")))
                
                var grammarList : [String] = [String]()
                
                repeat {
                    grammarList.append(stack.removeLast())
                    
                    if (stack.count == 0 || relationTable.table[RelationKey(stack.last!, grammarList.last!)]! == "<") {
                        break
                    }
                } while (1 == 1)
                
                grammarList = grammarList.reverse()
                
                print(grammarList.joinWithSeparator(", "))
                
                let polizOperator : String = getPolizRuleResult(grammarList)
                if polizOperator != "" {
                    RPNstack.append((lineNumber: -1, name: polizOperator, substring: polizOperator, index: LexTable.getCode(polizOperator)))
                }
                
                let key = GetKeyByValue(grammarList)
                if key != "" {
                    stack.append(key)
                }
                
                break
            default:
                break
            }
        }
    }
    
    func interpretate() {
        var stack2 : [Float] = [Float]()
        
        for val in RPNstack {
            var el : Float?
            
            if LexTable.isCON(val) {
                el = Float(val.substring)
                stack2.append(el!)
            } else if val.name == "@" {
                let a = stack2.removeLast()
                stack2.append(-a)
            } else {
                let b = stack2.removeLast()
                let a = stack2.removeLast()
                
                switch (val.name)
                {
                case "/":
                    stack2.append(a / b);
                    break
                case "*":
                    stack2.append(a * b);
                    break
                case "+":
                    stack2.append(a + b);
                    break
                case "-":
                    stack2.append(a - b);
                    break
                default:
                    break
                }
            }
        }
        
        result = stack2.removeLast()
    }
}