import AppKit

// Controls the preferences window
class PreferencesWindowController: NSWindowController, NSWindowDelegate {
	override var windowNibName: NSNib.Name? {
		return "PreferencesWindow"
	}
	
	@objc dynamic weak var sharedLoginItemManager = LoginItemManager.shared
	
	override func windowDidLoad() {
		super.windowDidLoad()
		self.window?.center()
	}
	
	override func showWindow(_ sender: Any?) {
		if !(self.window?.isVisible ?? true) {
			self.window?.center()
		}
		super.showWindow(sender)
	}
	
	func windowWillClose(_: Notification) {
		(NSApplication.shared.delegate as? AppDelegate)?.deactivateApp()
	}
	
	// recheck if login item is enabled on window updates
	func windowDidUpdate(_: Notification) {
		LoginItemManager.shared.updateEnabled()
	}
}
