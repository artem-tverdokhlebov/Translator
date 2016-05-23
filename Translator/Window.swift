//
//  Window.swift
//  Translator
//
//  Created by Artem Tverdokhlebov on 5/24/16.
//  Copyright © 2016 Artem Tverdokhlebov. All rights reserved.
//

import Cocoa

class BluredWindow: NSWindow {
    
    override func awakeFromNib() {        
        //self.styleMask = self.styleMask | NSFullSizeContentViewWindowMask
        self.titlebarAppearsTransparent = true
    }
}