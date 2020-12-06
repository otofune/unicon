//
//  AppDelegate.swift
//  unicon
//
//  Created by owner on 2020/11/17.
//

import Cocoa

extension NSMenu {
    @discardableResult
    func addMenuTitleOnly(_ title: String) -> NSMenuItem {
        let menu = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        self.addItem(menu)
        return menu
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

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    let textField = NSTextField(labelWithString: "unicon")

    func setStatusItemText(_ upper: String, _ lower: String) {
        let font = NSFont.systemFont(ofSize: 9)
        let p = NSMutableParagraphStyle()
        p.alignment = .left
        let title = NSMutableAttributedString()
        title.append(NSAttributedString(string: upper + "\n", attributes: [ .font: font, .paragraphStyle: p ]))
        title.append(NSAttributedString(string: lower, attributes: [ .font: font, .paragraphStyle: p ]))
        textField.attributedStringValue = title
        textField.sizeToFit()
        statusItem.button!.frame = CGRect(x: 0, y: 0, width: textField.frame.width, height: statusItem.button!.frame.height)
        statusItem.isVisible = true
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem.isVisible = false
        // 縦幅を合わせる（本当にこれでいいのか？）
        textField.frame = CGRect(x: 0, y: 0, width: statusItem.button!.frame.width, height: statusItem.button!.frame.height)
        textField.lineBreakMode = .byTruncatingTail
        let parent = statusItem.button!
        parent.addSubview(textField)

        // TODO: changeHandler を selector で渡したほうがいいというアドバイスを受けたが、やり方が不明
        // selector のほうがいいのはおそらくメモリリークしないから (self を NSWorkspace に強参照されたくない)
        // この場合だと問題ないだろうけど（アプリのライフサイクルと完全に一致しているため）覚えておきたい
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

        statusItem.isVisible = true

        let menu = NSMenu()

        setStatusItemText(name, (app.executableArchitecture as CPUArchitecture).toStr())

        let appArch = (app.executableArchitecture as CPUArchitecture).toStr()
        let appMenu = menu.addMenuTitleOnly("\(name) runs with \(appArch)")
        let appSubMenu = NSMenu()
        appMenu.submenu = appSubMenu
        appSubMenu.addMenuTitleOnly("Identifier:")
        appSubMenu.addMenuTitleOnly("\t\(identifier)")
        menu.addSeparator()

        // list supported architectures
        if let p = app.executableURL {
            if let archs = try? MachOUtility.supportCPUTypes(path: p) {
                if archs.isEmpty {
                    appSubMenu.addMenuTitleOnly("Architectures supported:")
                    appSubMenu.addMenuTitleOnly("\t\(appArch)")
                } else {
                    appSubMenu.addMenuTitleOnly("Architectures supported:")
                    let arch_names = archs.map({ a in (a as CPUArchitecture).toStr() })
                    appSubMenu.addMenuTitleOnly("\t\(arch_names.joined(separator: ", "))")
                }
            }
        }

        menu.addAppFooter()
        statusItem.menu = menu
        return true
    }
}
