//
//  GameViewController.swift
//  DinoRunner
//
//  Created by Arman Kazi on 3/4/18.
//  Copyright © 2018 Arman Kazi. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit



class GameViewController: UIViewController, MWMDelegate {
    
    let mwm = MWMDevice.sharedInstance()
    
    func deviceFound(_ devName: String!, mfgID: String!, deviceID: String!) {
        let str1:String = "devName = "+devName
        let str2:String = ",mfgID = "+mfgID
        let str3:String = ",deviceID = "+deviceID
        mwm?.connect(deviceID)
        
        print(str1+str2+str3)
    }
    
    func didConnect() {
        print("didConnect")
    }
    
    func didDisconnect() {
        mwm?.disconnectDevice()
        print("didDisconnect")
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mwm?.connect("NS252FA4:Mindwave Mobile")
        mwm?.delegate = self
        print("MWM SDK version: "+(mwm?.getVersion())!)
        mwm?.enableConsoleLog(true)
        mwm?.scanDevice()
        
        
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}
