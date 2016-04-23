//
//  SelectionButton.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/30/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

class SelectionButton: UIButton {
    
    override init(frame: CGRect) {
        let bg = UIColor(red: 250, green: 250, blue: 250, alpha: 1)
        super.init(frame: frame)
        super.layer.borderWidth = 1
        super.layer.cornerRadius = 2
        super.layer.borderColor = lightBlue.CGColor
        super.setTitleColor(UIColor.blackColor(), forState: .Selected)
        super.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
        super.backgroundColor = bg

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
