//
//  ViewController.swift
//  SidebarMenu
//
//  Created by Jorge Benavides on 5/16/16.
//  Copyright © 2016 PEW PEW. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dismissButtonAction(button:UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

