//
//  EditEnabledCoinsContainer.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-12-19.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class EditEnabledCoinsContainer: UIViewController{
    var coinHandler: CoinHandler!
    var delegate: EditCoinsDelegate?
    @IBOutlet weak var button0: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    
    override func viewDidLoad() {
        
        button0.backgroundColor = UIColor.systemGray4
        button0.layer.cornerRadius = 5
        
        button1.backgroundColor = UIColor.systemGray4
        button1.layer.cornerRadius = 5
        
        button2.backgroundColor = UIColor.systemGray4
        button2.layer.cornerRadius = 5
        
        button3.backgroundColor = UIColor.systemGray4
        button3.layer.cornerRadius = 5
        
        super.viewDidLoad()
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        delegate?.buttonPressed(sender.tag)
    }
}

protocol EditCoinsDelegate {
    func buttonPressed(_ val: Int)
}
