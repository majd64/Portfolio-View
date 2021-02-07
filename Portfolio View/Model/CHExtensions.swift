//
//  CHExtensions.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-12-21.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import Foundation
import UIKit

extension CoinHandler{
    var preferredCurrency: String{
        get{
            if let rate = defaults.string(forKey: "preferredCurrency"){
                return rate
            }
            defaults.set("usd", forKey: "preferredCurrency")
            return "usd"
        }set{
            defaults.set(newValue, forKey: "preferredCurrency")
            fetchCoinData(lightRefresh: false)
        }
    }
    
    var secondaryCurrency: String{
        get{
            if let rate = defaults.string(forKey: "secondaryCurrency"){
                return rate
            }
            defaults.set("btc", forKey: "secondaryCurrency")
            return "usd"
        }set{
            defaults.set(newValue, forKey: "secondaryCurrency")
            fetchCoinData(lightRefresh: false)
        }
    }
    
    var enabledCoinIdsArray: [String]{
        get{
            if let enabledCoins = defaults.stringArray(forKey: "enabledCoins"){
                return enabledCoins
            }
            defaults.setValue(["bitcoin", "ethereum", "tether", "polkadot", "ripple", "cardano", "litecoin", "bitcoin-cash", "chainlink", "stellar", "binancecoin", "usd-coin", "wrapped-bitcoin", "bitcoin-cash-sv", "monero", "eos", "aave", "cosmos", "tron", "tezos", "nem", "havven", "theta-token", "crypto-com-chain", "vechain"], forKey: "enabledCoins")
            return defaults.stringArray(forKey: "enabledCoins")!
        }
    }
    
    var premium: Bool{
        get{
            return defaults.bool(forKey: "premium")//PLEASE PLEASE PLEASE DONT FORGET TO TOGGLE THIS BACK
        }set{
            defaults.set(newValue, forKey: "premium")
        }
    }
    
    var darkCellColor: String{
        get{
            if let col = defaults.string(forKey: "darkCellColor"){
                return col
            }else{
                defaults.setValue(defaultDarkCellColor, forKey: "darkCellColor")
                return defaultDarkCellColor
            }
        }set{
            defaults.setValue(newValue, forKey: "darkCellColor")
        }
    }
    var darkCellColorAlpha: Double{
        get{
            if (!defaults.bool(forKey: "didInitAlpha")){
                defaults.setValue(defaultDarkCellColorAlpha, forKey: "darkCellColorAlpha")
                defaults.setValue(defaultLightCellColorAlpha, forKey: "lightCellColorAlpha")
                defaults.setValue(true, forKey: "didInitAlpha")
            }
            return defaults.double(forKey: "darkCellColorAlpha")
        }set{
            defaults.setValue(newValue, forKey: "darkCellColorAlpha")
        }
    }
    
    var lightCellColor: String{
        get{
            if let col = defaults.string(forKey: "lightCellColor"){
                return col
            }else{
                defaults.setValue(defaultLightCellColor, forKey: "lightCellColor")
                return defaultLightCellColor
            }
        }set{
            defaults.setValue(newValue, forKey: "lightCellColor")
        }
    }
    
    var lightCellColorAlpha: Double{
        get{
            if (!defaults.bool(forKey: "didInitAlpha")){
                defaults.setValue(defaultDarkCellColorAlpha, forKey: "darkCellColorAlpha")
                defaults.setValue(defaultLightCellColorAlpha, forKey: "lightCellColorAlpha")
                defaults.setValue(true, forKey: "didInitAlpha")
            }
            return defaults.double(forKey: "lightCellColorAlpha")
        }set{
            defaults.setValue(newValue, forKey: "lightCellColorAlpha")
        }
    }
    
    
    //IMAGE STARTS HERE //////////////////////////////////////////////////////////////////////////
    var lightCustomImage: UIImage?{
        get{
            if let data = defaults.data(forKey: "lightCustomImage"){
                return UIImage(data: data)
            }
            return nil
        }set{
            if let img = newValue{
                defaults.setValue(img.pngData(), forKey: "lightCustomImage")
            }
        }
    }
    
    
    var darkCustomImage: UIImage?{
        get{
            if let data = defaults.data(forKey: "darkCustomImage"){
                return UIImage(data: data)
            }
            return nil
        }set{
            if let img = newValue{
                defaults.setValue(img.pngData(), forKey: "darkCustomImage")
            }
        }
    }
    
    var darkCustomImageColor: String?{
        get{
            if let col = defaults.string(forKey: "darkCustomImageColor"){
                return col
            }
            return nil
        }set{
            defaults.setValue(newValue, forKey: "darkCustomImageColor")
        }
    }
    
    var lightCustomImageColor: String?{
        get{
            if let col = defaults.string(forKey: "lightCustomImageColor"){
                return col
            }
            return nil
        }set{
            defaults.setValue(newValue, forKey: "lightCustomImageColor")
        }
    }
    
    var darkImageType: String{//preset, customImage, customImageColor
        get{
            if let type = defaults.string(forKey: "darkImageType"){
                return type
            }
            defaults.setValue("preset", forKey: "darkImageType")
            return "preset"
        }set{
            defaults.setValue(newValue, forKey: "darkImageType")
        }
    }
    
    var lightImageType: String{//preset, customImage, customImageColor
        get{
            if let type = defaults.string(forKey: "lightImageType"){
                return type
            }
            defaults.setValue("preset", forKey: "lightImageType")
            return "preset"
        }set{
            defaults.setValue(newValue, forKey: "lightImageType")
        }
    }
    //IMAGE ENDS HERE //////////////////////////////////////////////////////////////////////////

 
    
    
    
    var volatilityAlert: Bool{
        get{
            return defaults.bool(forKey: "volatilityAlertsEnabled")
        }set{
            defaults.setValue(newValue, forKey: "volatilityAlertsEnabled")
        }
       
    }
    
    var deviceId: String{
        get{
            guard let deviceId = defaults.string(forKey: "deviceId") else{
                fatalError("no device token")
            }
            return deviceId
        }
    }
    
    var appearance: String{
        get{
            if let appearance = defaults.string(forKey: "appearance"){
                return appearance
            }
            defaults.set("light", forKey: "appearance")
            return "light"
        }set{
            defaults.set(newValue, forKey: "appearance")
        }
    }
    
    var preferredSortType: String{
        get{
            if let sortType = defaults.string(forKey: "preferredSortType"){
                return sortType
            }
            defaults.set("balanceValue", forKey: "preferredSortType")
            return "balanceValue"
        }set{
            if sortTypeIds.contains(newValue){
                defaults.set(newValue, forKey: "preferredSortType")
                sortCoins(sender: "pref sort changed")
            }
        }
    }
}



