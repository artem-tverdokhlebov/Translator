//
//  RelationTable.swift
//  Lab2
//
//  Created by Artem Tverdokhlebov on 5/25/16.
//  Copyright © 2016 Artem Tverdokhlebov. All rights reserved.
//

import Foundation

class Grammar {
    var rules : [String : [[String]]] = [String : [[String]]]()
    var keys : [String] = [String]()
    var allItems : [String] = [String]()
    
    func addRule(title : String, sequence : [[String]]) {
        rules[title] = sequence
    }
    
    func updateKeys() {
        for item in Array(rules.keys) {
            keys.append(item)
        }
    }
    
    func updateAllItems() {
        for key in Array(rules.keys) {
            var list : [[String]]
            
            if !allItems.contains(key) {
                allItems.append(key)
            }
            if rules[key] != nil {
                list = rules[key]!
                
                for lst in list {
                    for item in lst {
                        if !allItems.contains(item) && item != "|" {
                            allItems.append(item)
                        }
                    }
                }
            }
        }
    }
    
    func getSequence(key : String) -> [[String]]? {
        return rules[key]
    }
    
    func getKeys() -> [String] {
        return keys
    }
    
    func getAllItems() -> [String] {
        return allItems
    }
    
    func first(value : String, inout result : [String]) {
        //var result = result
        var list : [[String]]
        
        if rules[value] != nil {
            list = rules[value]!
            
            for item in list {
                if !result.contains(item[0]) {
                    result.append(item[0])
                    first(item[0], result: &result)
                }
            }
        }
    }
    
    func last(value : String, inout result : [String]) {
        if rules[value] != nil {
            let list : [[String]] = rules[value]!
            
            for item in list {
                if !result.contains(item.last!)
                {
                    result.append(item.last!)
                    last(item.last!, result: &result)
                }
            }
        }
    }
    
}

struct RelationKey: Hashable {
    let one: String
    let two: String
    
    var hashValue: Int {
        return one.hashValue ^ two.hashValue
    }
    
    init(_ one: String, _ two: String) {
        self.one = one
        self.two = two
    }
}

func == (lhs: RelationKey, rhs: RelationKey) -> Bool {
    return lhs.one == rhs.one && lhs.two == rhs.two
}

class RelationTable {
    var table : [RelationKey : String] = [RelationKey : String]()
    
    func makeEq() {
        for key in grammar.getKeys() {
            var isFirst = true
            let list : [[String]] = grammar.getSequence(key)!
            
            for lst in list {
                var prevItem = ""
                
                for item in lst {
                    if isFirst {
                        isFirst = false
                    } else {
                        if table[RelationKey(item, prevItem)] == nil || table[RelationKey(item, prevItem)] == "=" {
                            table[RelationKey(prevItem, item)] = "="
                        } else {
                            print("Equal \(prevItem) \(item)")
                        }
                    }
                    
                    prevItem = item
                }
            }
        }
    }
    
    func makeLess() {
        for V in grammar.getAllItems() {
            var list : [String] = [String]()
            
            grammar.first(V, result: &list)
            
            for S in list {
                for R in grammar.getAllItems() {
                    if S != "|" && R != "|" && V != "|" && table[RelationKey(R, V)] == "=" {
                        if table[RelationKey(R, S)] == nil || table[RelationKey(R, S)] == "<" {
                            table[RelationKey(R, S)] = "<";
                        } else {
                            print("Less \(R) \(S)")
                        }
                    }
                }
            }
        }
    }
    
    func makeGreater() {
        for V in grammar.getAllItems() {
            for W in grammar.getAllItems() {
                if table[RelationKey(V, W)] == "=" {
                    var last : [String] = [String]()
                    var first : [String] = [String]()
                    grammar.last(V, result: &last)
                    grammar.first(W, result: &first)
                    
                    first.append(W)
                    
                    for S in first {
                        for R in last {
                            if table[RelationKey(R, S)] == nil || table[RelationKey(R, S)] == ">" {
                                table[RelationKey(R, S)] = ">"
                            } else {
                                print("Greater \(R) \(S)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    var grammar : Grammar = Grammar()
    
    init() {
        grammar.addRule("program", sequence: [["program", "idn", "var", "listId1", ":", "real", ";", "begin", "listOp1", "end"]])
        grammar.addRule("listId1", sequence: [["listId"]])
        grammar.addRule("listId", sequence: [[",", "idn" ], ["listId", ",", "idn"]])
        
        grammar.addRule("listOp1", sequence: [ [ "listOp" ] ])
        grammar.addRule("listOp", sequence: [[ "operator", ";" ], [ "listOp", "operator", ";" ]])
        
        grammar.addRule("operator", sequence: [ [ "label", ":", "unmarkOp" ], ["unmarkOp" ]])
        
        grammar.addRule("unmarkOp", sequence: [ [ "idn", ":=", "expr1" ], [ "read", "(", "idn", ")" ], [ "write", "(", "idn", ")" ], [ "do", "idn", ":=", "expr1", "by", "expr1", "to", "expr1", ";", "unmarkOp1" ], [ "if", "log.expr1", "goto", "label" ] ])
        grammar.addRule("unmarkOp1", sequence: [[ "unmarkOp" ]])
        
        grammar.addRule("expr1", sequence: [[ "expr" ]])
        grammar.addRule("expr", sequence: [[ "term1" ], [ "expr", "+", "term1" ], [ "expr", "-", "term1" ], [ "-", "term1" ]])
        
        grammar.addRule("term1", sequence: [ [ "term" ] ])
        grammar.addRule("term", sequence: [[ "mult1" ], [ "term", "*", "mult1" ], [ "term", "/", "mult1" ] ])
        
        grammar.addRule("mult1", sequence:[ [ "mult" ] ])
        grammar.addRule("mult", sequence:[ [ "idn" ], [ "con" ], [ "(", "expr1", ")" ] ])
        
        grammar.addRule("log.expr1", sequence:[ [ "log.expr" ] ])
        grammar.addRule("log.expr", sequence:[ [ "log.expr", "or", "log.term1" ], [ "log.term1" ] ])
        
        grammar.addRule("log.term1", sequence:[ [ "log.term" ] ])
        grammar.addRule("log.term", sequence:[ [ "log.term", "and", "log.mult1" ], [ "log.mult1" ] ])
        
        grammar.addRule("log.mult1", sequence:[ [ "log.mult" ] ])
        grammar.addRule("log.mult", sequence:[ [ "expr1", "ratio", "expr1" ], [ "[", "log.expr1", "]" ], [ "not", "log.mult" ] ])
        
        grammar.addRule("ratio", sequence:[ [ "=" ], [ "!=" ], [ ">" ], [ "<" ], [ ">=" ], [ "<=" ] ])
        
        grammar.updateKeys()
        grammar.updateAllItems()
        
        makeEq()
        makeLess()
        makeGreater()
        
        print("done")
    }
}