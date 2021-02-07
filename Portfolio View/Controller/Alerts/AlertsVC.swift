//
//  alertsVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-11-21.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class AlertsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, DidBuyPremium, AlertAdded{
    private let defaults = UserDefaults.standard
    private var alerts: [AlertModel] = []
    var coinHandler: CoinHandler!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var shouldGoStraighToAddAlertVC = false
    var coinToAddAlertFor: Coin?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (!addButton.isEnabled){
            return 1
        }
        if (alerts.count > 0){
            return alerts.count + 1
        }
        return alerts.count
    }
    
    func didBuyPremium() {
        let alert = UIAlertController(title: "Thank you for buying Portfolio View Pro", message: "You can now enjoy unlimited price alerts, new features will be coming shortly!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (!addButton.isEnabled){
            let cell = UITableViewCell()
            cell.textLabel!.textColor = UIColor.systemRed
            cell.textLabel!.text = "No interenet connection"
            cell.selectionStyle = .none
            return cell
        }
        else if (indexPath.row == alerts.count && alerts.count != 0){
            let cell = UITableViewCell()
            cell.textLabel!.textColor = UIColor.systemRed
            cell.textLabel!.text = "Delete all"
            return cell
        }
        let alert = alerts[indexPath.row]
        let coin: Coin? = coinHandler.getCoin(id: alert.coinID)
        let cell = tableView.dequeueReusableCell(withIdentifier: "alertCell") as! AlertCell
        
        cell.priceLabel.text = "\(K.convertToCoinPrice(alert.price, currency: alert.currencyID)) \(alert.currencyID.uppercased())"
        cell.iconImage.image = coin?.getImage()
        cell.tickerLabel.text = alert.coinTicker?.uppercased() ?? (coin?.getSymbol().uppercased() ?? alert.coinID)
        if (alert.above){
            cell.crossesLabel.text = "Crosses above"
            cell.crossesLabel.textColor = UIColor.systemGreen
        }else{
            cell.crossesLabel.text = "Crosses below"
            cell.crossesLabel.textColor = UIColor.systemRed
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == alerts.count && addButton.isEnabled{
            let alert = UIAlertController(title: nil, message: "Are you sure you want to delete all the price alerts?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete all", style: .default, handler:  { action in
                DispatchQueue.main.async {
                    let url = URL(string: "\(K.api)/alerts/delete/\(self.coinHandler.deviceId)")!
                    var request = URLRequest(url: url)
                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    request.httpMethod = "POST"
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        self.fetchAlerts()
                    }
                    task.resume()
                }
            }))
            self.present(alert, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)

    }
    @IBOutlet weak var alertsTableView: UITableView!
    
    override func viewDidLoad() {
        alertsTableView.delegate = self
        alertsTableView.dataSource = self
        alertsTableView.register(UINib(nibName: "AlertCell", bundle: nil), forCellReuseIdentifier: "alertCell")
        super.viewDidLoad()
    }
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        if (canAddAlert()){
            performSegue(withIdentifier: "goToChooseCoinForAlertVC", sender: self)
        }
    }
    
    func canAddAlert() -> Bool{
        if (alerts.count >= 1 && !coinHandler.premium){
            let alert = UIAlertController(title: "Purchase Pro", message: "You can only add 1 alert with the free version of Portfolio View. Upgrade to pro to add an unlimited number of alerts", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "View Pro", style: .default, handler:  { action in
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "goToPremium", sender: self)
                }
            }))
            self.present(alert, animated: true)
            return false
        }
        return true
    }
    
    func alertAdded() {
        print("alert added")
        fetchAlerts()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if (shouldGoStraighToAddAlertVC && coinToAddAlertFor != nil){
            if (canAddAlert()){
                performSegue(withIdentifier: "goToAddAlert", sender: coinToAddAlertFor!)
            }
        }
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
            } else if settings.authorizationStatus == .denied {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Notifications disabled", message: "To use alerts you must enable push notifications for Portfolio View", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
                        if let bundle = Bundle.main.bundleIdentifier,
                            let settings = URL(string: UIApplication.openSettingsURLString + bundle) {
                            if UIApplication.shared.canOpenURL(settings) {
                                UIApplication.shared.open(settings)
                            }
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
    
                    self.present(alert, animated: true)
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchAlerts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChooseCoinForAlertVC"{
            let destinationVC = segue.destination as! ChooseCoinForAlertVC
            destinationVC.coinHandler = coinHandler
        }
        else if (segue.identifier == "goToPremium"){
            let destinationVC = segue.destination as! PremiumVC
            destinationVC.coinHandler = coinHandler
            destinationVC.delegate = self
        }
        if segue.identifier == "goToAddAlert"{
            let destinationVC = segue.destination as! AddAlertVC
            destinationVC.coin = sender as? Coin
            destinationVC.coinHandler = coinHandler
            destinationVC.delegate = self
            shouldGoStraighToAddAlertVC = false
            coinToAddAlertFor = nil
        }
    }
    
    func fetchAlerts(){
        let url = URL(string: "\(K.api)/alerts/\(coinHandler.deviceId)")!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if ((error) != nil){
                DispatchQueue.main.async {
                    self.addButton.isEnabled = false
                    self.alertsTableView.reloadData()
                }
            }
            guard let data = data else {return}
            let decoder = JSONDecoder()
            do{
                let alertsModel = try decoder.decode(AlertsModel.self, from: data)
                self.alerts = alertsModel.alerts
                self.alerts.reverse()
                DispatchQueue.main.async {
                    self.addButton.isEnabled = true
                    self.alertsTableView.reloadData()
                }
            }catch{
                print("error")
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (!addButton.isEnabled){
            return
        }
        if editingStyle == .delete {
            let url = URL(string: "\(K.api)/alerts/delete/\(coinHandler.deviceId)")!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let parameters: [String: Any] = [
                "alert_id": alerts[indexPath.row]._id,
            ]
            request.httpBody = parameters.percentEncoded()

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                self.fetchAlerts()
            }
            task.resume()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if (!addButton.isEnabled || indexPath.row == alerts.count){
            return .none
        }else{
            return .delete
        }
       
    }
}

struct AlertsModel: Decodable{
    let alerts:[AlertModel]
}

struct AlertModel: Decodable{
    let _id: String
    let coinID: String
    let coinTicker: String?
    let currencyID: String
    let price: Double
    let above: Bool
}
