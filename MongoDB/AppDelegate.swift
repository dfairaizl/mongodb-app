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
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var uiStartServerMenuItem: NSMenuItem!
    @IBOutlet weak var uiRestartServerMenuItem: NSMenuItem!
    
    let systemMenu: NSStatusBar = NSStatusBar.systemStatusBar()
    var statusItem: NSStatusItem!
    
    // MARK: NSApplicationDelegate Methods

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        self.setupStatusItemMenu()
        MongoDB.sharedServer.startServer()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        MongoDB.sharedServer.stopServer()
    }
    
    // MARK: UI Methods
    
    @IBAction func startServer(sender: AnyObject) {

        if(!MongoDB.sharedServer.isRunning()) {
            MongoDB.sharedServer.startServer()
        }
    }
    
    @IBAction func restartServer(sender: AnyObject) {
        MongoDB.sharedServer.stopServer()
    }
    
    @IBAction func openShell(sender: AnyObject) {

    }
    
    @IBAction func openPreferences(sender: AnyObject) {

    }
    
    @IBAction func copyConnectionString(sender: AnyObject) {
        NSLog("mongodb://localhost:27017")
    }
    
    // MARK: Private Helper Methods
    
    private
    
    func setupStatusItemMenu() {

        let statusItemImage = NSImage(named: "Menu-Status-Icon")
        statusItemImage?.setTemplate(true)
        
        self.statusItem = systemMenu.statusItemWithLength(-1)
        
        self.statusItem.button?.image = statusItemImage
        
        self.statusItem.menu = self.statusMenu
        
        NSNotificationCenter.defaultCenter().addObserverForName("ServerStartedSuccessfullyNotification", object: nil, queue: NSOperationQueue.mainQueue(), { (note: NSNotification!) -> Void in
            self.uiStartServerMenuItem.enabled = false
            self.uiRestartServerMenuItem.enabled = true
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName("ServerStoppedSuccessfullyNotification", object: nil, queue: NSOperationQueue.mainQueue(), { (note: NSNotification!) -> Void in
            self.uiStartServerMenuItem.enabled = true
            self.uiRestartServerMenuItem.enabled = false
        })
        
        self.uiStartServerMenuItem.enabled = true
        self.uiRestartServerMenuItem.enabled = false
    }
}

