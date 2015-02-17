//
//  ConnectionsViewController.swift
//  MongoDB
//
//  Created by Dan Fairaizl on 2/11/15.
//  Copyright (c) 2015 TwentyBelow, LLC. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        let defaultsController = NSUserDefaultsController.sharedUserDefaultsController()
        defaultsController.addObserver(self, forKeyPath: "values.autoStartup", options: NSKeyValueObservingOptions.New, context: nil)
        defaultsController.addObserver(self, forKeyPath: "values.databasePath", options: NSKeyValueObservingOptions.New, context: nil)
        defaultsController.addObserver(self, forKeyPath: "values.logPath", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    override func viewDidDisappear() {
        let defaultsController = NSUserDefaultsController.sharedUserDefaultsController()
        defaultsController.removeObserver(self, forKeyPath: "values.autoStartup")
        defaultsController.removeObserver(self, forKeyPath: "values.databasePath")
        defaultsController.removeObserver(self, forKeyPath: "values.logPath")
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "values.autoStartup" {
            if MongoDB.sharedServer.enabledOnStartup() {
                MongoDB.sharedServer.runOnStartup(false)
            }
            else {
                MongoDB.sharedServer.runOnStartup(true)
            }
        }
        else if keyPath == "values.databasePath" || keyPath == "values.logPath" {
            MongoDB.sharedServer.restartServer()
        }
    }
    
    @IBAction func changeDataDirectory(sender: AnyObject) {
        self.chooseDirectory(forKey: "databasePath")
    }
    
    @IBAction func defaultDataDirectory(sender: AnyObject) {
        
        if let dataDir = MongoDB.sharedServer.defaultDatabaseDirectory() {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(dataDir, forKey: "databasePath")
            defaults.synchronize()
        }
    }
    
    @IBAction func changeLogDirectory(sender: AnyObject) {
        self.chooseDirectory(forKey: "logPath")
    }
    
    @IBAction func defaultLogDirectory(sender: AnyObject) {
        
        if let logDir = MongoDB.sharedServer.defaultLogDirectory() {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(logDir, forKey: "logPath")
            defaults.synchronize()
        }
    }
    
    private
    
    func chooseDirectory(forKey key: String!) {
        
        var panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        
        panel.beginWithCompletionHandler( { (result: Int) in
            if result == NSFileHandlingPanelOKButton {
                let url = panel.URLs[0] as NSURL
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setValue(url.path, forKey: key)
                defaults.synchronize()
            }
        })
    }
}
