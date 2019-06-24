//
//  DetailViewController.swift
//  Project 7
//
//  Created by Richard Worrell on 22/06/2019.
//  Copyright © 2019 Richard Worrell. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    var webView: WKWebView!
    var detailItem: Petition?
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let detailItem = detailItem else { return }
        
        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style> body { font-size: 100%; } </style>
        </head>
        <h2>
        \(detailItem.name)
        </h2>
        <body>
        \(detailItem.description)
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
        
    }
}
