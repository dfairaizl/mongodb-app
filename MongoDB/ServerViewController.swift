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
   
   @IBOutlet weak var serverStatusLabelConstraint: NSLayoutConstraint!
    
   var uiEnabled: Bool = false
    
   override func viewDidLoad() {
      super.viewDidLoad()
      // Do view setup here.
      
      self.view.wantsLayer = true
      self.view.layer!.backgroundColor = CGColorGetConstantColor(kCGColorWhite)

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
      
      NSNotificationCenter.defaultCenter().addObserverForName("ServerStartedSuccessfullyNotification", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { (note: NSNotification!) -> Void in
         
         self.enableUI()
      })
      
      NSNotificationCenter.defaultCenter().addObserverForName("ServerStoppedSuccessfullyNotification", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { (note: NSNotification!) -> Void in
         
         self.disableUI()
      })
      
      NSNotificationCenter.defaultCenter().addObserverForName("ServerRestartedSuccessfullyNotification", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { (note: NSNotification!) -> Void in
         
         if !self.uiEnabled {
            self.enableUI()
         }
      })
   }
   
   // MARK: Private Methods
   
   private
   
   func enableUI() {
      
      self.serverStatusLabel.stringValue = "Port \(MongoDB.sharedServer.port)"
      self.serverStatusImageView.image = NSImage(named: NSImageNameStatusAvailable)
      
      self.serverStatusLabelConstraint.constant = 60
      self.view.layoutSubtreeIfNeeded()
      
      self.animateIcon(from: 0.8, to: 0.0)
      
      self.uiEnabled = true
   }
   
   func disableUI() {
      
      self.serverStatusLabel.stringValue = "Not connected"
      self.serverStatusImageView.image = NSImage(named: NSImageNameStatusUnavailable)
      
      self.serverStatusLabelConstraint.constant = 85
      self.view.layoutSubtreeIfNeeded()
      
      self.animateIcon(from: 0.0, to: 0.8)
      
      self.uiEnabled = false
   }
   
   func animateIcon(from fromValue: Double, to toValue: Double) {
      NSAnimationContext.runAnimationGroup({ (context: NSAnimationContext!) in
         
         var animation = CABasicAnimation(keyPath: "filters.monochromeFilter.inputIntensity")
         animation.toValue = toValue
         animation.fromValue = fromValue
         animation.fillMode = kCAFillModeForwards
         animation.duration = 1.0
         animation.removedOnCompletion = false
         
         self.iconImageView.layer!.addAnimation(animation, forKey: "colorAnimation")
         
         }, completionHandler: nil)
 
   }
}
