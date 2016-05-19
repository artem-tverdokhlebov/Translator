//
//  RPNGenerator.swift
//  Translator
//
//  Created by Artem Tverdokhlebov on 5/14/16.
//  Copyright © 2016 Artem Tverdokhlebov. All rights reserved.
//

import Foundation

class RPNGenerator {
    var lexemes : [Lexeme]
    var m : [String] = [String]()
    var r : [String] = [(String)]()
    
    var lastLexeme : Lexeme?
    
    var priorityOperationsTable : [String : Int] = [
        "read": 0,
        "write": 0,
        "(": 0,
        "[": 0,
        "if": 0,
        "goto": 0,
        "do": 0,
        "by": 0,
        "to": 0,
        
        "{": 1,
        "}": 1,
        ";": 1,
        "]": 1,
        ")": 1,
        
        ":=": 2,
        "or": 3,
        "and": 4,
        "not": 5,
        
        "<": 6,
        ">": 6,
        "<=": 6,
        ">=": 6,
        "=": 6,
        "!=": 6,
        
        "+": 7,
        "-": 7,
        
        "*": 8,
        "/": 8,
        "@": 8
    ]
    
    internal var RPNstack : [Lexeme]
    var localStack : [Lexeme]
    
    var outputTable : [(lexeme: String, stack: String, RPNStack: String)] = [(lexeme: String, stack: String, RPNStack: String)]()
    
    let specialIndexes : [String : Int] = [
        "m" : -1,
        "m:" : -2,
        "r" : -3
    ]
    
    func isArithmeticOrBrackets(index: Int) -> Bool {
        let array : [String] = [
            "+",
            "-",
            "*",
            "/",
            "(",
            ")"
        ]
        
        return array.map { (substring) -> Int in
            return LexTable.getCode(substring)
            }.contains(index)
    }
    
    func isLogicOrBrackets(index: Int) -> Bool {
        let array : [String] = [
            "or",
            "and",
            "not",
            
            "[",
            "]",
            
            "=",
            "!=",
            
            "<",
            ">",
            "<=",
            ">=",
            ]
        
        return array.map { (substring) -> Int in
            return LexTable.getCode(substring)
            }.contains(index)
    }
    
    func isOperatorOrBrackets(index: Int) -> Bool {
        let array : [String] = [
            "read",
            "write",
            "do",
            "by",
            "to",
            "if",
            "goto",
            ":",
            ":=",
            ",",
            ";",
            "{",
            "}"
        ]
        
        return array.map { (substring) -> Int in
            return LexTable.getCode(substring)
            }.contains(index)
    }
    
    init(lexemes : [Lexeme]) {
        self.lexemes = lexemes
        
        self.RPNstack = [Lexeme]()
        self.localStack = [Lexeme]()
        
        start()
    }
    
    func start() {
        var RPN : Bool = false
        for lexeme : Lexeme in lexemes {
            if lexeme.name == "begin" {
                RPN = true
            }
            
            if RPN {
                createRPN(lexeme)
            }
            /*
             var stack : String = ""
             for item : Lexeme in localStack {
             stack += item.substring + " "
             }
             
             var RPNstackS : String = ""
             for item : Lexeme in RPNstack {
             RPNstackS += item.substring + " "
             }
             */
            outputTable.append((lexeme: lexeme.substring, stack: localStack.map({"\($0.substring)"}).joinWithSeparator(" "), RPNStack: RPNstack.map({"\($0.substring)"}).joinWithSeparator(" ")))
            
            //print(lexeme.substring + "\t\t|\t\t" + stack + "\t\t|\t\t" + RPNstackS + "\n")
        }
    }
    
    func createRPN(lexeme : Lexeme) {
        if lexeme.name == "idn" || lexeme.name == "con" || lexeme.name == "label" {
            RPNstack.append(lexeme)
            lastLexeme = lexeme
        } else if isArithmeticOrBrackets(lexeme.index) {
            arithmeticExpression(lexeme)
            lastLexeme = lexeme
        } else if isLogicOrBrackets(lexeme.index) {
            logicalExpression(lexeme)
            lastLexeme = lexeme
        } else if isOperatorOrBrackets(lexeme.index) {
            operators(lexeme)
            lastLexeme = lexeme
        }
    }
    
