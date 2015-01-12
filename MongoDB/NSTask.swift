//
//  NSTask.swift
//  MongoDB
//
//  Created by Dan Fairaizl on 12/29/14.
//  Copyright (c) 2014 TwentyBelow, LLC. All rights reserved.
//

import Cocoa

extension NSTask {
    
    class func executeSyncTask(binPath: String, withArguments args: Array<String>) -> (String?, String?) {
        
        var task = NSTask()
        
        task.launchPath = binPath
        task.arguments = args
        
        task.standardError = NSPipe()
        task.standardOutput = NSPipe()
        
        var stdOutHandle = task.standardOutput.fileHandleForReading.readDataToEndOfFile()
        var stdErrHandle = task.standardError.fileHandleForReading.readDataToEndOfFile()
        
        let stdOut = NSString(data: stdOutHandle, encoding: NSUTF8StringEncoding)
        let stdErr = NSString(data: stdErrHandle, encoding: NSUTF8StringEncoding)
        
        task.launch()
        task.waitUntilExit()
        
        return (stdOut, stdErr)
    }
    
    class func runProcess(binPath: String, pipe: NSPipe, withArguments args: Array<String>, completion: (_: String) -> Void) {
        let mainQueue = NSOperationQueue.mainQueue()
        var task = NSTask()
        
        task.launchPath = binPath
        task.arguments = args
        
        task.standardOutput = pipe
        
        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleDataAvailableNotification, object: pipe.fileHandleForReading, queue: mainQueue, { (note: NSNotification!) -> Void in
            
            let handle: NSFileHandle = note.object as NSFileHandle
            let data = handle.availableData
            
            if data.length > 0 {
                if let stdOut = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    completion(stdOut)
                }
                
                handle.waitForDataInBackgroundAndNotify()
            }
        })
        
        task.launch()
        task.waitUntilExit()
    }
}
