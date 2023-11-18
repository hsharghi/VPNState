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
    
    
    
      private let asia =
          NSMenuItem(
              title: "Asia",
              action: #selector(connectAsia(sender:)),
              keyEquivalent: "")
          
      private let w403 =
          NSMenuItem(
              title: "403",
              action: #selector(connect403(sender: )),
              keyEquivalent: "")
          
      private let shecan =
          NSMenuItem(
              title: "Shecan",
              action: #selector(connectShecan(sender: )),
              keyEquivalent: "")
          
    
      private let disconnect =
          NSMenuItem(
              title: "Disconnect",
              action: #selector(vpnDisconnect(sender:)),
              keyEquivalent: "")
          
    
    @objc func connectAsia(sender: Any) {
        try? vpn.connect(to: .asia)
    }
    @objc func connect403(sender: Any) {
        try? vpn.connect(to: .w403)
    }
    @objc func connectShecan(sender: Any) {
        try? vpn.connect(to: .shecan)
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
        case .asia:
            asia.isEnabled = false
            w403.isEnabled = true
            shecan.isEnabled = true
            disconnect.isEnabled = true
        case .w403:
            asia.isEnabled = true
            w403.isEnabled = false
            shecan.isEnabled = true
            disconnect.isEnabled = true
        case .shecan:
            asia.isEnabled = true
            w403.isEnabled = true
            shecan.isEnabled = false
            disconnect.isEnabled = true
        case .off:
            asia.isEnabled = true
            w403.isEnabled = true
            shecan.isEnabled = true
            disconnect.isEnabled = false
        default:
            asia.isEnabled = true
            disconnect.isEnabled = true
        }

        mainMenu.removeAllItems()
        generateMainMenuItems()
    }
    
    
    func generateMainMenuItems() {
        asia.target = self
        shecan.target = self
        w403.target = self
        disconnect.target = self
        
        mainMenu.addItem(.separator())
        mainMenu.addItem(asia)
        mainMenu.addItem(w403)
        mainMenu.addItem(shecan)
        mainMenu.addItem(disconnect)
        mainMenu.addItem(.separator())
        mainMenu.addItem(quitMenuItem)
        
    }
        
    
    @objc func noAction() {
        
    }
    
}
