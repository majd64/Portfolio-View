//
//  ViewController.swift
//  Portfolio View
//
//  Created by Majd Hailat on 2020-11-11.
//  Copyright © 2020 Majd Hailat. All rights reserved.
//

import UIKit
import WebKit
class SupportVC: UIViewController, WKUIDelegate {
    var webView: WKWebView!
    var url: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string: url ?? "https://www.portfolioview.ca/support")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
}
