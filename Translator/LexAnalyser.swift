//
//  LexAnalyser.swift
//  Translator
//
//  Created by Artem Tverdokhlebov on 4/27/16.
//  Copyright © 2016 Artem Tverdokhlebov. All rights reserved.
//

import Foundation

class LexAnalyser {
    var currentPosition = 0
    
    var indexInCON = 0
    var indexInIDN = 0
    var indexInLBL = 0
    
    var isBeginPassed = false
    
    internal var lexemes : [Lexeme] = [Lexeme]()
    internal var IDNs : [(index: Int, name: String)] = [(index: Int, name: String)]()
    internal var CONs : [(index: Int, name: String)] = [(index: Int, name: String)]()
    internal var LBLs : [(index: Int, name: String, type: String)] = [(index: Int, name: String, type: String)]()
    
    var errors : [String] = [String]()
    
    init(listing : String) {
        let lines = listing.characters.split{$0 == "\n"}.map(String.init)
        
        for var line in lines {
            line = removeAllSeparatorsInString(line)
        }
        
        var i = 1
        for line in lines {
            lexem(line, lineNumber: i)
            i += 1
        }
        
        
        for label in LBLs {
            if label.type == "U" {
                if !LBLs.contains({ $0.name == label.name && $0.type == "D" }) {
                    errors.append("Error with label '\(label.name)'")
                }
            }
        }
    }
    
    func cutString(parts: [String], position: Int) -> [String] {
        if(parts.count == position) {
            return [String]()
        }
        
        let cutted = parts[position..<parts.count]
        
        let characterArray = cutted.flatMap { String.CharacterView($0) }
        let string = String(characterArray).stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " "))
        
        return string.characters.map { String($0) }
    }
    
    func removeAllSeparatorsInString(input : String) -> String {
        var output = input
        
        if let regex = try? NSRegularExpression(pattern: "[\\s]", options: .CaseInsensitive) {
            output = regex.stringByReplacingMatchesInString(output, options: .WithTransparentBounds, range: NSMakeRange(0, output.characters.count), withTemplate: " ")
        }
        
        if let regex = try? NSRegularExpression(pattern: "[ ]+", options: .CaseInsensitive) {
            output = regex.stringByReplacingMatchesInString(output, options: .WithTransparentBounds, range: NSMakeRange(0, output.characters.count), withTemplate: " ")
        }
        
        return output.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " "))
    }
    
    func isLetter(char : String) -> Bool {
        let value = char.unicodeScalars.first?.value
        return (value >= 65 && value <= 90) || (value >= 97 && value <= 122)
    }
    
    func isNumber(char : String) -> Bool {
        let value = char.unicodeScalars.first?.value
        return (value >= 48 && value <= 57)
    }
    
    func isSignifier(char : String) -> Bool {
        return (char == "+" || char == "-")
    }
    
    func lexem(string : String, lineNumber : Int) {
        currentPosition = 0
        let parts = string.characters.map { String($0) }
        condition1(parts, lineNumber: lineNumber)
    }
    
    func addConstant(result : String, lineNumber : Int) {
        var currentIndexCON = 0
        if (LexTable.getCode(result) == -1) {
            if !CONs.contains({ $0.name == result }) {
                indexInCON += 1
                currentIndexCON = indexInCON
                CONs.append((index: currentIndexCON, name: result))
            }
            
            lexemes.append((lineNumber: lineNumber, name: LexTable.getString(LexTable.getCode("con"))!, substring: result, index: LexTable.getCode("con")))
        } else {
            indexInCON += 1
            lexemes.append((lineNumber: lineNumber, name: LexTable.getString(LexTable.getCode(result))!, substring: result, index: LexTable.getCode(result)))
        }
    }
    
}

extension LexAnalyser {
    func condition1( parts : [String], lineNumber : Int) {
        var parts = parts
        
        if parts.count == 0 {
            return
        }
        
        if isLetter(parts[0]) {
            currentPosition = 0
            condition2(parts, lineNumber: lineNumber)
            return
        }
        
        if isNumber(parts[0]) {
            currentPosition = 0
            condition3(parts, lineNumber: lineNumber)
            return
        }
        
        if parts[0] == "." {
            currentPosition = 0
            condition4(parts, lineNumber: lineNumber)
            return
        }
        
        if parts[0] == ";" {
            currentPosition += 1
            lexemes.append((lineNumber: lineNumber, name: LexTable.getString(LexTable.getCode(";"))!, substring: ";", index: LexTable.getCode(";")))
            return
        }
        
        if parts[0] == ":" {
            currentPosition = 0
            condition9(parts, lineNumber: lineNumber)
            return
        }
        
        if parts[0] == ">" {
            currentPosition = 0;
            condition10(parts, lineNumber: lineNumber)
            return
        }
        
        if parts[0] == "<" {
            currentPosition = 0;
            condition11(parts, lineNumber: lineNumber)
            return
        }
        
        if parts[0] == "!" {
            currentPosition = 0;
            condition12(parts, lineNumber: lineNumber)
            return
        }
        
        if LexTable.getCode(parts[0]) != -1 {
            lexemes.append((lineNumber: lineNumber, name: LexTable.getString(LexTable.getCode(parts[0]))!, substring: parts[0], index: LexTable.getCode(parts[0])))
            condition1(cutString(parts, position: 1), lineNumber: lineNumber)
            return
        }
        
        if parts[0] == " " {
            parts.removeAtIndex(0)
            condition1(parts, lineNumber: lineNumber)
            return
        }
        
        errors.append("Error in string #\(lineNumber) in \(parts[0])")
    }
    
