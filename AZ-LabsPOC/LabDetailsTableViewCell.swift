//
//  LabDetailsTableViewCell.swift
//  AZ-LabsPOC
//
//  Created by Siddharth on 21/10/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit

class LabDetailsTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var labName: UILabel!
    @IBOutlet weak var labAddress: UILabel!
    
    @IBOutlet weak var labCity: UILabel!
    @IBOutlet weak var labState: UILabel!
    @IBOutlet weak var labZip: UILabel!
    @IBOutlet weak var labPhone: UILabel!
    @IBOutlet weak var labFax: UILabel!
    
}
