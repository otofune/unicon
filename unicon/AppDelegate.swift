//
//  AppDelegate.swift
//  unicon
//
//  Created by owner on 2020/11/17.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var observer: NSKeyValueObservation!

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.button?.image = NSImage(named: NSImage.bookmarksTemplateName)
        // TODO: これやると自身を差したやつになっちゃう (なんでやねん)
        if let app = NSWorkspace.shared.frontmostApplication {
            applyNSRunningApplicationChange(app)
        } else {
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "No running app detected.", action: nil, keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "quit"))
            statusItem.menu = menu
        }

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
        // TODO: nest するとやなのでこうしてる
        // newValue が [.new] が確実に指定されてるなら来るはずなので、強制でやってるけど本当にいいの?
        if let app = value.newValue! {
            self.applyNSRunningApplicationChange(app)
        }
    }

    func applyNSRunningApplicationChange(_ app: NSRunningApplication) {
        // TODO: 自分だったら更新したくない (そもそも active にならない気もするが)
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Ident: \(app.bundleIdentifier!)", action: nil, keyEquivalent: ""))
        let architecture = architectureStringFromExecutableArchitecture(app.executableArchitecture)
        menu.addItem(NSMenuItem(title: "Architecture: \(architecture)", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate), keyEquivalent: "quit"))
        statusItem.menu = menu
    }
    
    func architectureStringFromExecutableArchitecture(_ executableArchitecture: Int) -> String {
        switch executableArchitecture {
        case NSBundleExecutableArchitecturePPC:
            return "PPC32"
        case NSBundleExecutableArchitecturePPC64:
            return "PPC64"
        case NSBundleExecutableArchitectureI386:
            return "i386"
        case NSBundleExecutableArchitectureX86_64:
            return "x86_84"
        case let other:
            if #available(OSX 11.0, *), other == NSBundleExecutableArchitectureARM64 {
                return "Apple Silicon"
            }
            fallthrough
        default: return "Unknown"
        }
    }
}
