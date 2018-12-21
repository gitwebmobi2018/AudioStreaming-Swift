//
//  PlayPauseButton.swift
//  Jammin92
//
//  Created by gitwebmobi on 10/16/17.
//  Copyright © 2017 gitwebmobi All rights reserved.
//


import UIKit

enum ButtonState {
    case play
    case stop
}

class PlayPauseButton: UIButton {
    
    var playImage:UIImage = UIImage.init(named: "play")!
    var stopImage:UIImage = UIImage.init(named: "stop")!

    var btnState:ButtonState = .stop{
        didSet{
            switch btnState {
            case .play:
                setImage(playImage, for: .normal)
            case .stop:
                setImage(stopImage, for: .normal)
            }
        }
    }
    /*
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
    */
    //---------------------------------------------------
    // MARK: - Initializations
    //---------------------------------------------------
    
    func commonInit() {
       // if !autoRound { layer.cornerRadius = 5  }
        btnState = .stop
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
       // self.layer.cornerRadius = cornerRadius;
        //self.layer.borderColor = borderColor.cgColor
        //self.layer.borderWidth = borderWidth
        
        layer.masksToBounds = true
    }
}
