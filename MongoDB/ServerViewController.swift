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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
      
        // Setup icon filter
        let image = self.iconImageView.image
        var colorFilter = CIFilter(name: "CIColorMonochrome")
      
        if let oringinalImage = image {
            colorFilter.setDefaults()
            colorFilter.name = "monochromeFilter"
            colorFilter.setValue(CIImage(data: oringinalImage.TIFFRepresentation), forKey: "inputImage")
            colorFilter.setValue(CIColor(red: 50, green: 50, blue: 50, alpha: 1.0), forKey: "inputColor")
            colorFilter.setValue(0.8, forKey: "inputIntensity")
         
            self.iconImageView.contentFilters = [colorFilter]
        }
      
        NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) -> Void in
            context.duration = 3.0
            self.iconImageView.setValue(0.0, forKey: "contentFilters.monochromeFilter.inputIntensity")
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