    func arithmeticExpression(lexeme : Lexeme) {
        if lexeme.name == ")" {
            while(!localStack.isEmpty && localStack.last?.name != "(") {
                RPNstack.append(localStack.removeLast())
            }
            
            if !localStack.isEmpty {
                localStack.removeLast()
            }
            
            if !localStack.isEmpty && localStack.last?.substring == "read" {
                localStack.removeLast()
                RPNstack.append((lineNumber: -1, name: "read", substring: "read", index: LexTable.getCode("read")))
            } else if !localStack.isEmpty && localStack.last?.substring == "write" {
                localStack.removeLast()
                RPNstack.append((lineNumber: -1, name: "write", substring: "write", index: LexTable.getCode("write")))
            }
        } else {
            while !localStack.isEmpty &&
                (priorityOperationsTable[(localStack.last?.name)!] != nil) &&
                priorityOperationsTable[(localStack.last?.name)!]! >= priorityOperationsTable[lexeme.name]! &&
                lexeme.name != "(" {
                    RPNstack.append(localStack.removeLast())
            }
            
            if lexeme.name == "-" && lastLexeme != nil && LexTable.isReserved(lastLexeme!) {
                localStack.append((lineNumber: lexeme.lineNumber, name: "@", substring: "@", index: -1))
            } else {
                localStack.append(lexeme)
            }
        }
    }
    
    func logicalExpression(lexeme : (lineNumber: Int, name: String, substring: String, index: Int)) {
        if lexeme.name == "]" {
            while !localStack.isEmpty && localStack.last!.name != "[" {
                RPNstack.append(localStack.removeLast())
            }
            
            if !localStack.isEmpty {
                localStack.removeLast()
            }
        } else {
            while !localStack.isEmpty &&
                (priorityOperationsTable[(localStack.last?.name)!] != nil) &&
                priorityOperationsTable[(localStack.last?.name)!]! >= priorityOperationsTable[lexeme.name]! &&
                lexeme.name != "[" {
                    RPNstack.append(localStack.removeLast())
            }
            
            localStack.append(lexeme)
        }
    }
    
    var isCycle = false
    var cycleParameter = ""
    
