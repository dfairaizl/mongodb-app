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
      
        self.iconImageView.wantsLayer = true
        self.iconImageView.layerUsesCoreImageFilters = true
      
        // Setup icon filter
        let image = self.iconImageView.image
        var colorFilter = CIFilter(name: "CIColorMonochrome")
      
        if let oringinalImage = image {
            colorFilter.setDefaults()
            colorFilter.name = "monochromeFilter"
            colorFilter.setValue(CIImage(data: oringinalImage.TIFFRepresentation), forKey: "inputImage")
            colorFilter.setValue(CIColor(red: 50, green: 50, blue: 50, alpha: 1.0), forKey: "inputColor")
            colorFilter.setValue(0.8, forKey: "inputIntensity")
         
            self.iconImageView.layer!.filters = [colorFilter]
        }
      
        self.registerServerNotifications()
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
   
   // MARK: Private
   
   func registerServerNotifications() {
      
      NSNotificationCenter.defaultCenter().addObserverForName("ServerStartedSuccessfullyNotification", object: nil, queue: NSOperationQueue.mainQueue(), { (note: NSNotification!) -> Void in
         
         self.serverStatusLabel.stringValue = "Connected to localhost"
         
         self.serverStatusImageView.image = NSImage(named: NSImageNameStatusAvailable)
         
         NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) in
            
            var animation = CABasicAnimation(keyPath: "filters.monochromeFilter.inputIntensity")
            animation.toValue = 0.0
            animation.fromValue = 0.8
            animation.fillMode = kCAFillModeForwards
            animation.duration = 1.0
            animation.removedOnCompletion = false
            
            self.iconImageView.layer!.addAnimation(animation, forKey: "colorAnimation")
            
            }, completionHandler: nil)
      })
      
      NSNotificationCenter.defaultCenter().addObserverForName("ServerStoppedSuccessfullyNotification", object: nil, queue: NSOperationQueue.mainQueue(), { (note: NSNotification!) -> Void in
         
         self.serverStatusLabel.stringValue = "Not connected"
         
         self.serverStatusImageView.image = NSImage(named: NSImageNameStatusUnavailable)
         
         NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) in
            
            var animation = CABasicAnimation(keyPath: "filters.monochromeFilter.inputIntensity")
            animation.toValue = 0.8
            animation.fromValue = 0.0
            animation.fillMode = kCAFillModeForwards
            animation.duration = 1.0
            animation.removedOnCompletion = false
            
            self.iconImageView.layer!.addAnimation(animation, forKey: "colorAnimation")
            
            }, completionHandler: nil)
      })
   }
}
