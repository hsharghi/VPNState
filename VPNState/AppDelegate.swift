//
//  AppDelegate.swift
//  VPNState
//
//  Created by Hadi Sharghi on 11/12/22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBarItem: NSStatusItem!
    var menuBuilder: MenuBuilder!
    var device: String?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        print(toggleDockIcon(showIcon: false))
        

        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(
            withLength: NSStatusItem.squareLength)
        statusBarItem.button?.title = "🌯"

        let statusBarMenu = NSMenu(title: "Cap Status Bar Menu")
        statusBarItem.menu = statusBarMenu
        

        guard let menu = self.statusBarItem.menu else {
            return
        }
        menu.autoenablesItems = false
        self.menuBuilder = MenuBuilder(menu: menu)
        self.menuBuilder.updateMenu()

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.menuBuilder.updateMenu()
        }

        
    }
    
    @objc func quit(sender: Any) {

        NSApp.terminate(sender)
//
//        let answer = dialogOKCancel(question: "Quit VPNState?", text: "", okButtonTitle: "Quit")
//
//        if answer {
//            NSApp.terminate(sender)
//        }
        
    }
    
    func updateStatusIcon(status: VPNStatus) {
        statusBarItem.button?.title = ""
        let image = NSImage(named: status.rawValue)
        statusBarItem.button?.image = image
    }
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    func toggleDockIcon(showIcon state: Bool) -> Bool {
        var result: Bool
        if state {
            result = NSApp.setActivationPolicy(NSApplication.ActivationPolicy.regular)
        }
        else {
            result = NSApp.setActivationPolicy(NSApplication.ActivationPolicy.accessory)
        }
        return result
    }
    
    func dialogOKCancel(question: String,
                        text: String,
                        okButtonTitle: String = "OK",
                        cancelButtonTitle: String = "Cancel") -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: okButtonTitle)
        alert.addButton(withTitle: cancelButtonTitle)
        return alert.runModal() == .alertFirstButtonReturn
    }

}


extension AppDelegate: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        return true
    }
}