    func condition2(parts : [String], lineNumber : Int) {
        var result = ""
        var currentIndexIDN = 0
        
        while (currentPosition <= parts.count - 1) && (isLetter(parts[currentPosition]) || isNumber(parts[currentPosition])) {
            result += parts[currentPosition]
            currentPosition += 1
        }
        
        if LexTable.getCode(result) < 0 {
            if (isBeginPassed) && !(IDNs.contains({ $0.name == result })) {
                errors.append("Error <undeclared identifier> in string #\(lineNumber) : \"\(result)\"")
                condition1(cutString(parts, position: currentPosition), lineNumber: lineNumber)
                return
            }
            
            if !isBeginPassed && IDNs.contains({ $0.name == result }) {
                errors.append("Error <identifier already declared> in string #\(lineNumber) : \"\(result)\"")
            }
            
            if !IDNs.contains({ $0.name == result }) {
                indexInIDN += 1
                currentIndexIDN = indexInIDN
                IDNs.append((index: currentIndexIDN, name: result))
            }
            
            lexemes.append((lineNumber: lineNumber, name: LexTable.getString(LexTable.getCode("idn"))!, substring: result, index: LexTable.getCode("idn")))
        } else {
            if (LexTable.getCode(result) == 3) {
                isBeginPassed = true
            }
            
            lexemes.append((lineNumber: lineNumber, name: LexTable.getString(LexTable.getCode(result))!, substring: result, index: LexTable.getCode(result)))
            
            if LexTable.getCode(result) == 12 {
                condition14(parts, lineNumber: lineNumber)
            }
        }
        
        condition1(cutString(parts, position: currentPosition), lineNumber: lineNumber)
        
        return
    }
    
    func condition3(parts : [String], lineNumber : Int) {
        var result = ""
        
        while (currentPosition <= parts.count - 1) && (isNumber(parts[currentPosition])) {
            result += parts[currentPosition]
            currentPosition += 1
        }
        
        if (parts.count - 1 >= currentPosition) {
            if (parts[currentPosition] == ".") {
                result += parts[currentPosition]
                currentPosition += 1
                condition5(result, parts: cutString(parts, position: currentPosition), lineNumber: lineNumber)
                return
            }
        }
        
        if (parts.count - 1 >= currentPosition) {
            if (parts[currentPosition] == "E") {
                result += parts[currentPosition]
                currentPosition += 1
                condition6(result, parts: cutString(parts, position: currentPosition), lineNumber: lineNumber)
                return;
            }
        }
        
        if (parts.count - 1 >= currentPosition) {
            if (parts[currentPosition] == ":") {
                currentPosition += 1
                condition13(result, parts: cutString(parts, position: currentPosition), lineNumber: lineNumber)
                return;
            }
        }
        
        addConstant(result, lineNumber: lineNumber)
        condition1(cutString(parts, position: currentPosition), lineNumber: lineNumber)
    }
    
    func condition4(parts : [String], lineNumber : Int) {
        var result = "."
        currentPosition += 1
        
        if parts.count - 1 >= currentPosition {
            if isNumber(parts[currentPosition]) {
                result += parts[currentPosition]
                currentPosition += 1
                condition5(result, parts: cutString(parts, position: currentPosition), lineNumber: lineNumber)
                return
            }
        }
        
        errors.append("Error in string #\(lineNumber) : \"\(result + parts[currentPosition])\"")
        condition1(cutString(parts, position: currentPosition), lineNumber: lineNumber)
    }
    
    func condition5(result : String, parts : [String], lineNumber : Int) {
        var _result = result
        
        currentPosition = 0
        
        while (currentPosition <= parts.count - 1) && (isNumber(parts[currentPosition])) {
            _result += parts[currentPosition];
            currentPosition += 1
        }
        
        if parts.count - 1 >= currentPosition {
            if parts[currentPosition] == "E" {
                _result += parts[currentPosition];
                currentPosition += 1
                condition6(_result, parts: cutString(parts, position: currentPosition), lineNumber: lineNumber)
                return
            }
        }
        
        addConstant(_result, lineNumber: lineNumber)
        condition1(cutString(parts, position: currentPosition), lineNumber: lineNumber)
    }
    
