//
//  SyntaxAnalyser.swift
//  Translator
//
//  Created by Artem Tverdokhlebov on 5/4/16.
//  Copyright © 2016 Artem Tverdokhlebov. All rights reserved.
//

import Foundation

let OUT = -1
let BACK = -2
let NO_NAME = "NO_NAME"

class SyntaxAnalyser {
    
    var lexemes : [(lineNumber: Int, substring: String, index: Int)]
    var stack = [Int]()
    
    var currentCondition = 1
    var index = 0
    
    internal var errors : [String] = [String]()
    
    let conditions : [(alpha: Int, beta: Int, sign: String, stack: Int?)] = [
        // Main
        (alpha: 1, beta: 2, sign: "program", stack: nil),
        (alpha: 2, beta: 3, sign: "idn", stack: nil),
        (alpha: 3, beta: 4, sign: "var", stack: nil),
        (alpha: 4, beta: 5, sign: "idn", stack: nil),
        (alpha: 5, beta: 4, sign: ",", stack: nil),
        (alpha: 5, beta: 6, sign: ":", stack: nil),
        (alpha: 6, beta: 7, sign: "real", stack: nil),
        (alpha: 7, beta: 8, sign: ";", stack: nil),
        (alpha: 8, beta: 101, sign: "begin", stack: 9),
        (alpha: 9, beta: OUT, sign: "end", stack: nil),
        (alpha: 9, beta: 101, sign: NO_NAME, stack: 9),
        
        // SubAutomat Operation
        (alpha: 101, beta: 102, sign: "idn", stack: nil),
        (alpha: 101, beta: 104, sign: "read", stack: nil),
        (alpha: 101, beta: 104, sign: "write", stack: nil),
        (alpha: 101, beta: 107, sign: "do", stack: nil),
        (alpha: 101, beta: 301, sign: "if", stack: 114),
        (alpha: 101, beta: 400, sign: "label", stack: nil),
        
        // Marked operator
        (alpha: 400, beta: 101, sign: ":", stack: nil),

        // Appropriation
        (alpha: 102, beta: 200, sign: ":=", stack: 103),
        (alpha: 103, beta: BACK, sign: ";", stack: nil),
        
        // Read/Write
        (alpha: 104, beta: 105, sign: "(", stack: nil),
        (alpha: 105, beta: 106, sign: "idn", stack: nil),
        (alpha: 106, beta: 107, sign: ")", stack: nil),
        (alpha: 107, beta: BACK, sign: ";", stack: nil),
        
        // Cycle
        (alpha: 107, beta: 108, sign: "idn", stack: nil),
        (alpha: 108, beta: 200, sign: ":=", stack: 109),
        (alpha: 109, beta: 200, sign: "by", stack: 110),
        (alpha: 110, beta: 200, sign: "to", stack: 111),
        (alpha: 111, beta: 101, sign: ";", stack: nil),
        (alpha: 112, beta: BACK, sign: ";", stack: nil),
        
        // If
        (alpha: 114, beta: 115, sign: "goto", stack: nil),
        (alpha: 115, beta: 116, sign: "label", stack: nil),
        (alpha: 116, beta: BACK, sign: ";", stack: nil),
        
        // SubAutomat Expression
        (alpha: 200, beta: 201, sign: "-", stack: nil),
        (alpha: 200, beta: 201, sign: NO_NAME, stack: nil),
        (alpha: 201, beta: 202, sign: "idn", stack: nil),
        (alpha: 201, beta: 202, sign: "con", stack: nil),
        (alpha: 201, beta: 200, sign: "(", stack: 203),
        (alpha: 202, beta: 200, sign: "+", stack: nil),
        (alpha: 202, beta: 200, sign: "-", stack: nil),
        (alpha: 202, beta: 200, sign: "*", stack: nil),
        (alpha: 202, beta: 200, sign: "/", stack: nil),
        (alpha: 202, beta: BACK, sign: NO_NAME, stack: nil),
        (alpha: 203, beta: 202, sign: ")", stack: nil),

        // SubAutomat Logical Expression
        (alpha: 301, beta: 301, sign: "[", stack: 304),
        (alpha: 301, beta: 301, sign: "not", stack: nil),
        (alpha: 301, beta: 200, sign: NO_NAME, stack: 302),
        
        (alpha: 302, beta: 200, sign: "=", stack: 303),
        (alpha: 302, beta: 200, sign: "<", stack: 303),
        (alpha: 302, beta: 200, sign: "<=", stack: 303),
        (alpha: 302, beta: 200, sign: ">", stack: 303),
        (alpha: 302, beta: 200, sign: ">=", stack: 303),
        (alpha: 302, beta: 200, sign: "<>", stack: 303),

        (alpha: 303, beta: 301, sign: "or", stack: nil),
        (alpha: 303, beta: 301, sign: "and", stack: nil),
        (alpha: 303, beta: BACK, sign: NO_NAME, stack: nil),
        (alpha: 304, beta: 303, sign: "]", stack: nil)
    ]
    
    init(lexemes : [(lineNumber: Int, substring: String, index: Int)]) {
        self.lexemes = lexemes
        
        mainCycle()
    }
 
    func mainCycle() {
        var conditions = [(alpha : Int, beta : Int, sign: String, stack: Int?)]()
        
        for condition in self.conditions {
            if condition.alpha == currentCondition {
                conditions.append(condition)
            }
        }
        
        if checkSign(conditions) {
            if currentCondition != OUT {
                mainCycle()
            }
        }
    }
 
    func checkSign(conditions : [(alpha : Int, beta : Int, sign: String, stack: Int?)]) -> Bool {
        var isFound = false
        
        for condition in conditions {
            if LexTable.getCode(condition.sign) == lexemes[index].index {
                isFound = true
                index += 1
                
                nextAction(condition)
                
                return true
            } else if !isFound && condition.sign == NO_NAME && (condition.beta == BACK || condition.sign == NO_NAME) {
                
                nextAction(condition)
                
                return true
            }
        }
        
        errors.append("Ошибка в строке: \(lexemes[index].lineNumber). \(lexemes[index].substring)")
        
        return false
    }
    
    func nextAction(condition : (alpha : Int, beta : Int, sign: String, stack: Int?)) {
        if condition.beta == BACK {
            currentCondition = stack.removeLast()
        } else {
            currentCondition = condition.beta
            if (condition.stack != nil) {
                stack.append(condition.stack!)
            }
        }
    }
}