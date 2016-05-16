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
    
    var eventHostLabel : UILabel!
    var eventDescpLabel : UILabel!
    var eventNameLabel : UILabel!
    var eventTimeLabel : UILabel!
    var eventDateLabel : UILabel!
    var userImage : UIImageView?
    var slideImage : UIImageView?
    var chatButton : UIButton?
    
    required init(coder aDecorder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        userImage = UIImageView()
        userImage?.frame = CGRectMake(2, 10, 85, 85)
        userImage!.layer.cornerRadius = 8.0
        userImage!.clipsToBounds = true
        contentView.addSubview(userImage!)
      
        eventNameLabel = UILabel()
        eventNameLabel.frame = CGRectMake(90, 11, screenWidth-100, 30)
        eventNameLabel.textColor = UIColor(red: 0.81, green: 0.71, blue: 0.23, alpha: 1)
        eventNameLabel.font = UIFont(name: "GILLSANSCE-ROMAN-Bold", size: 35)
        contentView.addSubview(eventNameLabel)
        
        eventDateLabel = UILabel()
        eventDateLabel.frame = CGRectMake(screenWidth-80, 11, screenWidth/3, 25)
        eventDateLabel.textColor = UIColor.grayColor()
        eventDateLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        contentView.addSubview(eventDateLabel)
        
        eventTimeLabel = UILabel()
        eventTimeLabel.frame = CGRectMake(screenWidth-80, 20, screenWidth/3, 25)
        eventTimeLabel.textColor = UIColor.grayColor()
        eventTimeLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        contentView.addSubview(eventTimeLabel)
        
        
        slideImage = UIImageView()
        slideImage?.frame = CGRectMake(screenWidth-80, 40, 25, 25)
        slideImage!.layer.cornerRadius = 8.0
        slideImage!.clipsToBounds = true
        contentView.addSubview(slideImage!)
        
        chatButton = UIButton()
        chatButton?.frame = CGRectMake(screenWidth-30, 40, 25, 25)
        contentView.addSubview(chatButton!)
        
        
        eventDescpLabel = UILabel()
        eventDescpLabel.frame = CGRectMake(90, 30, screenWidth-100, 25)
        eventDescpLabel.textColor = UIColor.grayColor()
        eventDescpLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        contentView.addSubview(eventDescpLabel)
        
        eventHostLabel = UILabel()
        eventHostLabel.frame = CGRectMake(90, 65, screenWidth-100, 20)
        eventHostLabel.textColor = UIColor.grayColor()
        eventHostLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        contentView.addSubview(eventHostLabel)
        
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
