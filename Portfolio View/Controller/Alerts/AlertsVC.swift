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
        let cell = tableView.dequeueReusableCell(withIdentifier: "alertCell") as! AlertCell
        cell.priceLabel.text = String(format: "%.2f", alert.price)
        cell.iconImage.image = UIImage(named: alert.coinID)
        cell.tickerLabel.text = coinHandler.getCoin(id: alert.coinID)?.getSymbol()
        if (alert.above){
            cell.crossesLabel.text = "Crooses above"
        }else{
            cell.crossesLabel.text = "Crooses below"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    @IBOutlet weak var alertsTableView: UITableView!
    
    override func viewDidLoad() {
        alertsTableView.delegate = self
        alertsTableView.dataSource = self
        alertsTableView.register(UINib(nibName: "AlertCell", bundle: nil), forCellReuseIdentifier: "alertCell")
        fetchAlerts()

        super.viewDidLoad()
    }
    
    func fetchAlerts(){
        guard let token = defaults.string(forKey: "deviceToken") else{
            fatalError("Device token not found")
        }
        let url = URL(string: "https://www.portfolioview.ca/alerts/\(token)")!

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
}

struct AlertsModel: Decodable{
    let alerts:[AlertModel]
}

struct AlertModel: Decodable{
    let coinID: String
    let price: Double
    let above: Bool
}
