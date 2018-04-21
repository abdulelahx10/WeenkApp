//
//  TrackingRequstCell.swift
//  Weenk
//
//  Created by Abdulrahman Alzeer on 03/04/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import UIKit

class TrackingRequstCell: UITableViewCell {

     weak var delegate:TrackingRequstCellDelegate?
    
   
    @IBOutlet weak var requstLabel: UILabel!
    
    @IBAction func didTapAccept(_ sender: Any) {
        delegate?.acceptTracking(self)
    }
  
    
    @IBAction func didTapReject(_ sender: Any) {
        delegate?.rejectTracking(self)
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

protocol TrackingRequstCellDelegate :class{
    func acceptTracking(_ sender:TrackingRequstCell)
    func rejectTracking(_ sender:TrackingRequstCell)
}
