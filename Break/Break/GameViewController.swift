//
//  GameViewController.swift
//  Break
//
//  Created by Susanne Burnham on 10/8/15.
//  Copyright © 2015 Susanne Kasahara. All rights reserved.
//

import UIKit

import AVFoundation

import Foundation

enum BoundaryType: String {
    
    case Floor, LeftWall, RightWall, Ceiling
}
// the singleton is evaluating info in GameData and through the singletion function is passing top score and current score info 

private let _mainData = GameData()

class GameData: NSObject {
    
    class func mainData() -> GameData { return _mainData }
    
    var topScore = 0
    
    var currentScore = 0 {
        
        didSet {
            
            if currentScore > topScore { topScore = currentScore }
            
        }
        
    }
    
    var currentLevel = 0
    
    // levels = array of tuples where each tuple is made of 2 Int type values
    var levels: [(Int,Int)] = [
        
        (5,2), // (row,col)
        (8,2),
        (6,3),
        (9,3),
        (5,4),
        (8,4)
        
    ]
    
}


class GameViewController: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate, AVAudioPlayerDelegate {
    
    
    let x = 5
    let y = 2
    var z: Int { return x + y }
    
    var animator: UIDynamicAnimator!
    
    
    let ballBehavior = UIDynamicItemBehavior()
    let brickBehavior = UIDynamicItemBehavior()
    let paddleBehavior = UIDynamicItemBehavior()
    
    var attachment: UIAttachmentBehavior?
    
    let gravity = UIGravityBehavior()
    let collision = UICollisionBehavior()
    
    let topBar = TopBarView(frame: CGRect(x: 0, y: 0, width: 0, height: 50))
    let paddle = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
    
    var players = [AVAudioPlayer]()
    
    
    
    // MARK: ALL METHODS
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        playSound("KnightRider")
        
        
        let bg = UIImageView(image: UIImage(named: "bg"))
        bg.frame = view.frame
        view.addSubview(bg)
        
        // topbar
        
        topBar.frame.size.width = view.frame.width
        view.addSubview(topBar)
        
        
        view.addSubview(topBar)
        
        setupBehaviors()

        // run create game elements methods
        
