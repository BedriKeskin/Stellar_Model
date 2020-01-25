//
//  CellPolytropes.swift
//  Stellar Model
//
//  Created by Bedri Keskin on 1/21/20.
//  Copyright © 2020 Bedri Keskin. All rights reserved.
//

import UIKit

class PolytropesCell: UITableViewCell {
    @IBOutlet weak var lbli: UILabel!
    @IBOutlet weak var lblx: UILabel!
    @IBOutlet weak var lblf: UILabel!
    @IBOutlet weak var lblh: UILabel!
    @IBOutlet weak var lbllogPoPc: UILabel!
    @IBOutlet weak var lbllogdodc: UILabel!
    @IBOutlet weak var lbllmr: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
