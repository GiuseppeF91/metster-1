//
//  ProfileButton.swift
//  Metsterios
//
//  Created by Chelsea Green on 4/6/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

class LogoutButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        super.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        super.backgroundColor = UIColor(red: 0.9569, green: 0.2392, blue: 0, alpha: 1.0)
        super.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        super.layer.borderWidth = 1
        super.layer.cornerRadius = 5
        super.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}