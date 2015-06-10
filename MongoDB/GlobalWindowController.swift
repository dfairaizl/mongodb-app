//
//  ServerWindowController.swift
//  MongoDB
//
//  Created by Daniel Fairaizl on 6/9/15.
//  Copyright (c) 2015 TwentyBelow, LLC. All rights reserved.
//

import Cocoa

class GlobalWindowController: NSWindowController {
    
    override func windowDidLoad() {
        
        self.window?.titleVisibility = .Hidden
        self.window?.titlebarAppearsTransparent = true
        self.window?.styleMask |= NSFullSizeContentViewWindowMask
    }
   
}
