//
//  FriendTableViewCell.swift
//  Weenk
//
//  Created by Abdulrahman Alzeer on 01/03/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var trackBtn: UIButton!
    
    weak var delegate:FriendTableViewCellDelegate?
    
    @IBAction func sendTrackingRequst(_ sender: Any) {
        delegate?.didTapTrack(self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol FriendTableViewCellDelegate : class {
    func didTapTrack(_ sender:FriendTableViewCell)
}
