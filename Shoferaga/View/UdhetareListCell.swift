//
//  UdhetareListCell.swift
//  Shoferaga
//
//  Created by Gentian Barileva on 5/19/18.
//  Copyright © 2018 Gentian Barileva. All rights reserved.
//

import UIKit

class UdhetareListCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var nameLabel: UILabel!
    
    func updateLabel(with name: String){
        nameLabel.text = name
    }
}
