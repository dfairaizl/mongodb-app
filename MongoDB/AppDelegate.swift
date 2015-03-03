//
//  AppDelegate.swift
//  MongoDB
//
//  Created by Dan Fairaizl on 12/29/14.
//  Copyright (c) 2014 TwentyBelow, LLC. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate, DownloadDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var uiStartServerMenuItem: NSMenuItem!
    @IBOutlet weak var uiRestartServerMenuItem: NSMenuItem!
    
    let systemMenu: NSStatusBar = NSStatusBar.systemStatusBar()
    var statusItem: NSStatusItem!
    var pasteBoard = NSPasteboard.generalPasteboard()
    
    var appUpdateInfo: [NSObject: AnyObject]?
    var windowController: NSWindowController?
    
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
        
        MDBTerminalScript.sharedInstance().runCommand("mongo")
    }
    
    @IBAction func openPreferences(sender: AnyObject) {

    }
    
    @IBAction func copyConnectionString(sender: AnyObject) {
        self.pasteBoard.declareTypes([NSPasteboardTypeString], owner: nil)
        self.pasteBoard.setString("mongodb://localhost:17017", forType: NSPasteboardTypeString)
    }
    
    // MARK: NSUserNotificationCenterDelegate Methods
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        
        if notification.activationType == NSUserNotificationActivationType.ActionButtonClicked {
            if let info = notification.userInfo {
                self.updateApp(info)
            }
        }
        else if notification.activationType == NSUserNotificationActivationType.ContentsClicked {
            NSLog("Do you want to update now?")
        }
    }
    
    // MARK: DownloadDelegate Methods
    func urlForDownload() -> NSURL {
        let url = "https://github.com/PostgresApp/PostgresApp/releases/download/9.4.1.0/Postgres-9.4.1.0.zip" //self.appUpdateInfo?["downloadURL"] as String
        return NSURL(string: url)!
    }
    
    func messageForDownload() -> String {
        return "Downloading update, please wait..."
    }
    
    func downloadDidFinishSuccessfully(downloadedFile: NSURL) {
        NSApp.stopModal()
        self.windowController?.close()
    }
    
    func downloadWasCancelled() {
        self.windowController?.close()
    }
    
    func downloadDidFailWithError(error: NSError?) {
        self.windowController?.close()
    }
    
    // MARK: Private Helper Methods
    
    private
    
    func updateApp(info: [NSObject: AnyObject]) {
        
        self.appUpdateInfo = info
        
        self.windowController = NSStoryboard(name: "Main", bundle: nil)?.instantiateControllerWithIdentifier("MongoProgressWindow") as? NSWindowController
        let downloadViewController = windowController!.contentViewController! as DownloadViewController
        
        downloadViewController.downloadDelegate = self
        
        windowController?.showWindow(self)
    }
    
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

