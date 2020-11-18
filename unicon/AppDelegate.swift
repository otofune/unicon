//
//  AppDelegate.swift
//  unicon
//
//  Created by owner on 2020/11/17.
//

import Cocoa
import SwiftUI

// TODO: 自動で Int になっちゃうのか気になる (オートダウンキャストされるのか名前によって絞られるのか)
typealias CPUType = cpu_type_t // NSBundleExecutableArchitecture と中の値は同じっぽいが

enum CPUGroup {
    case Unknown
    case PPC
    case Intel
    case Apple
}

protocol CPUArchitecture {
    func toStr() -> String
    func group() -> CPUGroup
}

extension Int: CPUArchitecture {
    func toStr() -> String {
        switch self {
        case NSBundleExecutableArchitecturePPC:
            return "ppc"
        case NSBundleExecutableArchitecturePPC64:
            return "ppc64"
        case NSBundleExecutableArchitectureI386:
            return "i386"
        case NSBundleExecutableArchitectureX86_64:
            return "x86_64"
        case let other:
            if #available(OSX 11.0, *), other == NSBundleExecutableArchitectureARM64 {
                return "arm64"
            }
            if other == Int(CPU_TYPE_ARM64) {
                return "arm64"
            }
            fallthrough
        default: return "Unknown"
        }
    }
    func group() -> CPUGroup {
        switch self {
        case NSBundleExecutableArchitecturePPC:
            fallthrough
        case NSBundleExecutableArchitecturePPC64:
            return .PPC
        case NSBundleExecutableArchitectureI386:
            fallthrough
        case NSBundleExecutableArchitectureX86_64:
            return .Intel
        case let other:
            if #available(OSX 11.0, *), other == NSBundleExecutableArchitectureARM64 {
                return .Apple
            }
            fallthrough
        default: return .Unknown
        }
    }
}

extension CPUType: CPUArchitecture {
    func toStr() -> String {
        (Int(self) as CPUArchitecture).toStr()
    }
    func group() -> CPUGroup {
        (Int(self) as CPUArchitecture).group()
    }
}

extension NSMenu {
    func addMenuTitleOnly(_ title: String) {
        self.addItem(NSMenuItem(title: title, action: nil, keyEquivalent: ""))
    }
    func addSeparator() {
        self.addItem(NSMenuItem.separator())
    }
    func addAppFooter() {
        self.addSeparator()
        self.addItem(NSMenuItem(title: "About \(ProcessInfo.processInfo.processName)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ""))
        self.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "quit"))
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var observer: NSKeyValueObservation!

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        // 起動直後は無視する
        let menu = NSMenu()
        menu.addMenuTitleOnly("Switch active app…")
        menu.addAppFooter()
        statusItem.menu = menu

        // TODO: changeHandler を selector で渡したほうがいいというアドバイスを受けたが、やり方が不明
        // selector のほうがいいのはおそらくメモリリークしないから (self を NSWorkspace に強参照されたくない)
        // NSObject に生えてる observe じゃなくて NSKeyValueObserving のほう使えばいいのか?
        observer = NSWorkspace.shared.observe(\.frontmostApplication, options: [.new], changeHandler: self.onFrontmostApplicationChanged)

        NSApp.setActivationPolicy(NSApplication.ActivationPolicy.accessory)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func onFrontmostApplicationChanged(model: NSWorkspace, value: NSKeyValueObservedChange<NSRunningApplication?>) {
        if let app = value.newValue as? NSRunningApplication {
            self.applyNSRunningApplicationChange(app)
        }
    }

    func applyNSRunningApplicationChange(_ app: NSRunningApplication) {
        if _applyNSRunningApplicationChange(app) { return }
        let menu = NSMenu()
        menu.addMenuTitleOnly("No running app detected.")
        menu.addAppFooter()
        statusItem.menu = menu
    }
    
    func _applyNSRunningApplicationChange(_ app: NSRunningApplication) -> Bool {
        // TODO: 自分だったら更新したくない (そもそも active にならない気もするが)
        guard let identifier = app.bundleIdentifier else { return false }
        guard let name = app.localizedName else { return false }

        let menu = NSMenu()

        let machineArch = (try? MachOUtility.getMachineArchitecture()) ?? -1
        let machineArchGroup = (machineArch as CPUArchitecture).group()
        let appArchGroup = (app.executableArchitecture as CPUArchitecture).group()
        let isNative = machineArchGroup == appArchGroup

        let appArch = (app.executableArchitecture as CPUArchitecture).toStr()
        menu.addMenuTitleOnly("\(name) runs \(isNative ? "natively " : "")on \(appArch)")
        menu.addSeparator()

        menu.addMenuTitleOnly("Identifier: \(identifier)")

        // support architectures
        if let p = app.executableURL {
            if let archs = try? MachOUtility.supportCPUTypes(path: p) {
                if archs.isEmpty {
                    menu.addMenuTitleOnly("Architectures: \(appArch) (only)")
                } else {
                    let arch_names = archs.map({ a in (a as CPUArchitecture).toStr() })
                    menu.addMenuTitleOnly("Architectures: \(arch_names.joined(separator: ", "))")
                }
            }
        }

        menu.addAppFooter()
        statusItem.menu = menu
        return true
    }
}
