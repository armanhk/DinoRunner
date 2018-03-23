//
//  GameScene.swift
//  DinoRunner
//
//  Created by Arman Kazi on 3/4/18.
//  Copyright © 2018 Arman Kazi. All rights reserved.
//

import SpriteKit
import UIKit
import GameplayKit
import Foundation

func readDataFromFile(file:String) -> Array<Any>!{
    guard let filepath = Bundle.main.path(forResource: file, ofType: "txt")
        else {
            return nil
    }
    do {
        let content = try String(contentsOfFile: filepath)
        let lines : [String] = content.components(separatedBy: "\n")
        var ints : [Int] = []
        for var line in lines {
            if (line == "") { continue }
            line = line.filter{(!"\r".contains($0))}
            ints.append(Int(line)!)
        }
        return ints
    } catch {
        print("File Read Error for file \(filepath)")
        return nil
    }
}

var file1 : [Int] = readDataFromFile(file: "data-at") as! [Int]
var file2 : [Int] = readDataFromFile(file: "data-bl") as! [Int]
var i = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    //MARK: File i/o
    
    
    // Score
    var scoreLabel = SKLabelNode()
    var brainLabel = SKLabelNode()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var brainActivity = 0 {
        didSet {
            brainLabel.text = "Attn Level: \(brainActivity)"
        }
    }
    
    // Physics for collisions
    struct GamePhysics {
        static let None: UInt32 = 0
        static let All: UInt32 = UInt32.max
        static let Enemy: UInt32 = 0b1
        static let Player: UInt32 = 0b10
     }
    
    
    
    // Create and add the player (dinosaur) to the scene
    let player = SKSpriteNode(imageNamed: "Dinosaur")   //declare priv constant, ex) of a sprite
    
    
    // Set player position in scene
    override func didMove(to view: SKView) {
        
        
        
        backgroundColor = SKColor.white
        player.position = CGPoint(x: size.width * 0.05, y: size.height * 0.5)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = GamePhysics.Player
        player.physicsBody?.contactTestBitMask = GamePhysics.Enemy
        player.physicsBody?.collisionBitMask = GamePhysics.None
        player.physicsBody?.usesPreciseCollisionDetection = true
        addChild(player)
        
        //Physics delegate
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        // Score keeping
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontColor = SKColor.blue
        scoreLabel.text = "Score: "
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: size.width-10, y: size.height/7)
        addChild(scoreLabel)
        
        // Brain activity
        brainLabel = SKLabelNode(fontNamed: "Chalkduster")
        brainLabel.fontColor = SKColor.blue
        brainLabel.text = "Score: "
        brainLabel.horizontalAlignmentMode = .right
        brainLabel.position = CGPoint(x: size.width-10, y: size.height/4)
        addChild(brainLabel)
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 2.0), SKAction.run(addEnemy), SKAction.wait(forDuration: 2.0, withRange: 6.0)])))
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    func touchDown(attn: Int) {
        if (attn >= 0){
            jump()
        }
    }
    
    
    func jump() {
        
        // These two lines prevent double jumps from multitouch
        
        let enable = SKAction.run { self.isUserInteractionEnabled = true }
        
        // Defines jumping action
        let jumpUpAction = SKAction.moveBy(x: 0, y: 150, duration: 0.5)
        let jumpDownAction = SKAction.moveBy(x: 0, y: -150, duration: 0.5)
        let jumpSequence = SKAction.sequence([jumpUpAction, jumpDownAction, enable])
        i+=1
        
        if (self.isUserInteractionEnabled == true) {
            player.run(jumpSequence)
        }
        self.isUserInteractionEnabled = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (i < file1.count){
            if (file1[i] >= 90) {
                jump()
            }
            self.brainActivity = file1[i]
            i+=1
        }
        
        if (score > 1500) {self.playerEnemyCollision()}
        
        keepScore()
        // Called before each frame is rendered
    }
    
    // Create and add enemies to scene
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addEnemy() {
        
        // Create sprite
        let enemy = SKSpriteNode(imageNamed: "Cactus")
        
        //Physics
        enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.texture!.size())
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.categoryBitMask = GamePhysics.Enemy
        enemy.physicsBody?.contactTestBitMask = GamePhysics.Player
        enemy.physicsBody?.collisionBitMask = GamePhysics.None
        
        // Determine where to spawn enemy along y-axis
        let actualY = random(min: size.height * 0.5, max: size.height * 0.5)
        
        // Position enemy
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: actualY)
        
        // Add enemy to scene
        addChild(enemy)
        
        // Speed of enemy
        let actualDuration = 3.5
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: -enemy.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        enemy.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    // Score method
    func keepScore() {
        self.score+=1
    }
    
    // Collision methods
    func playerEnemyCollision() {
        let gameOver = SKAction.run {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, score: self.score)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        player.run(SKAction.sequence([gameOver]))
    }
    
    /*
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & GamePhysics.Enemy != 0) && (secondBody.categoryBitMask & GamePhysics.Player != 0)) {
            if let enemy = firstBody.node as? SKSpriteNode, let player = secondBody.node as? SKSpriteNode {
                self.playerEnemyCollision(player: player, enemy: enemy)
            }
        }
        
    }
 */
 
}
