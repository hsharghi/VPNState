//
//  VPN.swift
//  VPNState
//
//  Created by Hadi Sharghi on 11/12/22.
//

import Foundation
#if(canImport(RegexBuilder))
import RegexBuilder
#endif

enum VPNStatus: String {
    case asia = "Asia"
    case off = "OFF"
    case w403 = "403"
    case shecan = "Shecan"
    case unknown = "Unknow"
}

struct NetworkError: Error {
    var message: String
}


class VPN {
    
    private let bash: Bash
    
    init() {
        bash = Bash()
        Bash.debugEnabled = true
    }
    
    
    var status: VPNStatus {
        return getVPNStatus()
    }
    
    func getDevice() throws -> String? {
        
        guard let info = try? bash.run("networksetup", arguments: ["-listnetworkserviceorder"]) else {
            throw NetworkError(message: "Can't get device name")
        }
        
        if #available(macOS 13, *) {
            let search = Regex {
                "Hardware Port: Wi-Fi, Device: "
                Capture {
                    OneOrMore(.word)
                }
            }
            
            guard let result = try? search.firstMatch(in: info) else {
                throw NetworkError(message: "No Wi-Fi device")
            }
            
            return String(result.1)
        } else {
            let range = NSRange(location: 0, length: info.utf16.count)
            let regex = try! NSRegularExpression(pattern: "\\w+.*Wi-Fi, Device: \\s*(\\w{3})")
            let result = regex.matches(in: info, range: range)
            if result.count == 0 {
                throw NetworkError(message: "No Wi-Fi device")
            }
            guard let rr = Range(result[0].range(at: 1), in: info) else {
                throw NetworkError(message: "Can't get Wi-Fi device name")
            }
            
            return info.substring(with: rr)
        }
        
        
    }
    
    func getVPNStatus() -> VPNStatus {
        if let dns = try? bash.run("networksetup", arguments: ["-getdnsservers", "Wi-Fi"]) {
            switch dns {
            case "192.168.80.2":
                return .asia
                
            case "178.22.122.100\n185.51.200.2":
                return .shecan
                
            case "10.202.10.202\n10.202.10.102":
                return .w403
                
            case "192.168.80.1":
                return .off
                
            default:
                return .unknown
            }
        }
        return .unknown
    }
    
    func connect(to vpn: VPNStatus = .asia) throws {
        guard let ip = try? bash.run("ipconfig", arguments: ["getifaddr", "en1"]) else {
            throw NetworkError(message: "Can't get system IP")
        }
        switch vpn {
        case .asia:
            _ = try? bash.run("networksetup", arguments: ["-setmanual", "Wi-Fi", ip, "255.255.255.0", "192.168.80.2"])
            _ = try? bash.run("networksetup", arguments: ["-setdnsservers", "Wi-Fi", "192.168.80.2"])
        case .w403:
            _ = try? bash.run("networksetup", arguments: ["-setmanual", "Wi-Fi", ip, "255.255.255.0", "192.168.80.1"])
            _ = try? bash.run("networksetup", arguments: ["-setdnsservers", "Wi-Fi", "10.202.10.202", "10.202.10.102"])
        case .shecan:
            _ = try? bash.run("networksetup", arguments: ["-setmanual", "Wi-Fi", ip, "255.255.255.0", "192.168.80.1"])
            _ = try? bash.run("networksetup", arguments: ["-setdnsservers", "Wi-Fi", "178.22.122.100", "185.51.200.2"])
        default:
            return
        }
        
    }
    
    func disconnect() {
        _ = try? bash.run("networksetup", arguments: ["-setdhcp", "Wi-Fi"])
        _ = try? bash.run("networksetup", arguments: ["-setdnsservers", "Wi-Fi", "192.168.80.1"])
    }
    
}
