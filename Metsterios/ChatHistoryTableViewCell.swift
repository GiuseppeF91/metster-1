//
//  ChatHistoryTableViewCell.swift
//  Metsterios
//
//  Created by iT on 5/16/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

class ChatHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var imgPhoto: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgPhoto.clipsToBounds = true
        imgPhoto.layer.cornerRadius = imgPhoto.frame.size.height/2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