    func condition6(result : String, parts : [String], lineNumber : Int) {
        var _result = result
        
        currentPosition = 0
        
        if parts.count - 1 >= currentPosition {
            if isSignifier(parts[0]) {
                _result += parts[currentPosition]
                currentPosition += 1
                condition7(result, parts: cutString(parts, position: currentPosition), lineNumber: lineNumber)
                
                return
            }
        }
        
        if parts.count - 1 >= currentPosition {
            if isNumber(parts[0]) {
                _result += parts[currentPosition];
                currentPosition += 1
                condition8(result, parts: cutString(parts, position: currentPosition), lineNumber: lineNumber)
                return
            }
        }
        
        errors.append("Error in string #\(lineNumber) : \"\(_result + parts[currentPosition])\"")
        condition1(cutString(parts, position: currentPosition), lineNumber: lineNumber)
    }
    
    func condition7(result : String, parts : [String], lineNumber : Int) {
        var result = result
        
        currentPosition = 0
        
        if isNumber(parts[0]) {
            result += parts[currentPosition]
            currentPosition += 1
            condition8(result, parts: cutString(parts, position: currentPosition), lineNumber: lineNumber)
            return
        }
        
        errors.append("Error in string #\(lineNumber). Wrong constant value.");
        condition1(cutString(parts, position: currentPosition), lineNumber: lineNumber)
    }
    
    func condition8(result : String, parts : [String], lineNumber : Int) {
        var result = result
        
        currentPosition = 0
        
        while (currentPosition <= parts.count - 1) && (isNumber(parts[currentPosition])) {
            result += parts[currentPosition]
            currentPosition += 1
        }
        
        addConstant(result, lineNumber: lineNumber)
        condition1(cutString(parts, position: currentPosition), lineNumber: lineNumber)
    }
    
    func condition9(parts : [String], lineNumber : Int) {
        currentPosition = 0
        
        var result = ""
        
        if parts[0] == ":" {
            if parts[1] == "=" {
                result = ":="
                currentPosition += 2
            } else {
                result = ":"
                currentPosition += 1
            }
        }
        
        lexemes.append((lineNumber: lineNumber, name: LexTable.getString(LexTable.getCode(result))!, substring: result, index: LexTable.getCode(result)))
        condition1(cutString(parts, position: currentPosition), lineNumber: lineNumber)
    }
    
    func condition10(parts : [String], lineNumber : Int) {
        currentPosition = 0
        var result = ""
        
        if parts[1] == "=" {
            result = ">=";
            currentPosition += 2;
        } else {
            result = ">";
            currentPosition += 1;
        }
        
        lexemes.append((lineNumber: lineNumber, name: LexTable.getString(LexTable.getCode(result))!, substring: result, index: LexTable.getCode(result)))
        condition1(cutString(parts, position: currentPosition), lineNumber: lineNumber)
    }
    
    func condition11(parts : [String], lineNumber : Int) {
        currentPosition = 0
        var result = ""
        
        if parts[1] == "=" {
            result = "<=";
            currentPosition += 2;
        } else {
            result = "<"
            currentPosition += 1
        }
        
        lexemes.append((lineNumber: lineNumber, name: LexTable.getString(LexTable.getCode(result))!, substring: result, index: LexTable.getCode(result)))
        condition1(cutString(parts, position: currentPosition), lineNumber: lineNumber)
    }
    
    func condition13(result : String, parts : [String], lineNumber : Int) {
        currentPosition = 0
        
        if !LBLs.contains({ $0.name == result }) {
            indexInLBL += 1
        }
        
        LBLs.append((index: indexInLBL, name: result, type: "D"))
        
        lexemes.append((lineNumber: lineNumber, name: LexTable.getString(LexTable.getCode("label"))!, substring: result, index: LexTable.getCode("label")))
        lexemes.append((lineNumber: lineNumber, name: LexTable.getString(LexTable.getCode(":"))!, substring: ":", index: LexTable.getCode(":")))
        
        condition1(cutString(parts, position: currentPosition), lineNumber: lineNumber)
    }
    
    func condition14(parts : [String], lineNumber : Int) {
        var result = ""
        
        currentPosition += 1
        
        while (isNumber(parts[currentPosition])) {
            result += parts[currentPosition];
            currentPosition += 1
        }
        
        if !LBLs.contains({ $0.name == result }) {
            indexInLBL += 1
        }
        
        LBLs.append((index: indexInLBL, name: result, type: "U"))
        
        lexemes.append((lineNumber: lineNumber, name: LexTable.getString(LexTable.getCode("label"))!, substring: result, index: LexTable.getCode("label")))
        
        condition1(cutString(parts, position: currentPosition), lineNumber: lineNumber)
    }
    
    func condition12(parts : [String], lineNumber : Int) {
        currentPosition = 0
        var result = ""
        
        if parts[1] == "=" {
            result = "!=";
            currentPosition += 2;
        }
        
        lexemes.append((lineNumber: lineNumber, name: LexTable.getString(LexTable.getCode(result))!, substring: result, index: LexTable.getCode(result)))
        condition1(cutString(parts, position: currentPosition), lineNumber: lineNumber)
    }
}