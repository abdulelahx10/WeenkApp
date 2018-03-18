//
//  MassageTableViewCell.swift
//  Weenk
//
//  Created by Abdulrahman Alzeer on 08/03/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit

class MassageTableViewCell: UITableViewCell {

    @IBOutlet weak var backgoundMassage: UIView!
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var massageText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
