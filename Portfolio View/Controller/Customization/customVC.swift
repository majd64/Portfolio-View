//
//  ViewController.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2021-01-21.
//  Copyright © 2021 Majd Hailat. All rights reserved.
//

import UIKit

@available(iOS 14.0, *)
class CustomVC: UIViewController, UIColorPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var cellView: UIView!
    var coinHandler: CoinHandler?
    let imagePickerController = UIImagePickerController()
    let picker = UIColorPickerViewController()
    
    @IBOutlet weak var selectColorButton: UIButton!
    @IBOutlet weak var selectBgColorButton: UIButton!
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var cellColor: UIColor!
    var alpha: Double!
    
    var imageType: String!
    var customImageColor: UIColor?
    var customImage: UIImage?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var bgImage: UIImageView!
    
    var settingColorFor: String = "" //cell, bg
    
    
    override func viewDidLoad() {
        picker.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        
        cellView.layer.cornerRadius = 15
        selectColorButton.layer.cornerRadius = 15
        selectBgColorButton.layer.cornerRadius = 15
        uploadImageButton.layer.cornerRadius = 15
        resetButton.layer.cornerRadius = 15
        
        selectColorButton.tag = 0
        selectBgColorButton.tag = 1
        
        saveButton.layer.cornerRadius = 10
        
        initFromCH()
        cellColChanged()
        imageChanged()
        
        super.viewDidLoad()
    }
    
    func initFromCH(){
        if (self.traitCollection.userInterfaceStyle == .dark){
            imageType = coinHandler?.darkImageType
            
            cellColor = K.hexStringToUIColor(hex: coinHandler!.darkCellColor)
            alpha = coinHandler?.darkCellColorAlpha
            
            if let customColor = coinHandler?.darkCustomImageColor{
                customImageColor = K.hexStringToUIColor(hex: customColor)
            }
            
            if let image = coinHandler?.darkCustomImage{
                customImage = image
            }
        }else{
            imageType = coinHandler?.lightImageType
            
            cellColor = K.hexStringToUIColor(hex: coinHandler!.lightCellColor)
            alpha = coinHandler?.lightCellColorAlpha
            
            if let customColor = coinHandler?.lightCustomImageColor{
                customImageColor = K.hexStringToUIColor(hex: customColor)
            }
            
            if let image = coinHandler?.lightCustomImage{
                customImage = image
            }
        }
        
        imageChanged()
        cellColChanged()
    }
    
    @IBAction func setColorButtonPressed(_ sender: UIButton) {
        if sender.tag == 0{
            settingColorFor = "cell"
            picker.supportsAlpha = true
        }else if sender.tag == 1{
            settingColorFor = "bg"
            picker.supportsAlpha = false
        }
        self.present(picker, animated: true, completion: nil)
    }
    
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        if settingColorFor == "cell"{
            cellColor = viewController.selectedColor
            alpha = Double(viewController.selectedColor.rgba.alpha)
            cellColChanged()
        }
        else if settingColorFor == "bg"{
            imageType = "customImageColor"
            customImageColor = viewController.selectedColor
            imageChanged()
        }
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        if settingColorFor == "cell"{
            cellColor = viewController.selectedColor
            alpha = Double(viewController.selectedColor.rgba.alpha)
            cellColChanged()
        }
        else if settingColorFor == "bg"{
            imageType = "customImageColor"
            customImageColor = viewController.selectedColor
            imageChanged()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        self.imageType = "customImage"
        self.customImage = image
        imageChanged()
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func cellColChanged(){
        picker.selectedColor = cellColor.withAlphaComponent(CGFloat(alpha))
        
        cellView.backgroundColor = cellColor.withAlphaComponent(CGFloat(alpha))
        saveButton.setTitle("Save", for: .normal)
        if cellColor.isLight(){
            nameLabel.textColor = UIColor.black
            tickerLabel.textColor = UIColor.black
            priceLabel.textColor = UIColor.black
            balanceLabel.textColor = UIColor.black
            changeLabel.textColor = UIColor.black
            valueLabel.textColor = UIColor.black
        }else{
            nameLabel.textColor = UIColor.white
            tickerLabel.textColor = UIColor.white
            priceLabel.textColor = UIColor.white
            balanceLabel.textColor = UIColor.white
            changeLabel.textColor = UIColor.white
            valueLabel.textColor = UIColor.white
        }
    }
    
    func imageChanged(){
        bgImage.alpha = 1
        if (imageType == "preset"){
            bgImage.image = UIImage(named: "Background")
        }
        else if imageType == "customImageColor"{
            view.backgroundColor = customImageColor
            bgImage.alpha = 0
        }
        else if imageType == "customImage"{
            bgImage.image = customImage
        }
    }
    
    @IBAction func setCustomBackgroundPressed(_ sender: Any) {
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func resetPressed(_ sender: Any) {
        imageType = "preset"
        
        
        let alert = UIAlertController(title: nil, message: "Are you sure you want to restore to the default settings", preferredStyle: .alert)
        
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:  { action in
            self.coinHandler?.darkImageType = "preset"
            self.coinHandler?.lightImageType = "preset"
            self.coinHandler?.darkCellColor = self.coinHandler!.defaultDarkCellColor
            self.coinHandler?.lightCellColor = self.coinHandler!.defaultLightCellColor
            self.coinHandler?.darkCellColorAlpha = self.coinHandler!.defaultDarkCellColorAlpha
            self.coinHandler?.lightCellColorAlpha = self.coinHandler!.defaultLightCellColorAlpha
            self.initFromCH()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:  nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Select the style you want to set this for", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Light", style: .default, handler:  { action in
            self.coinHandler?.lightCellColor = K.hexStringFromColor(color: self.cellColor)
            self.coinHandler?.lightCellColorAlpha = self.alpha
            
            self.coinHandler?.lightImageType = self.imageType
            self.coinHandler?.lightCustomImage = self.customImage
            
            if let col = self.customImageColor{
                self.coinHandler?.lightCustomImageColor = K.hexStringFromColor(color: col)
            }
        }))
        alert.addAction(UIAlertAction(title: "Dark", style: .default, handler:  { action in
            self.coinHandler?.darkCellColor = K.hexStringFromColor(color: self.cellColor)
            self.coinHandler?.darkCellColorAlpha = self.alpha
            
            self.coinHandler?.darkImageType = self.imageType
            self.coinHandler?.darkCustomImage = self.customImage
            
            if let col = self.customImageColor{
                self.coinHandler?.darkCustomImageColor = K.hexStringFromColor(color: col)
            }
        }))
        alert.addAction(UIAlertAction(title: "Both", style: .default, handler:  { action in
            self.coinHandler?.lightCellColor = K.hexStringFromColor(color: self.cellColor)
            self.coinHandler?.lightCellColorAlpha = self.alpha
            self.coinHandler?.darkCellColor = K.hexStringFromColor(color: self.cellColor)
            self.coinHandler?.darkCellColorAlpha = self.alpha
            
            self.coinHandler?.lightImageType = self.imageType
            self.coinHandler?.darkImageType = self.imageType
            self.coinHandler?.lightCustomImage = self.customImage
            self.coinHandler?.darkCustomImage = self.customImage
            
            if let col = self.customImageColor{
                self.coinHandler?.lightCustomImageColor = K.hexStringFromColor(color: col)
                self.coinHandler?.darkCustomImageColor = K.hexStringFromColor(color: col)
            }
        }))
        self.present(alert, animated: true)
     }
}
