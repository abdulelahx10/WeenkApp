//
//  GroupRequstTableViewCell.swift
//  Weenk
//
//  Created by Abdulrahman Alzeer on 03/04/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit

class GroupRequstTableViewCell: UITableViewCell {

    
    @IBOutlet weak var groupName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    weak var delegate : GroupRequstTableViewCellDelegate?
    
    @IBAction func acceptRequst(_ sender: Any) {
        delegate?.didTapAcceptGroup(self)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol GroupRequstTableViewCellDelegate : class {
    func didTapAcceptGroup(_ sender:GroupRequstTableViewCell)
}
