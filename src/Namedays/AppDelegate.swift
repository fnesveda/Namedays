import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	private var statusMenuController: StatusMenuController?
	private var preferencesWindowController: PreferencesWindowController?
	
	func applicationWillFinishLaunching(_ notification: Notification) {
 		// don't put the "Enter Full Screen" menu item into the View submenu, there are no windows to put to fullscreen
		UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
		// don't put the "Emoji & Symbols" menu item into the Edit submenu, there is no textbox to put emoji in
		UserDefaults.standard.set(true, forKey: "NSDisabledCharacterPaletteMenuItem")
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		self.statusMenuController = StatusMenuController()
		self.preferencesWindowController = PreferencesWindowController()
	}
	
	@IBAction private func showPreferencesWindow(_ sender: Any?) {
		self.activateApp()
		DispatchQueue.main.async { self.preferencesWindowController?.showWindow(sender) }
	}
	
	@IBAction private func showAboutPanel(_ sender: Any?) {
		if #available(OSX 10.13, *) {
			let link = "https://www.nesveda.com/projects/Namedays"
			let credits = NSAttributedString(string: link, attributes: [.link: NSURL(string: link) ?? ""])
			NSApplication.shared.orderFrontStandardAboutPanel(options: [.credits: credits])
		}
		else {
			NSApplication.shared.orderFrontStandardAboutPanel(sender)
		}
	}
	
	// show the main menu and Dock icon
	func activateApp() {
		NSApplication.shared.setActivationPolicy(.regular)
		NSApplication.shared.activate(ignoringOtherApps: true)
	}
	
	// hide the main menu and Dock icon
	func deactivateApp() {
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150)) { NSApplication.shared.setActivationPolicy(.accessory) }
	}
}
