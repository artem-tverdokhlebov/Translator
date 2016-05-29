//
//  AppDelegate.swift
//  Translator
//
//  Created by Artem Tverdokhlebov on 4/27/16.
//  Copyright © 2016 Artem Tverdokhlebov. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet weak var openMenuItem: NSMenuItem!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        
    }
}

extension NSOpenPanel {
    func runModalSheetForWindow(aWindow: NSWindow) -> Int {
        self.beginSheetModalForWindow(aWindow) { returnCode in
            NSApp.stopModalWithCode(returnCode)
        }
        let modalCode = NSApp.runModalForWindow(aWindow)
        return modalCode
    }
    
    func runModalSheet() -> Int {
        return runModalSheetForWindow(NSApp.mainWindow!)
    }
}

extension NSAlert {
    func runModalSheetForWindow(aWindow: NSWindow) -> Int {
        self.beginSheetModalForWindow(aWindow) { returnCode in
            NSApp.stopModalWithCode(returnCode)
        }
        let modalCode = NSApp.runModalForWindow(aWindow)
        return modalCode
    }
    
    func runModalSheet() -> Int {
        return runModalSheetForWindow(NSApp.mainWindow!)
    }
}

