//
//  EventTableViewCell.swift
//  Metsterios
//
//  Created by Chelsea Green on 4/10/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class EventTableViewCell: UITableViewCell {
    
    var eventPlaceLabel : UILabel!
    var eventAddressLabel : UILabel!
    var eventNameLabel : UILabel!
    var eventTimeLabel : UILabel!
    var eventDateLabel : UILabel!
    
    required init(coder aDecorder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        eventNameLabel = UILabel()
        eventNameLabel.frame = CGRectMake(2, 0, screenWidth-4, 30)
        eventNameLabel.textColor = UIColor.blueColor()
        eventNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        contentView.addSubview(eventNameLabel)
        
        eventDateLabel = UILabel()
        eventDateLabel.frame = CGRectMake(2, 30, screenWidth/3, 25)
        eventDateLabel.textColor = UIColor.blackColor()
        contentView.addSubview(eventDateLabel)
        
        eventTimeLabel = UILabel()
        eventTimeLabel.frame = CGRectMake(screenWidth/3, 30, screenWidth/3, 25)
        eventTimeLabel.textColor = UIColor.blackColor()
        contentView.addSubview(eventTimeLabel)
        
        eventPlaceLabel = UILabel()
        eventPlaceLabel.frame = CGRectMake(2, 55, screenWidth-4, 25)
        eventPlaceLabel.textColor = UIColor.blackColor()
        contentView.addSubview(eventPlaceLabel)
        
        eventAddressLabel = UILabel()
        eventAddressLabel.frame = CGRectMake(2, 80, screenWidth-4, 20)
        eventAddressLabel.textColor = UIColor.blackColor()
        eventAddressLabel.font = UIFont(name: "HelveticaNeue-Light", size: 15)
        contentView.addSubview(eventAddressLabel)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
