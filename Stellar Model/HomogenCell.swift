//
//  HomogenCell.swift
//  Stellar Model
//
//  Created by Bedri Keskin on 2/4/20.
//  Copyright © 2020 Bedri Keskin. All rights reserved.
//

import UIKit

class HomogenCell: UITableViewCell {
    @IBOutlet weak var lbli: UILabel!
    @IBOutlet weak var lblMrMo: UILabel!
    @IBOutlet weak var lbllogp: UILabel!
    @IBOutlet weak var lbllogT: UILabel!
    @IBOutlet weak var lbllogd: UILabel!
    @IBOutlet weak var lblrr0: UILabel!
    @IBOutlet weak var lbllogE: UILabel!
    @IBOutlet weak var lbllogL: UILabel!
    @IBOutlet weak var lblx: UILabel!
    @IBOutlet weak var lblf: UILabel!
    @IBOutlet weak var lblh: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
