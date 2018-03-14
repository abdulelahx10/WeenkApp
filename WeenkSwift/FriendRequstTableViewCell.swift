//
//  FriendRequstTableViewCell.swift
//  Weenk
//
//  Created by Abdulrahman Alzeer on 01/03/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit

class FriendRequstTableViewCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    
    weak var delegate : FriendRequstTableViewCellDelegate?

    @IBAction func AcceptRequst(_ sender: Any) {
        delegate?.didTapAccept(self)
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

protocol FriendRequstTableViewCellDelegate : class {
    func didTapAccept(_ sender:FriendRequstTableViewCell)
}
