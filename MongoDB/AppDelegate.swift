//
//  AppDelegate.swift
//  MongoDB
//
//  Created by Dan Fairaizl on 12/29/14.
//  Copyright (c) 2014 TwentyBelow, LLC. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var statusMenu: NSMenu!
    @IBOutlet weak var uiStartServerMenuItem: NSMenuItem!
    @IBOutlet weak var uiRestartServerMenuItem: NSMenuItem!
    
    let systemMenu: NSStatusBar = NSStatusBar.systemStatusBar()
    var statusItem: NSStatusItem!
    
    // MARK: NSApplicationDelegate Methods

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        self.setupStatusItemMenu()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    // MARK: UI Methods
    
    @IBAction func startServer(sender: AnyObject) {
        MongoDB.sharedServer.startServer()
    }
    
    @IBAction func restartServer(sender: AnyObject) {
        NSLog("restarting server...")
    }
    
    // MARK: Private Helper Methods
    
    private
    
    func setupStatusItemMenu() {

        let statusItemImage = NSImage(named: "Menu-Status-Icon")
        statusItemImage?.setTemplate(true)
        
        self.statusItem = systemMenu.statusItemWithLength(-1)
        
        self.statusItem.button?.image = statusItemImage
        
        self.statusItem.menu = self.statusMenu
        
        // Disable relevant menu items on startup
        self.uiRestartServerMenuItem.enabled = false
    }

}

