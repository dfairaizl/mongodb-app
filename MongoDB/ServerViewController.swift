//
//  ServerViewController.swift
//  MongoDB
//
//  Created by Dan Fairaizl on 12/29/14.
//  Copyright (c) 2014 TwentyBelow, LLC. All rights reserved.
//

import Cocoa

class ServerViewController: NSViewController {

    @IBOutlet weak var serverStatusLabel: NSTextField!
    @IBOutlet weak var serverStartButton: NSButton!
    @IBOutlet weak var serverStopButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        NSNotificationCenter.defaultCenter().addObserverForName("ServerStartedSuccessfullyNotification", object: nil, queue: NSOperationQueue.mainQueue(), { (note: NSNotification!) -> Void in
            self.serverStatusLabel.stringValue = "Server Running"
            self.serverStartButton.enabled = false
            self.serverStopButton.enabled = true
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName("ServerStoppedSuccessfullyNotification", object: nil, queue: NSOperationQueue.mainQueue(), { (note: NSNotification!) -> Void in
            self.serverStatusLabel.stringValue = "Server is not running"
            self.serverStartButton.enabled = true
            self.serverStopButton.enabled = false
        })
    }
    
    @IBAction func startServer(sender: AnyObject) {
        
        if(!MongoDB.sharedServer.isRunning()) {
            MongoDB.sharedServer.startServer()
        }
    }
    
    @IBAction func stopServer(sender: AnyObject) {
        MongoDB.sharedServer.stopServer()
    }
    
    @IBAction func launchHelp(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://docs.mongodb.org/manual/")!)
    }
}
