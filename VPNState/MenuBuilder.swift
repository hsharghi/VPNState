//
//  MenuBuilder.swift
//  ArvanCloud
//
//  Created by Hadi Sharghi on 12/27/19.
//  Copyright © 2019 Hadi Sharghi. All rights reserved.
//

import Foundation
import Cocoa

class MenuBuilder {
    
    private var mainMenu: NSMenu
    private var vpn: VPN
    private var appDelegatge: AppDelegate
    
    private let quitMenuItem = NSMenuItem(
        title: "Quit",
        action: #selector(AppDelegate.quit(sender:)),
        keyEquivalent: "")
    
    
    
      private let connect =
          NSMenuItem(
              title: "Connect",
              action: #selector(vpnConnect(sender:)),
              keyEquivalent: "")
          
    
      private let disconnect =
          NSMenuItem(
              title: "Disconnect",
              action: #selector(vpnDisconnect(sender:)),
              keyEquivalent: "")
          
    
     @objc func vpnConnect(sender: Any) {
         try? vpn.connect()
     }
    
     @objc func vpnDisconnect(sender: Any) {
         vpn.disconnect()
     }
     
    init(menu: NSMenu) {
        self.mainMenu = menu
        self.vpn = VPN()
        self.appDelegatge = NSApplication.shared.delegate as! AppDelegate
        self.appDelegatge.device = try? self.vpn.getDevice()
    }
    
    func updateMenu() {
        guard let delegate = NSApplication.shared.delegate as? AppDelegate else {
            return
        }
        let status = vpn.getVPNStatus()
        delegate.updateStatusIcon(status: status)
        switch status {
        case .on:
            connect.isEnabled = false
            disconnect.isEnabled = true
        case .off:
            connect.isEnabled = true
            disconnect.isEnabled = false
        default:
            connect.isEnabled = true
            disconnect.isEnabled = true
        }

        mainMenu.removeAllItems()
        generateMainMenuItems()
    }
    
    
    func generateMainMenuItems() {
        connect.target = self
        disconnect.target = self
        
        mainMenu.addItem(.separator())
        mainMenu.addItem(connect)
        mainMenu.addItem(disconnect)
        mainMenu.addItem(.separator())
        mainMenu.addItem(quitMenuItem)
        
    }
        
    
    @objc func noAction() {
        
    }
    
}
