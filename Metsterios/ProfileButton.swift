//
//  ProfileButton.swift
//  Metsterios
//
//  Created by Chelsea Green on 4/6/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

class ProfileButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        super.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        super.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        super.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        super.layer.borderWidth = 1
        super.layer.borderColor = UIColor.lightGrayColor().CGColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