        createPaddle()
        createBall()
        createBricks()
        
        
    } // end viewDidLoad
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        
        
        for brick in brickBehavior.items as! [UIView] {
            
            if brick === item1 as! UIView || brick == item2 as! UIView {
                
                playSound("Beep")
                
                brickBehavior.removeItem(brick)
                collision.removeItem(brick)
                brick.removeFromSuperview()
                
                topBar.score += 100
                
    
                
                
            }
        }
        
        // check brick count
        
        
        
    } // end 2 items contact
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem
        item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?,
        atPoint p: CGPoint) {
            
            if let idString = identifier as? String, let boundaryName = BoundaryType(rawValue: idString) {
                
                switch boundaryName {
                    
                case.Ceiling : print("I can fly high")
                    
                case.Floor :
                    
                    if let ball = item as? UIView {
                        
                        ballBehavior.removeItem(ball)
                        collision.removeItem(ball)
                        ball.removeFromSuperview()
                        
                    }
                    
                    if topBar.lives == 0 {
                        
                        // game over
                        
                     endGame()
                        
                    } else {
                        
                        print("IT BURNS")
                        topBar.lives--
                        
                        createBall()
                
                    }
                    
                case.LeftWall : print("LEFTY")
                    
                case .RightWall : print("Correct")
                    
                }
                
                
                
            }
            
    } // end when item & boundary collision
    
    // MARK:  - 😊 METHODS
    

        override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        


        touchesMoved(touches, withEvent: event)
    
    } //end touches began
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
    
      if let touch = touches.first {
            let point = touch.locationInView(view)
            attachment?.anchorPoint.x = point.x
            

        
        }
    
    } // end touches moved
    
    // MARK : Create Game Elements
    
    func createBricks() {
        
        let cols = 8
        let rows = 3
        
        let brickH = 30
        let brickSpacing = 3
        
        let totalSpacing = (cols + 1) * brickSpacing
        let brickW = (Int(view.frame.width) - totalSpacing) / cols
        
        for c in 0..<cols {
            
            for r in 0..<rows {
                
                let x = c * (brickW + brickSpacing) + brickSpacing
                let y = r * (brickH + brickSpacing) + brickSpacing + 60
                
                let brick = UIView(frame: CGRect(x: x, y: y, width: brickW, height: brickH))
                brick.backgroundColor = UIColor.blackColor()
                brick.layer.cornerRadius = 5
                
                playSound("Beep")
                
                view.addSubview(brick)
                
                collision.addItem(brick)
                
                brickBehavior.addItem(brick)
                
                
                
                
            }
        }
        
    }
    
    func createBall() {
        
        
        let ball = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        ball.layer.cornerRadius = 10
        ball.backgroundColor = UIColor.whiteColor()
        view.addSubview(ball)
        
        ball.center = view.center
        
        ballBehavior.addItem(ball)
        collision.addItem(ball)
        
        ball.center.x = paddle.center.x
        ball.center.y = paddle.center.y - 20
        
        //push
        
        let push = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        
        push.pushDirection = CGVector(dx: 0.1, dy: -0.1)
        
        animator.addBehavior(push)
        
            
        print(animator.behaviors.count)
    }
    
    func createPaddle() {
        
        paddle.backgroundColor = UIColor.blackColor()
        paddle.layer.cornerRadius = 5
        
        paddle.center = CGPoint(x: view.center.x,  y: view.frame.height - 40)
        
        view.addSubview(paddle)
        
        paddleBehavior.addItem(paddle)
        collision.addItem(paddle)
        
        attachment = UIAttachmentBehavior(item: paddle, attachedToAnchor: paddle.center)
        
        animator.addBehavior(attachment!)
        
    }
    
    func setupBehaviors() {
        
        animator = UIDynamicAnimator(referenceView: view)
        
        
        animator.delegate = self
        
        animator.addBehavior(gravity)
        animator.addBehavior(collision)
        animator.addBehavior(ballBehavior)
        animator.addBehavior(brickBehavior)
        animator.addBehavior(paddleBehavior)
        
        collision.collisionDelegate = self
        
        //ball behavior
        
        ballBehavior.friction = 0
        ballBehavior.resistance = 0
        ballBehavior.elasticity = 1
        
        //set up brick behavior
        
        brickBehavior.anchored = true
        
        // set up paddle behavior
        
        paddleBehavior.allowsRotation = false
        //paddleBehavior.anchored = true
        
        // wrap view in boundary
        collision.translatesReferenceBoundsIntoBoundary = true
        
        collision.addBoundaryWithIdentifier(BoundaryType.Ceiling.rawValue, fromPoint: CGPoint(x: 0, y: 50), toPoint: CGPoint(x: view.frame.width, y: 50))
        
        collision.addBoundaryWithIdentifier(BoundaryType.Floor.rawValue, fromPoint: CGPoint(x: 0, y: view.frame.height - 10), toPoint: CGPoint(x: view.frame.width, y: view.frame.height - 10))
        
    }
    // MARK: -End Game
    
    func endGame(){
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    let startVC =
    storyboard.instantiateViewControllerWithIdentifier("StartVC")
    navigationController?.viewControllers = [startVC]
    
    
    }
    
    
    func playSound(named: String) {
        print("playing")
        
        if let fileData = NSDataAsset(name: named) {
            
            let data = fileData.data
            
            do {
                
                let player = try AVAudioPlayer(data: data)
                
                player.play()
                
                players.append(player)
                
                print(players.count)
                
            } catch {
                
                print(error)
            }
            
        
            
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        players.removeLast()
    }
} // end class