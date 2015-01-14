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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        NSNotificationCenter.defaultCenter().addObserverForName("ServerStartedSuccessfullyNotification", object: nil, queue: NSOperationQueue.mainQueue(), { (note: NSNotification!) -> Void in
            self.serverStatusLabel.stringValue = "Server Running"
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName("ServerStoppedSuccessfullyNotification", object: nil, queue: NSOperationQueue.mainQueue(), { (note: NSNotification!) -> Void in
            self.serverStatusLabel.stringValue = "Server Stopped"
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
}
