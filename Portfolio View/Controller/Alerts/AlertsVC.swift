//
//  alertsVC.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-11-21.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit

class AlertsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let defaults = UserDefaults.standard
    private var alerts: [AlertModel] = []
    var coinHandler: CoinHandler!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alerts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let alert = alerts[indexPath.row]
        print(alert)
        let coin: Coin? = coinHandler.getCoin(id: alert.coinID)
        let cell = tableView.dequeueReusableCell(withIdentifier: "alertCell") as! AlertCell
        cell.priceLabel.text = K.convertToMoneyFormat(alert.price, currency: "usd")
        cell.iconImage.image = coin?.getImage()
        cell.tickerLabel.text = coin?.getSymbol().uppercased()
        if (alert.above){
            cell.crossesLabel.text = "Crosses above"
        }else{
            cell.crossesLabel.text = "Crosses below"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    @IBOutlet weak var alertsTableView: UITableView!
    
    override func viewDidLoad() {
        alertsTableView.delegate = self
        alertsTableView.dataSource = self
        alertsTableView.register(UINib(nibName: "AlertCell", bundle: nil), forCellReuseIdentifier: "alertCell")
        

        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchAlerts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChooseCoinForAlertVC"{
            let destinationVC = segue.destination as! ChooseCoinForAlertVC
            destinationVC.coinHandler = coinHandler
        }
    }
    
    func fetchAlerts(){
        guard let token = defaults.string(forKey: "deviceToken") else{
            fatalError("Device token not found")
        }
        let url = URL(string: "\(K.api)/alerts/\(token)")!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let decoder = JSONDecoder()
            do{
                print("IN DO")
                let alertsModel = try decoder.decode(AlertsModel.self, from: data)
                self.alerts = alertsModel.alerts
                print("MODEL: \(alertsModel)")
                print(self.alerts)
                
                
                DispatchQueue.main.async {
                    self.alertsTableView.reloadData()
                }
                
            }catch{
                print("error")
            }
            
        }

        task.resume()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let url = URL(string: "\(K.api)/alerts/delete/\(coinHandler.deviceToken)")!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let parameters: [String: Any] = [
                "alert_id": alerts[indexPath.row]._id,
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
            fetchAlerts()
        }
    }
}

struct AlertsModel: Decodable{
    let alerts:[AlertModel]
}

struct AlertModel: Decodable{
    let _id: String
    let coinID: String
    let price: Double
    let above: Bool
}
