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

class PlaceTableViewCell: UITableViewCell {
    
    var placeSnippetLabel : UILabel!
    var placedetailsLabel : UILabel!
    var placeDescpLabel : UILabel!
    var placeNameLabel : UILabel!
    var placeImage : UIImageView?
    var publishbutton : UIButton!
    
    required init(coder aDecorder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        placeImage = UIImageView()
        placeImage?.frame = CGRectMake(2, 10, 85, 85)
        placeImage!.layer.cornerRadius = 8.0
        placeImage!.clipsToBounds = true
        contentView.addSubview(placeImage!)
        
        placeNameLabel = UILabel()
        placeNameLabel.frame = CGRectMake(90, 11, screenWidth-100, 30)
        placeNameLabel.textColor = UIColor(red: 0.81, green: 0.71, blue: 0.23, alpha: 1)
        placeNameLabel.font = UIFont(name: "GILLSANSCE-ROMAN-Bold", size: 35)
        contentView.addSubview(placeNameLabel)
        
        placeDescpLabel = UILabel()
        placeDescpLabel.frame = CGRectMake(90, 30, screenWidth-100, 25)
        placeDescpLabel.textColor = UIColor.grayColor()
        placeDescpLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        contentView.addSubview(placeDescpLabel)
        
        placedetailsLabel = UILabel()
        placedetailsLabel.frame = CGRectMake(90, 48, screenWidth-100, 25)
        placedetailsLabel.textColor = UIColor.grayColor()
        placedetailsLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        contentView.addSubview(placedetailsLabel)
        
        placeSnippetLabel = UILabel()
        placeSnippetLabel.frame = CGRectMake(90, 68, screenWidth-100, 20)
        placeSnippetLabel.textColor = UIColor.grayColor()
        placeSnippetLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        contentView.addSubview(placeSnippetLabel)
                
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
