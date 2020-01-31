//
//  GameScene.swift
//  Pong
//
//  Created by Shyamal Chandra on 6/23/17.
//  Copyright © 2017 Shyamal Chandra. All rights reserved.
//

// The 2-D engine for making games
import SpriteKit

// The library for controlling
import GameplayKit

// The library for the controller
import GameController

// The class created by default
class GameScene: SKScene {
    
    // The SpriteNodes for the two paddles and the ball
    var ball = SKSpriteNode()
    var enemy = SKSpriteNode()
    var main = SKSpriteNode()
    
    // The two labels that contain the score
    var topLbl = SKLabelNode()
    var btmLbl = SKLabelNode()
    
    // The array that holds the score
    var score = [Int]()
    
    // Self-explanatory
    override func didMove(to view: SKView) {
        
        // Check for game controllers
        CheckForGameControllers()
        
        // Call the initialization function
        startGame()
        
        // Associate the labels with the appropriate name
        topLbl = self.childNode(withName: "topLabel") as! SKLabelNode
        btmLbl = self.childNode(withName: "bottomLabel") as! SKLabelNode
        
        // Associate the Sprite nodes with the labels
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        main = self.childNode(withName: "main") as! SKSpriteNode
        enemy = self.childNode(withName: "enemy") as! SKSpriteNode
        
        // Apply an impulse to the Sprite Node
        ball.physicsBody?.applyImpulse(CGVector(dx: 300, dy: 300))
        
        // The border of where the physics takes place (cage)
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        // No friction
        border.friction = 0
        
        // Restitution is set to 1
        border.restitution = 1
        
        // Self-explanatory
        self.physicsBody = border
    }
    
    @objc func disconnectControllers() {
        // Pause the game if disconnected
        
        self.isPaused = true
    }
    
    func setupControllerControls(controller: GCController) {
        controller.extendedGamepad?.valueChangedHandler = {
            (gamepad: GCExtendedGamepad, element: GCControllerElement) in
            
            // Add movement for sprites of the controllers
            
            self.controllerInputDetected(gamepad: gamepad, element: element, index: controller.playerIndex.rawValue)
        }
    }
    
    @objc func connControllers() {
        // Unpause the game if currently paused
        self.isPaused = false
        
        // Registers the controller to a player number
        var indexNumber = 0
        
        for controller in GCController.controllers() {
            
            // Check if extended game controller
            if controller.extendedGamepad != nil {
                controller.playerIndex = GCControllerPlayerIndex.init(rawValue: indexNumber)!
                
                indexNumber += 1
                
                setupControllerControls(controller: controller)
            }
            
        }
    }
    
    func CheckForGameControllers() {
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(connControllers), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectControllers), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
        
        
        
    }
    
    // Always done at the start of a game
    func startGame() {
        
        // Initial score
        score = [0,0]
        
        // Initialization of the labels to zero
        topLbl.text = "\(score[1])"
        btmLbl.text = "\(score[0])"
    }
    
    // Add to the score for the Pong game
    func addScore(playerWhoWon: SKSpriteNode) {
        
        // Initial position of the ball (x=0, y=0) with the four quadrant
        ball.position = CGPoint(x: 0, y: 0)
        
        // Velocity of the physics body
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        // If the human won playing the game
        if playerWhoWon == main {
            
            // Add to the score
            score[0] += 1
            
            // Apply an impulse to the ball
            ball.physicsBody?.applyImpulse(CGVector(dx: 300, dy: 300))
        }
        // If the CPU engine won playing the game
        else if playerWhoWon == enemy {
            // Add to the score
            score[1] += 1
            
            // Apply an impulse to the ball
            ball.physicsBody?.applyImpulse(CGVector(dx: -300, dy: -300))

        }
        
        // Update the labels with the right score
        topLbl.text = "\(score[1])"
        btmLbl.text = "\(score[0])"
    }
    
    // Keystroke to command (left or right)
    override func keyDown(with event: NSEvent) {
        
        // If left
        if event.keyCode == 123 {
            // Move your paddle to the left by 100 at 0.2 duration
            main.run(SKAction.moveTo(x: main.position.x - 100, duration: 0.2))
        }
        // If right
        else if event.keyCode == 124 {
            // Move your paddle to the right by 100 at 0.2 duration
            main.run(SKAction.moveTo(x: main.position.x + 100, duration: 0.2))
        }
    }

    
    
    // This is the update function every frame loop
    override func update(_ currentTime: TimeInterval) {

        // Registers the controller to a player number
        var indexNumber = 0
        
        // Make the enemy paddle to align with the ball as much as possible
        enemy.run(SKAction.moveTo(x: ball.position.x, duration: 0.1))
        
        // If ball below you, enemy wins!
        if ball.position.y <= main.position.y - 70  {
            addScore(playerWhoWon: enemy)
        }
        // If ball above the enemy, you win!
        else if ball.position.y >= enemy.position.y + 70 {
            addScore(playerWhoWon: main)
        }
        
        for controller in GCController.controllers() {
            
            // Check if extended game controller
            if controller.extendedGamepad != nil {
                controller.playerIndex = GCControllerPlayerIndex.init(rawValue: indexNumber)!
                
                // Registers the controller to a player number
                indexNumber += 1
                
                // Move your paddle to the left by 100 at 0.2 duration
                if ((controller.extendedGamepad?.leftTrigger.isPressed)!) {
                    main.run(SKAction.moveTo(x: main.position.x - 100, duration: 0.2))
                }
                // Move your paddle to the right by 100 at 0.2 duration
                else if ((controller.extendedGamepad?.rightTrigger.isPressed)!) {
                    main.run(SKAction.moveTo(x: main.position.x + 100, duration: 0.2))
                }
            }
            
        }
        
    }
}
