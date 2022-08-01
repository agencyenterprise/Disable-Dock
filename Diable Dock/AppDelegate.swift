import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    public var statusItem: NSStatusItem!
    public var menuItem: NSMenuItem!
    public var menu = NSMenu()
    public var currentUrl = "";
    public var currentId = 0;
    public var dockOpen = true;
    public var timer: Timer?;

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let logoImage = NSImage(named: "logo");
        
        statusItem.button?.title = "Toggle Dock";
        statusItem.button?.image = logoImage;

        self.menuItem = NSMenuItem(title: "Disable Dock", action: #selector(self.toggleDock), keyEquivalent: "t")
        
        self.menu.addItem(menuItem)

        self.menu.addItem(NSMenuItem.separator())

        self.menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        self.statusItem.menu = self.menu
    }
    
    @objc func toggleDock() {
        if (self.dockOpen) {
            self.killDock()
        } else {
            self.openDock()
        }
        self.dockOpen = !self.dockOpen
    }
    
    func execute(c: String, a: [String]) {
        let pipe = Pipe()

        let task = Process()
        task.launchPath = c
        task.arguments = a
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            print(output)
        }
    }

    func killDock()
    {
        self.execute(c: "/usr/bin/defaults", a: ["write", "com.apple.dock", "autohide", "-bool", "TRUE"])
        self.execute(c: "/usr/bin/killall", a: ["Dock"])
        
        self.execute(c: "/usr/bin/defaults", a: ["write", "com.apple.dock", "autohide-delay", "-float", "1000"])
        self.execute(c: "/usr/bin/killall", a: ["Dock"])
        
        self.execute(c: "/usr/bin/defaults", a: ["write", "com.apple.dock", "no-bounding", "-bool", "TRUE"])
        self.execute(c: "/usr/bin/killall", a: ["Dock"])
        self.menuItem.title = "Enable Dock"
    }
    
    func openDock() {
        self.execute(c: "/usr/bin/defaults", a: ["write", "com.apple.dock", "autohide", "-bool", "FALSE"])
        self.execute(c: "/usr/bin/killall", a: ["Dock"])
        
        self.execute(c: "/usr/bin/defaults", a: ["write", "com.apple.dock", "autohide-delay"])
        self.execute(c: "/usr/bin/killall", a: ["Dock"])
        
        self.execute(c: "/usr/bin/defaults", a: ["write", "com.apple.dock", "no-bounding"])
        self.execute(c: "/usr/bin/killall", a: ["Dock"])
        self.menuItem.title = "Disable Dock"
    }

    func applicationWillTerminate(_ aNotification: Notification) {

    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
