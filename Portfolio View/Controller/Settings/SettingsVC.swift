//
//  SettingsVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-10-20.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit
import StoreKit

class SettingsVC: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, DidBuyPremium{
    var coinHandler: CoinHandler!
    private let defaults = UserDefaults.standard
    @IBOutlet weak var sortTypePickerView: UIPickerView!
    @IBOutlet weak var appearanceSegmentedControl: UISegmentedControl!
    @IBOutlet weak var selectedCurrencyLabel: UILabel!
    @IBOutlet weak var selectedSecondaryCurrencyLabel: UILabel!
    
    @IBOutlet weak var premiumCell: UITableViewCell!
    @IBOutlet weak var premiumCellLabel: UILabel!
    @IBOutlet weak var premiumCellLearnMore: UILabel!
   
    @IBOutlet weak var volatilityAlertSwitch: UISwitch!
    @IBOutlet weak var promoCell: UITableViewCell!
    @IBOutlet weak var deviceIDLabel: UITextView!
    @IBOutlet weak var deviceIdCell: UITableViewCell!
    @IBOutlet weak var promoLabel: UILabel!
    var promoVisable = false
    var promoUrl: String = ""
    var showDeviceId: Bool = false
    
    override func viewDidLoad() {
        volatilityAlertSwitch.isOn = coinHandler.volatilityAlert
        volatilityAlertSwitch.isEnabled = false
        volatilityAlertSwitch.isUserInteractionEnabled = false
        sortTypePickerView.delegate = self
        sortTypePickerView.dataSource = self
        deviceIdCell.isHidden = true
        promoCell.isHidden = true
        deviceIDLabel.text = coinHandler.deviceId
        fetchPromo()
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        toggleBasedOnPremium()
        sortTypePickerView.selectRow(coinHandler.sortTypeIds.firstIndex(of: coinHandler.preferredSortType)!, inComponent: 0, animated: false)
        selectedCurrencyLabel.text = coinHandler.preferredCurrency.uppercased()
        selectedSecondaryCurrencyLabel.text = coinHandler.secondaryCurrency.uppercased()
        switch coinHandler.appearance{
        case "dark":
            appearanceSegmentedControl.selectedSegmentIndex = 0
        case "light":
            appearanceSegmentedControl.selectedSegmentIndex = 1
        default:
            appearanceSegmentedControl.selectedSegmentIndex = 2
        }
    }

    
    @IBAction func volatilityAlertSwitched(_ sender: UISwitch) {
        coinHandler.volatilityAlert = sender.isOn
        
        let state = coinHandler.volatilityAlert ? 1 : 0
        
        let url = URL(string: "\(K.api)/alerts/volatility/\(coinHandler.deviceId)/\(state)")!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in}
        task.resume()
    }
    
    func didBuyPremium() {
        toggleBasedOnPremium()
        let alert = UIAlertController(title: "Thank you for buying Portfolio View Pro", message: "You can now enjoy unlimited price alerts, new features will be coming shortly!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func toggleBasedOnPremium(){
        if !coinHandler.premium{
            volatilityAlertSwitch.isEnabled = false
            volatilityAlertSwitch.isUserInteractionEnabled = false
            premiumCell.selectionStyle = .default
            premiumCellLabel.text = "Portfolio View Pro"
            premiumCellLearnMore.isHidden = false
        }else{
            volatilityAlertSwitch.isEnabled = true
            volatilityAlertSwitch.isUserInteractionEnabled = true
            appearanceSegmentedControl.isEnabled = true
            premiumCell.selectionStyle = .none
            premiumCell.accessoryType = .none
            premiumCellLabel.text = "Pro purchased!"
            premiumCellLearnMore.isHidden = true
        }
    }
    
    @IBAction func customizePressed(_ sender: Any) {
        performSegue(withIdentifier: "goToCustomize", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToCurrencySettings"){
            let destinationVC = segue.destination as! CurrencySettingsVC
            destinationVC.coinHandler = coinHandler
            if sender as! Int == 1{
                destinationVC.isSecondaryCurrency = true
            }else{
                destinationVC.isSecondaryCurrency = false
            }
        }
        else if (segue.identifier == "goToSupport"){
            let destinationVC = segue.destination as! SupportVC
            switch sender! as! Int{
            case 2:
                destinationVC.url = "https://portfolio-view-website.herokuapp.com/support"
            case 3:
                destinationVC.url = "https://portfolio-view-website.herokuapp.com/report-bug"
            case 4:
                destinationVC.url = "https://portfolio-view-website.herokuapp.com/suggest-feature"
            default:
                destinationVC.url = "https://portfolio-view-website.herokuapp.com/support"
            }
        }
        else if (segue.identifier == "goToPremium"){
            let destinationVC = segue.destination as! PremiumVC
            destinationVC.coinHandler = coinHandler
            destinationVC.delegate = self
        }
        else if (segue.identifier == "goToEnabledCoins"){
            let destinationVC = segue.destination as! EditEnabledCoinsVC
            destinationVC.coinHandler = coinHandler
        }
        else if segue.identifier == "goToCustomize"{
            let destinationVC = segue.destination as! CustomizeVC
            destinationVC.coinHandler = coinHandler
        }
    }
    
    @IBAction func appearanceToggled(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            coinHandler.appearance = "dark"
            overrideUserInterfaceStyle = .dark
            self.navigationController?.overrideUserInterfaceStyle = .dark
        case 1:
            coinHandler.appearance = "light"
            overrideUserInterfaceStyle = .light
            self.navigationController?.overrideUserInterfaceStyle = .light
        default:
            coinHandler.appearance = "auto"
            overrideUserInterfaceStyle = .unspecified
            self.navigationController?.overrideUserInterfaceStyle = .unspecified
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coinHandler.sortTypeNames.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        coinHandler.preferredSortType = coinHandler.sortTypeIds[row]
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            if (!promoVisable){
            
                return 3
            }else{
                if (showDeviceId){
                    return 5
                }
                return 4
            }
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 1
        case 4:
            return 5
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if indexPath.row == 0{
                performSegue(withIdentifier: "goToEnabledCoins", sender: self)
            }
            else if indexPath.row == 1{
                performSegue(withIdentifier: "goToCurrencySettings", sender: 0)
            }
            else if indexPath.row == 2{
                performSegue(withIdentifier: "goToCurrencySettings", sender: 1)
            }
            else if indexPath.row == 3{
                guard let promoUrl = URL(string: promoUrl)
                        else { fatalError("Expected a valid URL") }
                    UIApplication.shared.open(promoUrl, options: [:], completionHandler: nil)
            }
        }
        else if indexPath.section == 4 {
            if indexPath.row == 0{
                if (!coinHandler.premium){
                    performSegue(withIdentifier: "goToPremium", sender: self)
                }
                
            }
            else if indexPath.row == 1{
                guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1540033839?action=write-review")
                        else { fatalError("Expected a valid URL") }
                    UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
            }
            else{
                performSegue(withIdentifier: "goToSupport", sender: indexPath.row)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(coinHandler.sortTypeNames)[row]
    }
    
    func fetchPromo(){
        let url = URL(string: "\(K.api)/promo/")!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {return}
            let decoder = JSONDecoder()
            do{
                let promoModel = try decoder.decode(PromoModel.self, from: data)
                if promoModel.url != ""{
                    DispatchQueue.main.async {
                        if (promoModel.showDeviceId){
                            self.showDeviceId = true
                            self.deviceIdCell.isHidden = false
                        }
                        self.promoCell.isHidden = false
                        self.promoVisable = true
                        self.promoLabel.text = promoModel.title
                        self.promoUrl = promoModel.url
                        self.tableView.reloadData()
                    }
                }
            }catch{}
        }
        task.resume()
    }
}

struct PromoModel: Decodable{
    let title: String
    let url: String
    let showDeviceId: Bool
}
