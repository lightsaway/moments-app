//
//  StatusMenuController.swift
//  moments
//
//  Created by Anton Serhiienko on 8/6/16.
//  Copyright © 2016 Serhiienko. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    
    let shooter = Shooter.sharedInstance;

    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    override func awakeFromNib() {
        let icon = NSImage(named: "AppIcon")
        icon?.template = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        shooter.takeSelfie("_quit");
        NSApplication.sharedApplication().terminate(self)
        
    }

    @IBAction func showContents(sender: NSMenuItem){
        let docsPath = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!.relativePath
        let fullPath = docsPath! + "/" + shooter.FOLDERNAME
        NSLog("Opening %@", fullPath)
        NSWorkspace.sharedWorkspace().selectFile(nil, inFileViewerRootedAtPath: fullPath)
    }
    
    @IBAction func photoClicked(sender: NSMenuItem) {
        shooter.takeSelfie("_selfie")
    }
    
}
    
    
    

