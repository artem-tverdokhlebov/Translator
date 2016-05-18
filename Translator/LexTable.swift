//
//  LexTable.swift
//  Translator
//
//  Created by Artem Tverdokhlebov on 4/27/16.
//  Copyright © 2016 Artem Tverdokhlebov. All rights reserved.
//

import Foundation

typealias Lexeme = (lineNumber: Int, name: String, substring: String, index: Int)

class LexTable {
    static internal let table : [String : Int] = [
        "program" : 1,
        "var" : 2,
        "begin" : 3,
        "end" : 4,
        "real" : 5,
        "read" : 6,
        "write" : 7,
        "do" : 8,
        "by" : 9,
        "to" : 10,
        "if" : 11,
        "goto" : 12,
        ":" : 13,
        ";" : 14,
        ":=" : 15,
        "," : 16,
        "=" : 17,
        "+" : 18,
        "-" : 19,
        "*" : 20,
        "/" : 21,
        "(" : 22,
        ")" : 23,
        "<" : 24,
        "<=" : 25,
        ">" : 26,
        ">=" : 27,
        "!=" : 28,
        "idn" : 29,
        "con" : 30,
        "not" : 31,
        "and" : 32,
        "or" : 33,
        "[" : 34,
        "]" : 35,
        "{" : 36,
        "}" : 37,
        "label" : 38
    ]
    
    static func getCode(s : String) -> Int {
        if (table[s] != nil) {
            return table[s]!
        } else {
            return -1
        }
    }
    
    static func getString(index: Int) -> String? {
        for item in table {
            if item.1 == index {
                return item.0
            }
        }
        
        return nil
    }
    
    static func isCON(lexeme : Lexeme) -> Bool {
        let array : [String] = [
            "con"
        ]
        
        return array.contains(lexeme.name)
    }
    
    static func isIDN(lexeme : Lexeme) -> Bool {
        let array : [String] = [
            "idn"
        ]
        
        return array.contains(lexeme.name)
    }
    
    
    static func isReserved(lexeme : Lexeme) -> Bool {
        return !isCON(lexeme) && !isIDN(lexeme)
    }
}