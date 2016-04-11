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
    var hiddenEventID : UILabel!
    
    required init(coder aDecorder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let gap : CGFloat = 10
        let labelHeight: CGFloat = 30
        let labelWidth: CGFloat = 400
        let lineGap : CGFloat = 5
        let label2Y : CGFloat = gap + labelHeight + lineGap
        
        eventPlaceLabel = UILabel()
        eventPlaceLabel.frame = CGRectMake(gap, gap, labelWidth, labelHeight)
        eventPlaceLabel.textColor = UIColor.blackColor()
        contentView.addSubview(eventPlaceLabel)
        
        eventAddressLabel = UILabel()
        eventAddressLabel.frame = CGRectMake(gap, label2Y, labelWidth, labelHeight)
        eventAddressLabel.textColor = UIColor.blackColor()
        contentView.addSubview(eventAddressLabel)
        
        hiddenEventID = UILabel()
        contentView.addSubview(hiddenEventID)
        hiddenEventID.hidden = true 
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
