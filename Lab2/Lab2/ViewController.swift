//
//  ViewController.swift
//  Lab2
//
//  Created by Artem Tverdokhlebov on 5/25/16.
//  Copyright © 2016 Artem Tverdokhlebov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    var rpn : RPN? = nil
    
    @IBOutlet weak var resultLabel: NSTextField!
    @IBOutlet weak var listingTextField: NSTextField!
    @IBOutlet weak var rpnTableView: NSTableView!
    @IBOutlet weak var relationTableView: NSTableView!
    
    @IBAction func stackClicked(sender: NSButton) {
        rpn = RPN(listing: listingTextField.stringValue + ";")
        
        resultLabel.stringValue = String(rpn!.result!)
        
        rpnTableView.reloadData()
        
        for column in relationTableView.tableColumns {
            relationTableView.removeTableColumn(column)
        }
        
        let column = NSTableColumn(identifier: "")
        
        column.title = ""
        relationTableView.addTableColumn(column)
        
        for key in rpn!.relationTable.grammar.getAllItems() {
            let column = NSTableColumn(identifier: key)
            
            column.title = key
            relationTableView.addTableColumn(column)
        }
        
        relationTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rpnTableView.setDelegate(self)
        rpnTableView.setDataSource(self)
        
        relationTableView.setDelegate(self)
        relationTableView.setDataSource(self)
        
        // Do any additional setup after loading the view.
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if tableView == rpnTableView {
            if rpn != nil {
                return rpn!.outputTable.count
            }
        } else if tableView == relationTableView {
            if rpn != nil {
                return rpn!.relationTable.grammar.getAllItems().count
            }
        }
        
        return 0
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        if tableView == rpnTableView {
            if rpn != nil {
                if tableColumn == tableView.tableColumns[0] {
                    return rpn!.outputTable[row].0
                } else if tableColumn == tableView.tableColumns[1] {
                    return rpn!.outputTable[row].1
                } else if tableColumn == tableView.tableColumns[2] {
                    return rpn!.outputTable[row].2
                } else if tableColumn == tableView.tableColumns[3] {
                    return rpn!.outputTable[row].3
                }
            }
        } else if tableView == relationTableView {
            if tableColumn == tableView.tableColumns[0] {
                return rpn!.relationTable.grammar.getAllItems()[row]
            } else {
                return rpn!.relationTable.table[RelationKey(rpn!.relationTable.grammar.getAllItems()[row], tableColumn!.identifier)]
            }
        }
        
        return ""
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

