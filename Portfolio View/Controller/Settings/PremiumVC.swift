//
//  PremiumVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-12-05.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit
import StoreKit

class PremiumVC: UIViewController, SKPaymentTransactionObserver, UITextFieldDelegate {
    var coinHandler: CoinHandler!
    var delegate: DidBuyPremium?
    
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    
    let productID = "com.porfolioview.portfolioview.portfolioViewPremium"

    override func viewDidLoad() {
        buyButton.backgroundColor = UIColor.link
        buyButton.layer.cornerRadius = 5
        
        restoreButton.backgroundColor = UIColor.systemGray4
        restoreButton.layer.cornerRadius = 5
        
        SKPaymentQueue.default().add(self)
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    @IBAction func purchaseButtonClicked(_ sender: Any) {
        buyPremium()
    }
    
    @IBAction func restore(_ sender: Any) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
//    @IBAction func redeemButtonClicked(_ sender: Any) {
//        if var code = codeTextField.text{
//            code = code.trimmingCharacters(in: .whitespacesAndNewlines)
//            let urlString = "\(K.api)/redeemcode/\(code)".trimmingCharacters(in: .whitespacesAndNewlines)
//            print("CODE: \(code)")
//            let url = URL(string: urlString)!
//            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
//                guard let data = data else {return}
//                let decoder = JSONDecoder()
//                do{
//                    let response = try decoder.decode(CodeRes.self, from: data)
//                    
//                        if (response.res == "success"){
//                            self.coinHandler.premium = true
//                            self.alertOfPurchase(type: "code:\(code)".trimmingCharacters(in: .whitespacesAndNewlines))
//                            DispatchQueue.main.async {
//                                self.navigationController?.popViewController(animated: true)
//                                self.dismiss(animated: true, completion: {
//                                    self.delegate?.didBuyPremium()
//                                })
//                            }
//                        }else{
//                            DispatchQueue.main.async {
//
//                                self.codeTextField.text = ""
//                                self.codeTextField.placeholder = "Invalid code"
//                            }
//                        }
//                    
//                }catch{}
//            }
//            task.resume()
//        }
//    }
//    
    
    func buyPremium(){
        if SKPaymentQueue.canMakePayments(){
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions{
            if transaction.transactionState == .purchased || transaction.transactionState == .restored{
                coinHandler.premium = true
                SKPaymentQueue.default().finishTransaction(transaction)
                alertOfPurchase(type: "purchase")
                navigationController?.popViewController(animated: true)
                dismiss(animated: true, completion: {
                    self.delegate?.didBuyPremium()
                })
            }
            else if transaction.transactionState == .failed{
                if let error = transaction.error{
                    let errorDescription = error.localizedDescription
                    print("transaction failed \(errorDescription)")
                }
                print("transaction failed with no description")
            }
        }
    }
    
    func alertOfPurchase(type: String){
        let code = "\(K.api)/premiumpurchased/\(type)"
        let url = URL(string: code)!
        let task = URLSession.shared.dataTask(with: url)
        task.resume()
    }
}

protocol DidBuyPremium {
    func didBuyPremium()
}

struct CodeRes: Decodable{
    let res: String
}
