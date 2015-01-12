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
        
        task.launch()
        
        var stdOutHandle = task.standardOutput.fileHandleForReading.readDataToEndOfFile()
        var stdErrHandle = task.standardError.fileHandleForReading.readDataToEndOfFile()
        
        let stdOut = NSString(data: stdOutHandle, encoding: NSUTF8StringEncoding)
        let stdErr = NSString(data: stdErrHandle, encoding: NSUTF8StringEncoding)
        
        task.waitUntilExit()
        
        return (stdOut, stdErr)
    }
    
    class func executeAsyncTask(binPath: String, withArguments args: Array<String>) -> (String?, String?) {
        
        var task = NSTask()
        
        task.launchPath = binPath
        task.arguments = args
        
        task.standardError = NSPipe()
        task.standardOutput = NSPipe()
        
        task.launch()
        
        var stdOutHandle = task.standardOutput.fileHandleForReading.readDataToEndOfFile()
        var stdErrHandle = task.standardError.fileHandleForReading.readDataToEndOfFile()
        
        let stdOut = NSString(data: stdOutHandle, encoding: NSUTF8StringEncoding)
        let stdErr = NSString(data: stdErrHandle, encoding: NSUTF8StringEncoding)
        
        return (stdOut, stdErr)
    }
}
