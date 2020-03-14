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
	var textColor: UIColor = .red
	var selectorTextColor: UIColor = .red
	var selectorViewColor: UIColor = .red
	var selectedIndex: Int = 0
	
	var selectorView: UIView = {
		let v = UIView()
		return v
	}()
	
	func setButtonTitles(buttonTitles: [String]) -> Void {
		
		let w = bounds.size.width / CGFloat(buttonTitles.count)
		let h = bounds.size.height
		
		var i: CGFloat = 0
		buttonTitles.forEach { title in
			let b = UIButton()
			b.setTitle(title, for: .normal)
			b.setTitleColor(textColor, for: .normal)
			if i == 0 {
				b.setTitleColor(selectorTextColor, for: .normal)
			}
			b.frame = CGRect(x: i * w, y: 0, width: w, height: h)
			i += 1
			addSubview(b)
			b.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
			buttons.append(b)
		}
		
		addSubview(selectorView)
		selectorView.frame = CGRect(x: 0.0, y: h - 4.0, width: w, height: 4.0)
		selectorView.backgroundColor = selectorViewColor
		
		self.buttonTitles = buttonTitles
	}
	
	@objc func buttonAction(sender:UIButton) {
		print("tap in CustomSegmentedControl")
		for (buttonIndex, btn) in buttons.enumerated() {
			btn.setTitleColor(textColor, for: .normal)
			if btn == sender {
				let selectorPosition = frame.width/CGFloat(buttonTitles.count) * CGFloat(buttonIndex)
				selectedIndex = buttonIndex
				//delegate?.changeToIndex(index: buttonIndex)
				if(delegate != nil){
					print("calling delegate:", buttonIndex)
					delegate?.indexChanged(index: buttonIndex)
				}else{
					print("delegate is nil! buttonIndex:", buttonIndex)
				}
				UIView.animate(withDuration: 0.3) {
					self.selectorView.frame.origin.x = selectorPosition
				}
				btn.setTitleColor(selectorTextColor, for: .normal)
			}
		}
	}
	
}

class Mail: UIViewController, SegmentControllerDelegate {
	
	func indexChanged(index: Int) {
		print("indexChanged:", index)
		switch index {
		case 0:
			container.bringSubviewToFront(inbox)
			break
		case 1:
			container.bringSubviewToFront(outbox)
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
	
	var inbox  : UIView!
	var outbox : UIView!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		segment.delegate = self
		inbox = Inbox().view
		outbox = GPS().view
		container.addSubview(outbox)
		container.addSubview(inbox)
		
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		inbox.frame = container.bounds
		outbox.frame = container.bounds
	}
	
}

class Inbox: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .green
	}
	
}

class GPS: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .red
	}
	
}
