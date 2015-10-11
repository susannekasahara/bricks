//
//  StartViewController.swift
//  Break
//
//  Created by Susanne Burnham on 10/8/15.
//  Copyright © 2015 Susanne Kasahara. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    
    @IBOutlet weak var highScore: UILabel {
        
        let highScore = GameData.mainData()
        

        
      
        
    @IBAction func Play(sender: AnyObject) {
        
        let gameVC = GameViewController()
        
        navigationController?.viewControllers = [gameVC]
    }
    
    
    
   }
}