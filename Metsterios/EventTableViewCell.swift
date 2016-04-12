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
    var foodImage : UIImageView?
    
    required init(coder aDecorder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        foodImage = UIImageView()
        foodImage?.frame = CGRectMake(screenWidth-95, 0, 95, 95)
        contentView.addSubview(foodImage!)
      
        eventNameLabel = UILabel()
        eventNameLabel.frame = CGRectMake(2, 0, screenWidth-100, 30)
        eventNameLabel.textColor = darkBlue
        eventNameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        contentView.addSubview(eventNameLabel)
        
        eventDateLabel = UILabel()
        eventDateLabel.frame = CGRectMake(2, 30, screenWidth/3, 25)
        eventDateLabel.textColor = darkBlue
        contentView.addSubview(eventDateLabel)
        
        eventTimeLabel = UILabel()
        eventTimeLabel.frame = CGRectMake(screenWidth/3, 30, screenWidth/3, 25)
        eventTimeLabel.textColor = darkBlue
        contentView.addSubview(eventTimeLabel)
        
        eventPlaceLabel = UILabel()
        eventPlaceLabel.frame = CGRectMake(2, 55, screenWidth-100, 25)
        eventPlaceLabel.textColor = darkBlue
        contentView.addSubview(eventPlaceLabel)
        
        eventAddressLabel = UILabel()
        eventAddressLabel.frame = CGRectMake(2, 80, screenWidth-100, 20)
        eventAddressLabel.textColor = darkBlue
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
