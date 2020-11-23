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
    @IBOutlet weak var currencySettingsLabel: UILabel!
    @IBOutlet weak var sortTypePickerView: UIPickerView!
    @IBOutlet weak var coloredCellsToggle: UISwitch!
    private let defaults = UserDefaults.standard

    override func viewDidLoad() {
        sortTypePickerView.delegate = self
        sortTypePickerView.dataSource = self
        currencySettingsLabel.text = coinHandler.getPreferredCurrency()?.getSymbol()
        sortTypePickerView.selectRow(coinHandler.sortTypeIds.firstIndex(of: coinHandler.getPreferredSortTypeId())!, inComponent: 0, animated: false)
        let coloredCellsEnabled = defaults.bool(forKey: "coloredCells")
        if coloredCellsEnabled{
            coloredCellsToggle.isOn = true
        }else{
            coloredCellsToggle.isOn = false
        }
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToCurrencySettings"){
            let destinationVC = segue.destination as! CurrencySettingsVC
            destinationVC.coinHandler = coinHandler
        }
        else if (segue.identifier == "goToSupport"){
            let destinationVC = segue.destination as! SupportVC
            switch sender! as! Int{
            case 1:
                destinationVC.url = "https://portfolio-view-website.herokuapp.com/report-bug"
            case 2:
                destinationVC.url = "https://portfolio-view-website.herokuapp.com/suggest-feature"
            default:
                destinationVC.url = "https://portfolio-view-website.herokuapp.com/support"
            }
        }
        else if (segue.identifier == "goToAlerts"){
            let destinationVC = segue.destination as! AlertsVC
            destinationVC.coinHandler = coinHandler
        }
    }
    
    @IBAction func coloredCellTogglePressed(_ sender: Any) {
        let toggle = sender as! UISwitch
        defaults.setValue(toggle.isOn, forKey: "coloredCells")
        coinHandler.refresh()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coinHandler.sortTypeNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        coinHandler.setPreferredSortTypeId(to: coinHandler.sortTypeIds[row])
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 5){
            return 3
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 4 {
            guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1540033839?action=write-review")
                    else { fatalError("Expected a valid URL") }
                UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
        else if indexPath.section == 5{
            performSegue(withIdentifier: "goToSupport", sender: indexPath.row)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(coinHandler.sortTypeNames)[row]
    }
}
