//
//  DoctorTableCell.Swift
//  RocketDoc
//
//  Created by gitwebmobi on 8/22/16.
//  Copyright © 2016 gitwebmobi. All rights reserved.
//

import UIKit

class MenuTableCell: UITableViewCell {

    
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var seperatorView: UIView!

    
     override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func fillMenuInfo(menu:Menu)  {
        self.menuLabel.text = menu.title
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTransparent() {
        let bgView: UIView = UIView()
        bgView.backgroundColor = .clear
        
        self.backgroundView = bgView
        self.backgroundColor = .clear
    }
 }
