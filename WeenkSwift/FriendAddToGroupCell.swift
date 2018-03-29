//
//  FriendAddToGroupCell.swift
//  Weenk
//
//  Created by Abdulrahman Alzeer on 23/03/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit

class FriendAddToGroupCell: UITableViewCell {
    
    weak var delegate:FriendAddToGroupCellDelegate?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol FriendAddToGroupCellDelegate: class {
    func didTapADD(_ sender:FriendAddToGroupCell)
    func didTapAsChild(_ sender:FriendAddToGroupCellDelegate)
}
