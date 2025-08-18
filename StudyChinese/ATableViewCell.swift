//
//  ATableViewCell.swift
//  Study Chinese app
//
//  Created by Kosuke Shigematsu on 5/12/23.
//

import UIKit

class ATableViewCell: UITableViewCell {

    @IBOutlet weak var TextLabel: UILabel!
    @IBOutlet weak var NumLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
