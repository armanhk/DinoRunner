//
//  GameOverScene.swift
//  DinoRunner
//
//  Created by Arman Kazi on 3/5/18.
//  Copyright © 2018 Arman Kazi. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, score: Int) {
        super.init(size: size)
        
        backgroundColor = SKColor.black
        let message = "GAME OVER"
        let score = "SCORE: \(score)"
        
        let label = SKLabelNode(fontNamed: "Times New Roman")
        let scoreLabel = SKLabelNode(fontNamed: "ChalkDuster")
        label.text = message
        scoreLabel.text = score
        label.fontSize = 50
        scoreLabel.fontSize = 20
        label.fontColor = SKColor.red
        scoreLabel.fontColor = SKColor.white
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height/3)
        addChild(label)
        addChild(scoreLabel)
        
        run(SKAction.sequence([SKAction.wait(forDuration: 3.0), SKAction.run {
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: self.size)
                self.view?.presentScene(scene, transition: reveal)
            }
        ]))
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
