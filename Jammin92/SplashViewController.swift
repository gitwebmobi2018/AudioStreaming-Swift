//
//  SplashViewController.swift
//  Jammin92
//
//  Created by gitwebmobi on 10/22/17.
//  Copyright © 2017 gitwebmobi All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.performSegue(withIdentifier: "PlayerViewController", sender: self)
    }
}
