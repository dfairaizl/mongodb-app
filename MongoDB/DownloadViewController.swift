//
//  DownloadViewController.swift
//  MongoDB
//
//  Created by Dan Fairaizl on 2/24/15.
//  Copyright (c) 2015 TwentyBelow, LLC. All rights reserved.
//

import Cocoa

class DownloadViewController: NSViewController {
    
    @IBOutlet weak var downloadingLabel: NSTextField!
    @IBOutlet weak var progressLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    var preferencesViewController: PreferencesViewController?
    var version: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        self.downloadingLabel.stringValue = "Downloading MongoDB version \(self.version)"
    }
    
    // MARK: UI ACTIONS
    @IBAction func cancelDownload(sender: AnyObject) {
     
        if let preferences = self.preferencesViewController {
            preferences.view.window!.endSheet(self.view.window!, returnCode: NSModalResponseCancel)
        }
    }
}
