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

class MapviewTableViewCell: UITableViewCell {
    
    var itemdescp : UILabel!
    var itemline1seg3 : UILabel!
    var itemline1seg2 : UILabel!
    var itemline1seg1 : UILabel!
    var itemTitle : UILabel!
    var itemdetail : UILabel!
    var itemImage : UIImageView?
    var publishbutton : UIButton!
    var chatButton : UIButton?
    required init(coder aDecorder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        itemImage = UIImageView()
        itemImage?.frame = CGRectMake(2, 10, 85, 85)
        itemImage!.layer.cornerRadius = 8.0
        itemImage!.clipsToBounds = true
        contentView.addSubview(itemImage!)
        
        itemTitle = UILabel()
        itemTitle.frame = CGRectMake(90, 11, screenWidth-100, 30)
        itemTitle.textColor = UIColor(red: 0.81, green: 0.71, blue: 0.23, alpha: 1)
        itemTitle.font = UIFont(name: "GILLSANSCE-ROMAN-Bold", size: 35)
        contentView.addSubview(itemTitle)
        
        itemline1seg1 = UILabel() // rate
        itemline1seg1.frame = CGRectMake(90, 30, screenWidth-100, 25)
        itemline1seg1.textColor = UIColor.grayColor()
        itemline1seg1.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        contentView.addSubview(itemline1seg1)
        
        itemline1seg2 = UILabel()
        itemline1seg2.frame = CGRectMake(200, 30, screenWidth-100, 25)
        itemline1seg2.textColor = UIColor.grayColor()
        itemline1seg2.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        contentView.addSubview(itemline1seg2)
        
        itemline1seg3 = UILabel()
        itemline1seg3.frame = CGRectMake(220, 30, screenWidth-100, 25)
        itemline1seg3.textColor = UIColor.grayColor()
        itemline1seg3.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        contentView.addSubview(itemline1seg3)
        
        itemdescp = UILabel()
        itemdescp.frame = CGRectMake(90, 48, screenWidth-100, 25)
        itemdescp.textColor = UIColor.grayColor()
        itemdescp.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        contentView.addSubview(itemdescp)
        
        
        itemdetail = UILabel()
        itemdetail.frame = CGRectMake(90, 68, screenWidth-100, 25)
        itemdetail.textColor = UIColor.grayColor()
        itemdetail.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        contentView.addSubview(itemdetail)
        
        chatButton = UIButton()
        chatButton?.frame = CGRectMake(screenWidth-50, 40, 25, 25)
        contentView.addSubview(chatButton!)
        
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
