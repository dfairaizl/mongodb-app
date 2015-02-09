//
//  ServerViewController.swift
//  MongoDB
//
//  Created by Dan Fairaizl on 12/29/14.
//  Copyright (c) 2014 TwentyBelow, LLC. All rights reserved.
//

import Cocoa

class ServerViewController: NSViewController {

    @IBOutlet weak var iconImageView: NSImageView!
    @IBOutlet weak var serverStatusLabel: NSTextField!
    @IBOutlet weak var serverStartButton: NSButton!
    @IBOutlet weak var serverStopButton: NSButton!
    @IBOutlet weak var serverStatusImageView: NSImageView!
    
    var colorFilter = CIFilter(name: "CIColorMonochrome")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
      
        self.colorFilter.setDefaults()
        self.colorFilter.setValue(1.0, forKey: "inputIntensity")
      
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
            context.duration = 3.0
//            self.iconImageView.contentFilters = [self.colorFilter]
        }, completionHandler: nil)
        
        NSNotificationCenter.defaultCenter().addObserverForName("ServerStartedSuccessfullyNotification", object: nil, queue: NSOperationQueue.mainQueue(), { (note: NSNotification!) -> Void in
            self.serverStatusLabel.stringValue = "Server Running"

            self.serverStatusImageView.image = NSImage(named: NSImageNameStatusAvailable)
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName("ServerStoppedSuccessfullyNotification", object: nil, queue: NSOperationQueue.mainQueue(), { (note: NSNotification!) -> Void in
            self.serverStatusLabel.stringValue = "Server is not running"
            
            self.serverStatusImageView.image = NSImage(named: NSImageNameStatusUnavailable)
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