    func operators(lexeme : Lexeme) {
        switch lexeme.name {
            
        case "do":
            isCycle = true
            
            localStack.append(lexeme)
            
            m.append("m" + String(m.count + 1))
            m.append("m" + String(m.count + 1))
            m.append("m" + String(m.count + 1))
            
            break
            
        case "by":
            while !localStack.isEmpty && (priorityOperationsTable[(localStack.last?.name)!] != nil) &&
                priorityOperationsTable[(localStack.last?.name)!]! >= priorityOperationsTable[lexeme.name]! && localStack.last?.name != "do" {
                    RPNstack.append(localStack.removeLast())
            }
            
            r.append("r" + String(r.count + 1))
            RPNstack.append((lineNumber: -1, name: r.last!, substring: r.last!, index: specialIndexes["r"]!))
            
            RPNstack.append((lineNumber: -1, name: "1", substring: "1", index: LexTable.getCode("con")))
            RPNstack.append((lineNumber: -1, name: ":=", substring: ":=", index: LexTable.getCode(":=")))
            
            RPNstack.append((lineNumber: -1, name: m[m.count - 3] + ":", substring: m[m.count - 3] + ":", index: specialIndexes["m:"]!))
            
            r.append("r" + String(r.count + 1))
            RPNstack.append((lineNumber: -1, name: r.last!, substring: r.last!, index: specialIndexes["r"]!))
            
            break
            
        case "to":
            while !localStack.isEmpty && (priorityOperationsTable[(localStack.last?.name)!] != nil) &&
                priorityOperationsTable[(localStack.last?.name)!]! >= priorityOperationsTable[lexeme.name]! && localStack.last?.name != "do" {
                    RPNstack.append(localStack.removeLast())
            }
            
            RPNstack.append((lineNumber: -1, name: ":=", substring: ":=", index: LexTable.getCode(":=")))
            RPNstack.append((lineNumber: -1, name: r[r.count - 2], substring: r[r.count - 2], index: specialIndexes["r"]!))
            RPNstack.append((lineNumber: -1, name: "0", substring: "0", index: LexTable.getCode("con")))
            RPNstack.append((lineNumber: -1, name: ":=", substring: ":=", index: LexTable.getCode(":=")))
            RPNstack.append((lineNumber: -1, name: m[m.count - 2], substring: m[m.count - 2], index: specialIndexes["m"]!))
            RPNstack.append((lineNumber: -1, name: "УПЛ", substring: "УПЛ", index: 0))
            RPNstack.append((lineNumber: -1, name: cycleParameter, substring: cycleParameter, index: 0))
            RPNstack.append((lineNumber: -1, name: cycleParameter, substring: cycleParameter, index: 0))
            RPNstack.append((lineNumber: -1, name: r[r.count - 1], substring: r[r.count - 1], index: specialIndexes["r"]!))
            RPNstack.append((lineNumber: -1, name: "+", substring: "+", index: LexTable.getCode("+")))
            RPNstack.append((lineNumber: -1, name: ":=", substring: ":=", index: LexTable.getCode(":=")))
            
            RPNstack.append((lineNumber: -1, name: m[m.count - 2] + ":", substring: m[m.count - 2] + ":", index: specialIndexes["m:"]!))
            
            RPNstack.append((lineNumber: -1, name: r[r.count - 2], substring: r[r.count - 2], index: specialIndexes["r"]!))
            RPNstack.append((lineNumber: -1, name: "0", substring: "0", index: LexTable.getCode("con")))
            RPNstack.append((lineNumber: -1, name: ":=", substring: ":=", index: LexTable.getCode(":=")))
            RPNstack.append((lineNumber: -1, name: cycleParameter, substring: cycleParameter, index: 0))
            break
            
        case "{":
            while !localStack.isEmpty && (priorityOperationsTable[(localStack.last?.name)!] != nil) &&
                priorityOperationsTable[(localStack.last?.name)!]! >= priorityOperationsTable[lexeme.name]! && localStack.last?.name != "do" {
                    RPNstack.append(localStack.removeLast())
            }
            
            RPNstack.append((lineNumber: -1, name: "-", substring: "-", index: LexTable.getCode("-")))
            RPNstack.append((lineNumber: -1, name: r[r.count - 1], substring: r[r.count - 1], index: specialIndexes["r"]!))
            RPNstack.append((lineNumber: -1, name: "*", substring: "*", index: LexTable.getCode("*")))
            RPNstack.append((lineNumber: -1, name: "0", substring: "0", index: LexTable.getCode("con")))
            RPNstack.append((lineNumber: -1, name: "<=", substring: "<=", index: LexTable.getCode("<=")))
            RPNstack.append((lineNumber: -1, name: m[m.count - 1], substring: m[m.count - 1], index: specialIndexes["m"]!))
            RPNstack.append((lineNumber: -1, name: "УПЛ", substring: "УПЛ", index: 0))
            
            // remove cycle r
            if r.count >= 2 {
                r.removeLast(2)
            }
            
            break
            
        case "}":
            //if in cycle
            
            while !localStack.isEmpty && (priorityOperationsTable[(localStack.last?.name)!] != nil) &&
                priorityOperationsTable[(localStack.last?.name)!]! >= priorityOperationsTable[lexeme.name]! && localStack.last?.name != "do" {
                    RPNstack.append(localStack.removeLast())
            }
            
            if localStack.last?.name == "do" {
                localStack.removeLast()
            }
            
            RPNstack.append((lineNumber: -1, name: m[m.count - 3], substring: m[m.count - 3], index: specialIndexes["m"]!))
            RPNstack.append((lineNumber: -1, name: "БП", substring: "БП", index: 0))
            RPNstack.append((lineNumber: -1, name: m[m.count - 1] + ":", substring: m[m.count - 1] + ":", index: specialIndexes["m:"]!))
            
            // remove cycle labels
            if m.count >= 3 {
                m.removeLast(3)
            }
            
            break
            
        case "if":
            localStack.append(lexeme)
            localStack.append((lineNumber: -1, name: "not", substring: "not", index: LexTable.getCode("not")))
            
            break
            
        case "goto":
            while !localStack.isEmpty && (priorityOperationsTable[(localStack.last?.name)!] != nil) &&
                priorityOperationsTable[(localStack.last?.name)!]! >= priorityOperationsTable[lexeme.name]! && localStack.last?.name != "if" {
                    RPNstack.append(localStack.removeLast())
            }
            
            if localStack.last?.name == "if" {
                localStack.removeLast()
            }
            
            localStack.append((lineNumber: -1, name: "goto", substring: "goto", index: LexTable.getCode("goto")))
            
            break
            
        case ":":
            if lastLexeme!.name == "label" {
                var label = RPNstack.removeLast()
                label.name += ":"
                label.substring += ":"
                
                RPNstack.append(label)
            }
            
            break
            
        case ":=":
            localStack.append(lexeme)
            
            if isCycle {
                cycleParameter = (RPNstack.last?.substring)!
                
                isCycle = false
            }
            
            break
            
        case "read":
            localStack.append(lexeme)
            break
            
        case "write":
            localStack.append(lexeme)
            break
            
        case ";":
            while !localStack.isEmpty && (priorityOperationsTable[(localStack.last?.name)!] != nil) &&
                priorityOperationsTable[(localStack.last?.name)!]! >= priorityOperationsTable[lexeme.name]! && localStack.last?.name != "goto" && localStack.last?.name != "do"  {
                    RPNstack.append(localStack.removeLast())
            }
            
            if localStack.last?.name == "goto" {
                RPNstack.append((lineNumber: -1, name: "УПЛ", substring: "УПЛ", index: 0))
                localStack.removeLast()
            }
            
            if localStack.last?.name == "do" {
                localStack.removeLast()
            }
            
            break
            
        default: break
        }
    }
}