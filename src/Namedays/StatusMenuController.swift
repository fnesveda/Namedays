import AppKit
import Foundation

// Manages the status menu for the application
class StatusMenuController: NSObject {
	@IBOutlet private var statusMenu: NSMenu!
	private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
	private var displayedItems = 0
	
	@objc private dynamic var namedaysToDisplay: NSNumber = 7 {
		didSet {
			updateMenu()
		}
	}
	
	@objc private dynamic var showFutureNamedays: NSNumber = 1 {
		didSet {
			updateMenu()
		}
	}
	
	override init() {
		super.init()
		
		// create the status menu
		Bundle.main.loadNibNamed("StatusMenu", owner: self, topLevelObjects: nil)
		statusItem.menu = statusMenu
		
		// human friendly name for autosaving the position of the status item
		if #available(OSX 10.12, *) {
			statusItem.autosaveName = "NamedaysStatusItem"
		}
		
		// set the user defaults and bind them to the right properties
		UserDefaults.standard.register(defaults: ["showFutureNamedays": 1, "namedaysToDisplay": 7])
		self.bind(NSBindingName(rawValue: "namedaysToDisplay"), to: NSUserDefaultsController.shared, withKeyPath: "values.namedaysToDisplay", options: nil)
		self.bind(NSBindingName(rawValue: "showFutureNamedays"), to: NSUserDefaultsController.shared, withKeyPath: "values.showFutureNamedays", options: nil)
		
		// update the status menu on each calendar day change
		NotificationCenter.default.addObserver(self, selector: #selector(updateMenuFromNotification), name: NSNotification.Name.NSCalendarDayChanged, object: nil)
		updateMenu()
	}
	
	@objc
	private func updateMenuFromNotification(_: NSNotification) {
		DispatchQueue.main.async { self.updateMenu() }
	}
	
	// empty action for binding from menu items, so the names in the menu don't look disabled
	@objc
	private func noop() {}
	
	// update the status menu with the namedays for the next few days
	private func updateMenu() {
		let today = Date()
		let calendar = NSCalendar.current
		let components = calendar.dateComponents([.day, .month], from: today)
		
		statusItem.title = Nameday.on(day: components.day ?? 0, month: components.month ?? 0)
		statusItem.menu = statusMenu
		
		// remove the old menu items
		for _ in 0..<displayedItems {
			statusMenu.removeItem(at: 0)
		}
		displayedItems = 0
		
		// if the user wants it, add a menu item for each nameday in the close future
		if showFutureNamedays.intValue > 0 && namedaysToDisplay.intValue > 0 {
			let separator = NSMenuItem.separator()
			statusMenu.insertItem(separator, at: 0)
			displayedItems += 1
			
			// align the date after each nameday to the same offset
			var tabStopLocation: CGFloat = 0
			var paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.tabStops = [NSTextTab(textAlignment: .right, location: tabStopLocation)]
			
			// add the namedays to the menu
			for offset in (1...namedaysToDisplay.intValue).reversed() {
				if let date = calendar.date(byAdding: DateComponents(day: offset), to: today) {
					let components = calendar.dateComponents([.day, .month], from: date)
					let (day, month) = (components.day ?? 0, components.month ?? 0)
					let name = Nameday.on(day: day, month: month)
					let menuItem = NSMenuItem(title: "", action: #selector(self.noop), keyEquivalent: "")
					menuItem.attributedTitle = NSAttributedString(string: "\(name)\t        \(day). \(month).", attributes: [.paragraphStyle: paragraphStyle])
					menuItem.target = self
					statusMenu.insertItem(menuItem, at: 0)
					displayedItems += 1
				}
			}
			
			// find the right position for the tab stop so everything fits but it's not too big
			var oldMenuSize = CGFloat.infinity
			var menuSize = statusMenu.size.width
			while menuSize <= oldMenuSize {
				tabStopLocation += 10
				paragraphStyle = NSMutableParagraphStyle()
				paragraphStyle.tabStops = [NSTextTab(textAlignment: .right, location: tabStopLocation)]
				for offset in (0..<namedaysToDisplay.intValue) {
					statusMenu.item(at: offset)?.attributedTitle = NSAttributedString(string: statusMenu.item(at: offset)?.title ?? "---", attributes: [.paragraphStyle: paragraphStyle])
				}
				statusMenu.update()
				oldMenuSize = menuSize
				menuSize = statusMenu.size.width
			}
		}
	}
}
