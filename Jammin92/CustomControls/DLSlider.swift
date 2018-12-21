//
//  DLSlider.swift
//  Jammin92
//
//  Created by gitwebmobi on 10/16/17.
//  Copyright © 2017 gitwebmobi All rights reserved.
//

import UIKit

class DLSlider: UISlider {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func commonInit() {
       // setThumbImage(UIImage.init(named: "volume"), for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = true
    }
}
