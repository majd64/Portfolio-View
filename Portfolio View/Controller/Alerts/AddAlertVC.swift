//
//  AddAlertVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-11-21.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class AddAlertVC: UIViewController, UITextFieldDelegate {
    var coinHandler: CoinHandler!
    var coin: Coin!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var textField: UITextField!{
        didSet { textField?.addDoneCancelToolbar() }
    }
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        textField.delegate = self
        image.image = coin.getImage()
        name.text = coin.getSymbol().uppercased()
        price.text = "\(K.convertToCoinPrice(coinHandler.convertCurrencies(from: coinHandler.preferredCurrency, to: "USD", amount: coin.getPrice()) ?? 0, currency: "USD")) USD"
        
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if coinHandler.appearance == "dark"{
            overrideUserInterfaceStyle = .dark
            self.navigationController?.overrideUserInterfaceStyle = .dark
        }
        else if coinHandler.appearance == "light"{
            overrideUserInterfaceStyle = .light
            self.navigationController?.overrideUserInterfaceStyle = .light
        }else{
            overrideUserInterfaceStyle = .unspecified
            self.navigationController?.overrideUserInterfaceStyle = .unspecified
        }
    }
    
  
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    @IBAction func addAlertPressed(_ sender: Any) {
        if let price = Double(K.convertCommasToDots(textField.text ?? "")){
            let isAbove = segmentedControl.selectedSegmentIndex == 0
            
            
            let url = URL(string: "\(K.api)/alerts/\(coinHandler.deviceToken)")!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let parameters: [String: Any] = [
                "coinID": coin.getID(),
                "price": price,
                "above": isAbove
            ]
            request.httpBody = parameters.percentEncoded()

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data,
                    let response = response as? HTTPURLResponse,
                    error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
                }

                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    return
                }

                let responseString = String(data: data, encoding: .utf8)
            }

            task.resume()
            
            navigationController?.popViewController(animated: true)

            dismiss(animated: true, completion: nil)
        }
    }
}
