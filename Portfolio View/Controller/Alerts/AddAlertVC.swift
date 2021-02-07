//
//  AddAlertVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-11-21.
//  Copyright © 2020 Majd Hailat
//All rights reserved.
//

import UIKit

class AddAlertVC: UIViewController, UITextFieldDelegate {
    var coinHandler: CoinHandler!
    var coin: Coin!
    var delegate: AlertAdded?
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var textField: UITextField!{
        didSet { textField?.addDoneCancelToolbar() }
    }
    
    var coinPrice: Double?
    var isAbove: Bool?
    
    var selectedPrice: Double?
    
    @IBOutlet weak var crossesAboveButton: UIButton!
    @IBOutlet weak var crossesBelowButton: UIButton!
    
    override func viewDidLoad() {
        textField.delegate = self
        image.image = coin.getImage()
        name.text = coin.getSymbol().uppercased()
        addButton.backgroundColor = UIColor.systemGray4
        addButton.layer.cornerRadius = 5
        
        crossesBelowButton.backgroundColor = UIColor.systemGray
        crossesBelowButton.layer.cornerRadius = 3
        
        crossesAboveButton.backgroundColor = UIColor.systemGray
        crossesAboveButton.layer.cornerRadius = 3
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        detailsLabel.isHidden = true
        
        textField.placeholder = "Price in \(coinHandler.preferredCurrency.uppercased())"

        super.viewDidLoad()
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let selectedPrice = Double(K.convertCommasToDots(textField.text ?? "")), let price = coinPrice{
            detailsLabel.isHidden = false
            if selectedPrice >= price{
                isAbove = true

                crossesAboveButton.backgroundColor = UIColor.systemGreen
                crossesBelowButton.backgroundColor = UIColor.systemGray
            }else{
                isAbove = false
                crossesAboveButton.backgroundColor = UIColor.systemGray
                crossesBelowButton.backgroundColor = UIColor.systemRed
            }
            detailsLabel.text = "Alert me when the price of \(coin.getSymbol().uppercased()) crosses \(isAbove! ? "above" : "below") \(K.convertToCoinPrice(selectedPrice, currency: coinHandler.preferredCurrency)) \(coinHandler.preferredCurrency.uppercased())"
            
            
        }else{
            detailsLabel.isHidden = true
            crossesAboveButton.backgroundColor = UIColor.systemGray
            crossesBelowButton.backgroundColor = UIColor.systemGray
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        coinPrice = coin.getPrice()
        price.text = "\(K.convertToCoinPrice(coin.getPrice(), currency: coinHandler.preferredCurrency)) \(coinHandler.preferredCurrency.uppercased())"
        
        switch coinHandler.appearance{
        case "dark":
            overrideUserInterfaceStyle = .dark
            self.navigationController?.overrideUserInterfaceStyle = .dark
        case "light":
            coinHandler.appearance = "light"
            overrideUserInterfaceStyle = .light
            self.navigationController?.overrideUserInterfaceStyle = .light
        default:
            coinHandler.appearance = "auto"
            overrideUserInterfaceStyle = .unspecified
            self.navigationController?.overrideUserInterfaceStyle = .unspecified
        }
        super.viewWillAppear(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    @IBAction func addAlertPressed(_ sender: Any) {
        if let selectedPrice = Double(K.convertCommasToDots(textField.text ?? "")), let price = coinPrice{
            if selectedPrice >= price{
                isAbove = true
            }else{
                isAbove = false
            }
            let url = URL(string: "\(K.api)/alerts/\(coinHandler.deviceId)")!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let parameters: [String: Any] = [
                "coinID": coin.getID(),
                "coinTicker": coin.getSymbol(),
                "currencyID": coinHandler.preferredCurrency,
                "price": selectedPrice,
                "above": isAbove!
            ]
            request.httpBody = parameters.percentEncoded()

            let task = URLSession.shared.dataTask(with: request) { data, response, error in}

            task.resume()
            
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                print(self.delegate)
                self.delegate?.alertAdded()
                
            })
        }else{
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
        }
        
    }
}


protocol AlertAdded {
    func alertAdded()
}
