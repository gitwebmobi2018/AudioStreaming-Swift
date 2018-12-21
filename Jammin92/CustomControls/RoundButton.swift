//
//  RoundButton.swift
//  Jammin92
//
//  Created by gitwebmobi on 10/16/17.
//  Copyright © 2017 gitwebmobi All rights reserved.
//


import UIKit


class RoundButton: UIButton {
    
    @IBInspectable var cornerRadius:CGFloat = 5.0 {
        didSet { setNeedsLayout() } }
    
    @IBInspectable var borderWidth:CGFloat = 2.0 {
        didSet{ setNeedsLayout() } }

    @IBInspectable var borderColor:UIColor = UIColor.clear { didSet {
        self.layer.borderColor = borderColor.cgColor
        setNeedsLayout()
        }
    }

    @IBInspectable var autoRound:Bool = false {
        didSet {
            if autoRound == true {
                cornerRadius = min(bounds.width, bounds.height)/2
                setNeedsLayout()
            }
        }
    }
   
    override var bounds: CGRect {
        didSet {
            if autoRound {
                cornerRadius = min(bounds.width, bounds.height)/2
                layer.masksToBounds = true
            }
        }
    }
    
    //---------------------------------------------------
    // MARK: - Initializations
    //---------------------------------------------------
    
    func commonInit() {
        if !autoRound { layer.cornerRadius = 5  }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    //---------------------------------------------------
    // MARK: - Layout
    //---------------------------------------------------
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = cornerRadius;
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        
        layer.masksToBounds = true
    }
}
