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
        super.init(frame: frame)
        super.layer.borderWidth = 1
        super.layer.cornerRadius = 2
        super.layer.borderColor = UIColor.lightGrayColor().CGColor
        super.setTitleColor(lightBlue, forState: .Selected)
        super.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        super.backgroundColor = darkBlue
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
