//
//  SettingsVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-10-20.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit
import StoreKit

class SettingsVC: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    var coinHandler: CoinHandler!
    @IBOutlet weak var sortTypePickerView: UIPickerView!
//    @IBOutlet weak var coloredCellsToggle: UISwitch!
    private let defaults = UserDefaults.standard
    @IBOutlet weak var appearanceSegmentedControl: UISegmentedControl!
    @IBOutlet weak var selectedCurrencyLabel: UILabel!
    @IBOutlet weak var selectedSecondaryCurrencyLabel: UILabel!
    
    override func viewDidLoad() {
        sortTypePickerView.delegate = self
        sortTypePickerView.dataSource = self
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        if coinHandler.appearance == "dark"{
            overrideUserInterfaceStyle = .dark
        }
        else if coinHandler.appearance == "light"{
            overrideUserInterfaceStyle = .light
        }else{
            overrideUserInterfaceStyle = .unspecified
        }
        
//        let coloredCellsEnabled = defaults.bool(forKey: "coloredCells")
//        if coloredCellsEnabled{
//            coloredCellsToggle.isOn = true
//        }else{
//            coloredCellsToggle.isOn = false
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToCurrencySettings"){
            let destinationVC = segue.destination as! CurrencySettingsVC
            destinationVC.coinHandler = coinHandler
            let s = sender as! Int
            if s == 0{
                destinationVC.isSecondaryCurrency = false
            }
            else if s == 1{
                destinationVC.isSecondaryCurrency = true
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
       
    }
    
//    @IBAction func coloredCellTogglePressed(_ sender: Any) {
//        let toggle = sender as! UISwitch
//        defaults.setValue(toggle.isOn, forKey: "coloredCells")
//        coinHandler.refresh()
//    }
    
    @IBAction func appearanceToggled(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            coinHandler.appearance = "dark"
        case 1:
            coinHandler.appearance = "light"
        case 2:
            coinHandler.appearance = "auto"
        default:
            coinHandler.appearance = "auto"
        }
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
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 2
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 5
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if indexPath.row == 0{
                performSegue(withIdentifier: "goToCurrencySettings", sender: 0)
            }
            else if indexPath.row == 1{
                performSegue(withIdentifier: "goToCurrencySettings", sender: 1)
            }
        }
        else if indexPath.section == 3 {
            if indexPath.row == 0{
                guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1540033839?action=write-review")
                        else { fatalError("Expected a valid URL") }
                    UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
            }
            else if indexPath.row == 1{
                guard let instagramURL = URL(string: "https://www.instagram.com/eagercrypto/?hl=en")
                        else { fatalError("Expected a valid URL") }
                    UIApplication.shared.open(instagramURL, options: [:], completionHandler: nil)
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
}
