//
//  ViewController.swift
//  Translator
//
//  Created by Artem Tverdokhlebov on 4/27/16.
//  Copyright © 2016 Artem Tverdokhlebov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet var codeTextView : NSTextView!
    @IBOutlet var outputTextView : NSTextView!
    
    @IBOutlet weak var lexAnalyserTableView : NSTableView!
    
    @IBOutlet weak var idnsTableView : NSTableView!
    @IBOutlet weak var consTableView : NSTableView!
    
    @IBOutlet weak var syntaxAnalyserTableView : NSTableView!
    @IBOutlet weak var rpnGeneratorTableView : NSTableView!
    
    let interpreter : RPNInterpreter = RPNInterpreter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interpreter.setOutputTextView(outputTextView)
        
        self.lexAnalyserTableView.setDelegate(self)
        self.lexAnalyserTableView.setDataSource(self)
        
        self.idnsTableView.setDelegate(self)
        self.idnsTableView.setDataSource(self)
        
        self.consTableView.setDelegate(self)
        self.consTableView.setDataSource(self)
        
        self.syntaxAnalyserTableView.setDelegate(self)
        self.syntaxAnalyserTableView.setDataSource(self)
        
        self.rpnGeneratorTableView.setDelegate(self)
        self.rpnGeneratorTableView.setDataSource(self)
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func buttonClicked(sender: NSButton) {
        interpreter.setListing(codeTextView.string!)
        interpreter.start()
        
        lexAnalyserTableView.reloadData()
        
        idnsTableView.reloadData()
        consTableView.reloadData()
        
        syntaxAnalyserTableView.reloadData()
        rpnGeneratorTableView.reloadData()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if tableView == lexAnalyserTableView && interpreter.lexAnalyser != nil {
            return interpreter.lexAnalyser!.lexemes.count
        }
        
        if tableView == syntaxAnalyserTableView && interpreter.syntaxAnalyser != nil {
            return interpreter.syntaxAnalyser!.outputTable.count
        }
        
        if tableView == rpnGeneratorTableView && interpreter.rpnGenerator != nil {
            return interpreter.rpnGenerator!.outputTable.count
        }
        
        if tableView == idnsTableView && interpreter.lexAnalyser?.IDNs != nil {
            return interpreter.lexAnalyser!.IDNs.count
        }
        
        if tableView == consTableView && interpreter.lexAnalyser?.CONs != nil {
            return interpreter.lexAnalyser!.CONs.count
        }
        
        return 0
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellIdentifier : String = ""
        var text : String = ""
        
        if tableView == lexAnalyserTableView {
            let item = interpreter.lexAnalyser!.lexemes[row]
            
            text = ""
            
            if tableColumn == tableView.tableColumns[0] {
                text = String(item.lineNumber)
                cellIdentifier = "lineCell"
            } else if tableColumn == tableView.tableColumns[1] {
                text = item.substring
                cellIdentifier = "lexemeCell"
            } else if tableColumn == tableView.tableColumns[2] {
                text = String(item.index)
                cellIdentifier = "idCell"
            } else if tableColumn == tableView.tableColumns[3] {
                if item.index == LexTable.getCode("con") {
                    text = "con"
                } else if item.index == LexTable.getCode("idn") {
                    text = "idn"
                } else if item.index == LexTable.getCode("label") {
                    text = "label"
                }
                cellIdentifier = "typeCell"
            }
            
            if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
            
            return nil
        } else if tableView == lexAnalyserTableView {
            let item = interpreter.lexAnalyser!.lexemes[row]
            
            text = ""
            
            if tableColumn == tableView.tableColumns[0] {
                text = String(item.lineNumber)
                cellIdentifier = "lineCell"
            } else if tableColumn == tableView.tableColumns[1] {
                text = item.substring
                cellIdentifier = "lexemeCell"
            } else if tableColumn == tableView.tableColumns[2] {
                text = String(item.index)
                cellIdentifier = "idCell"
            }
            
            if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
            
            return nil
        } else if tableView == idnsTableView {
            let item = interpreter.lexAnalyser!.IDNs[row]
            
            text = ""
            
            if tableColumn == tableView.tableColumns[0] {
                text = String(item.index)
                cellIdentifier = "idCell"
            } else if tableColumn == tableView.tableColumns[1] {
                text = item.name
                cellIdentifier = "nameCell"
            }
            
            if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
            
            return nil
            
        } else if tableView == consTableView {
            let item = interpreter.lexAnalyser!.CONs[row]
            
            text = ""
            
            if tableColumn == tableView.tableColumns[0] {
                text = String(item.index)
                cellIdentifier = "idCell"
            } else if tableColumn == tableView.tableColumns[1] {
                text = item.name
                cellIdentifier = "nameCell"
            }
            
            if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
            
            return nil
        } else if tableView == rpnGeneratorTableView {
            let item = interpreter.rpnGenerator!.outputTable[row]
            
            text = ""
            
            if tableColumn == tableView.tableColumns[0] {
                text = item.lexeme
                cellIdentifier = "lexemeCell"
            } else if tableColumn == tableView.tableColumns[1] {
                text = item.stack
                cellIdentifier = "stackCell"
            } else if tableColumn == tableView.tableColumns[2] {
                text = item.RPNStack
                cellIdentifier = "rpnCell"
            }
            
            if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
            
            return nil
        }
        
        return nil
    }
}