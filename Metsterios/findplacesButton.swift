//
//  SubmitButton.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

class findplacesButton: UIButton {
    
    let image = UIImage(named: "findplaces") as UIImage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.setImage(image, forState: .Normal)
        super.layer.cornerRadius = 5
        super.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}