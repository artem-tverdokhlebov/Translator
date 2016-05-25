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
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
}

extension NSAlert {
    func runModalSheetForWindow(aWindow: NSWindow) -> Int {
        self.beginSheetModalForWindow(aWindow) { returnCode in
            NSApp.stopModalWithCode(returnCode)
        }
        let modalCode = NSApp.runModalForWindow(self.window)
        return modalCode
    }
    
    func runModalSheet() -> Int {
        // Swift 1.2 gives the following error if only using one '!' below:
        // Value of optional type 'NSWindow?' not unwrapped; did you mean to use '!' or '?'?
        return runModalSheetForWindow(NSApp.mainWindow!)
    }
}

