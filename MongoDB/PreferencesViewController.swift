//
//  ConnectionsViewController.swift
//  MongoDB
//
//  Created by Dan Fairaizl on 2/11/15.
//  Copyright (c) 2015 TwentyBelow, LLC. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
    
    @IBOutlet weak var changeVersionButton: NSButton!
    @IBOutlet weak var latestVersionButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        let defaultsController = NSUserDefaultsController.sharedUserDefaultsController()
       
        defaultsController.addObserver(self, forKeyPath: "values.autoStartup", options: NSKeyValueObservingOptions.New, context: nil)
        defaultsController.addObserver(self, forKeyPath: "values.databasePath", options: NSKeyValueObservingOptions.New, context: nil)
        defaultsController.addObserver(self, forKeyPath: "values.logPath", options: NSKeyValueObservingOptions.New, context: nil)
        defaultsController.addObserver(self, forKeyPath: "values.mongodbVersion", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    override func viewDidDisappear() {
        let defaultsController = NSUserDefaultsController.sharedUserDefaultsController()
        
        defaultsController.removeObserver(self, forKeyPath: "values.autoStartup")
        defaultsController.removeObserver(self, forKeyPath: "values.databasePath")
        defaultsController.removeObserver(self, forKeyPath: "values.logPath")
        defaultsController.removeObserver(self, forKeyPath: "values.mongodbVersion")
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
        else if keyPath == "values.mongodbVersion" {
            let defaults = NSUserDefaults.standardUserDefaults()
            let v = defaults.stringForKey("mongodbVersion")!
            
            self.enableVersionChange(v)
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
    
    @IBAction func changeVersion(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let v = defaults.stringForKey("mongodbVersion")!
        
        if MongoDB.sharedServer.hasVersionAvailable(v) {
            MongoDB.sharedServer.restartServer()
        }
        else {
            var downloadAlert = NSAlert()
            downloadAlert.addButtonWithTitle("Download")
            downloadAlert.addButtonWithTitle("Cancel")
            downloadAlert.messageText = "Download MongoDB version \(v)?"
            downloadAlert.informativeText = "Version \(v) has not been downloaded yet. Do you want to download it now?"
            downloadAlert.alertStyle = NSAlertStyle.InformationalAlertStyle
            
            downloadAlert.beginSheetModalForWindow(self.view.window!, completionHandler: { (response) -> Void in
                
                NSLog("Response \(response)")
                
                if response == NSAlertFirstButtonReturn {
                    NSLog("download")
                }
                else if response == NSAlertSecondButtonReturn {
                    let defaults = NSUserDefaults.standardUserDefaults()
                    let currentVersion = MongoDB.sharedServer.currentVersion()
                    
                    defaults.setValue(currentVersion, forKey: "mongodbVersion")
                    defaults.synchronize()
                    
                    self.enableVersionChange(MongoDB.sharedServer.currentVersion()!)
                }
            })
        }
    }
    
    @IBAction func latestVersion(sender: AnyObject) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let latestVersion = MongoDB.sharedServer.latestVersion()
       
        defaults.setValue(latestVersion, forKey: "mongodbVersion")
        defaults.synchronize()
    }
    
    private
    
    func enableVersionChange(version: String) {
        
        if let currentVersion = MongoDB.sharedServer.currentVersion() {
            if currentVersion != version {
                self.changeVersionButton.enabled = true
                self.latestVersionButton.enabled = true
            }
            else {
                self.changeVersionButton.enabled = false
                self.latestVersionButton.enabled = false
            }
        }
    }
    
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
