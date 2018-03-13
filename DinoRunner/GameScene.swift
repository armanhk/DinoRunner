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

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Score
    var scoreLabel = SKLabelNode()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
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
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 2.0), SKAction.run(addEnemy), SKAction.wait(forDuration: 2.0, withRange: 6.0)])))
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    func touchDown(atPoint pos: CGPoint) {
        jump()
    }
    
    
    func jump() {
        
        // These two lines prevent double jumps from multitouch
        self.isUserInteractionEnabled = false
        let enable = SKAction.run { self.isUserInteractionEnabled = true }
        
        // Defines jumping action
        let jumpUpAction = SKAction.moveBy(x: 0, y: 150, duration: 0.5)
        let jumpDownAction = SKAction.moveBy(x: 0, y: -150, duration: 0.5)
        let jumpSequence = SKAction.sequence([jumpUpAction, jumpDownAction, enable])
        
        player.run(jumpSequence)
    }
    
    override func update(_ currentTime: TimeInterval) {
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
    func playerEnemyCollision(player: SKSpriteNode, enemy: SKSpriteNode) {
        let gameOver = SKAction.run {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, score: self.score)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        player.run(SKAction.sequence([gameOver]))
    }
    
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
 
}
