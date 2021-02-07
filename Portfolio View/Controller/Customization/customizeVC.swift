//
//  customizeVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2021-01-21.
//  Copyright © 2021 Majd Hailat. All rights reserved.
//

import UIKit

class CustomizeVC: UIViewController {
    var coinHandler: CoinHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToCustom"){
            if #available(iOS 14.0, *) {
                let destinationVC = segue.destination as! CustomVC
                destinationVC.coinHandler = coinHandler
            } else {
                //go back to settings and alert user that this isnt availble (only iOS 14)
            }
            
        }
    }
    
}
