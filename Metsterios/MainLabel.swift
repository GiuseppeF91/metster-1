//
//  MainLabel.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

class MainLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        super.layer.cornerRadius = 5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}