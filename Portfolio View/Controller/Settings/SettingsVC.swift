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
        currencySettingsLabel.text = coinHandler.getPreferredExchangeRate()?.getSymbol()
        sortTypePickerView.delegate = self
        sortTypePickerView.dataSource = self
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
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    
    @IBAction func coloredCellTogglePressed(_ sender: Any) {
        
        let toggle = sender as! UISwitch

        defaults.setValue(toggle.isOn, forKey: "coloredCells")
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coinHandler.sortTypeNames.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 4 {
//            SKStoreReviewController.requestReview()
            guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1517180079?action=write-review")
                    else { fatalError("Expected a valid URL") }
                UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(coinHandler.sortTypeNames)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        coinHandler.setPreferredSortTypeId(to: coinHandler.sortTypeIds[row])
        
    }
    
  

}
