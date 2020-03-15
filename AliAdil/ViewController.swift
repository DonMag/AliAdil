//
//  ViewController.swift
//  AliAdil
//
//  Created by Don Mag on 3/14/20.
//  Copyright © 2020 Don Mag. All rights reserved.
//

import UIKit


protocol SegmentControllerDelegate:class  {
	func indexChanged(index : Int)
}

class CustomSegmentedControl: UIView {
	
	weak var delegate  : SegmentControllerDelegate?
	
	var buttonTitles: [String] = [String]()
	var buttons: [UIButton] = [UIButton]()
	var textColor: UIColor = .black
	var selectorTextColor: UIColor = .red
	var selectorViewColor: UIColor = .red
	var selectedIndex: Int = 0
	
	var selectorViewLeadingAnchor: NSLayoutConstraint!
	
	let selectorView: UIView = {
		let v = UIView()
		return v
	}()
	
	let stackView: UIStackView = {
		let v = UIStackView()
		v.axis = .horizontal
		v.alignment = .fill
		v.distribution = .fillEqually
		v.spacing = 0
		return v
	}()
	
	func setButtonTitles(buttonTitles: [String]) -> Void {
		
		addSubview(stackView)
		
		buttonTitles.forEach { title in
			// create a new button
			let b = UIButton()
			b.setTitle(title, for: .normal)
			b.setTitleColor(textColor, for: .normal)
			// add to stackView
			stackView.addArrangedSubview(b)
			// assign touchUp action
			b.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
			// append to array of buttons
			buttons.append(b)
		}

		// add the selectorView
		addSubview(selectorView)
		// update its backgroundColor
		selectorView.backgroundColor = selectorViewColor

		// setup for auto-layout
		stackView.translatesAutoresizingMaskIntoConstraints = false
		selectorView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
		])

		// first button will be "selected" so, let's get a reference
		let b = buttons[0]
		
		// set its title color
		b.setTitleColor(selectorTextColor, for: .normal)
		
		// constrain the selectorView leading to "selected button" leading
		selectorViewLeadingAnchor = selectorView.leadingAnchor.constraint(equalTo: b.leadingAnchor)
		
		NSLayoutConstraint.activate([
			selectorView.topAnchor.constraint(equalTo: b.bottomAnchor, constant: -4.0),
			selectorView.widthAnchor.constraint(equalTo: b.widthAnchor),
			selectorView.heightAnchor.constraint(equalToConstant: 4.0),
			selectorViewLeadingAnchor,
		])
		
		// save buttonTitles to local array var
		self.buttonTitles = buttonTitles
	}

	@objc func buttonAction(sender:UIButton) {
		
		// get index of tapped button
		guard let buttonIndex = buttons.firstIndex(of: sender) else {
			fatalError("tapped button is not in buttons array!")
		}
		// no need to do anything if tapped on current selected button
		if buttonIndex == selectedIndex { return }
		
		// get reference to currently selected button
		let curSelectedButton = buttons[selectedIndex]
		
		// change its title color to textColor
		curSelectedButton.setTitleColor(textColor, for: .normal)
		
		// change title color of newly selected button to selectorTextColor
		sender.setTitleColor(selectorTextColor, for: .normal)
		
		// animate the selectorView to new position
		selectorViewLeadingAnchor.isActive = false
		selectorViewLeadingAnchor = selectorView.leadingAnchor.constraint(equalTo: sender.leadingAnchor)
		selectorViewLeadingAnchor.isActive = true
		UIView.animate(withDuration: 0.3) {
			self.layoutIfNeeded()
		}

		// tell the delegate the index was changed
		if(delegate != nil){
			delegate?.indexChanged(index: buttonIndex)
		}else{
			print("delegate is nil! buttonIndex:", buttonIndex)
		}

		// update selectedIndex var
		selectedIndex = buttonIndex
		
	}
	
}

class Mail: UIViewController, SegmentControllerDelegate {
	
	func indexChanged(index: Int) {
		print("indexChanged:", index)
		switch index {
		case 0:
			container.bringSubviewToFront(inboxTVC.view)
			break
		case 1:
			container.bringSubviewToFront(outboxTVC.view)
			break
		default:
			break
		}
	}
	
	@IBOutlet weak var segment: CustomSegmentedControl!{
		didSet{
			segment.selectorTextColor = .orange
			segment.selectorViewColor = .orange
			segment.setButtonTitles(buttonTitles: ["First","Second"])
		}
	}
	
	@IBOutlet weak var container: UIView!
	
	var inboxTVC:	InboxTableViewController!
	var outboxTVC: 	OutboxTableViewController!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		segment.delegate = self

		// for both inbox and outbox table view controllers,
		// 	instantiate
		//	add as child view controller
		//	add its view as a subview of container
		//	finish with .didMove()
		
		inboxTVC = InboxTableViewController()
		addChild(inboxTVC)
		container.addSubview(inboxTVC.view)
		inboxTVC.didMove(toParent: self)
		
		outboxTVC = OutboxTableViewController()
		addChild(outboxTVC)
		container.addSubview(outboxTVC.view)
		outboxTVC.didMove(toParent: self)

		// let's use auto-layout for the table views
		
		inboxTVC.view.translatesAutoresizingMaskIntoConstraints = false
		outboxTVC.view.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			
			inboxTVC.view.topAnchor.constraint(equalTo: container.topAnchor),
			inboxTVC.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
			inboxTVC.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
			inboxTVC.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),

			outboxTVC.view.topAnchor.constraint(equalTo: container.topAnchor),
			outboxTVC.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
			outboxTVC.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
			outboxTVC.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
			
		])
		
		// start with first table on top
		container.bringSubviewToFront(inboxTVC.view)
	}

}

class InboxCell: UITableViewCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		commonInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	func commonInit() -> Void {
		textLabel?.textColor = .blue
	}
}

class OutboxCell: UITableViewCell {
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		commonInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	func commonInit() -> Void {
		textLabel?.textColor = .red
	}
}

class InboxTableViewController: UITableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(InboxCell.self, forCellReuseIdentifier: "inboxCell")
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 20
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "inboxCell", for: indexPath) as! InboxCell
		cell.textLabel?.text = "Inbox Table Row: \(indexPath.row)"
		return cell
	}
	
}

class OutboxTableViewController: UITableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(OutboxCell.self, forCellReuseIdentifier: "outboxCell")
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 15
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "outboxCell", for: indexPath) as! OutboxCell
		cell.textLabel?.text = "Outbox Table Row: \(indexPath.row)"
		return cell
	}
	
}

