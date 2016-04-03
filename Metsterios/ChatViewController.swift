//
//  ChatViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

class ChatViewController: BaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Chat"
        navBar.items = [navigationItem]
        self.view.addSubview(navBar)
    }
}