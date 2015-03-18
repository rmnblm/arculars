//
//  GameScene.swift
//  Arculars
//
//  Created by Roman Blum on 09/03/15.
//  Copyright (c) 2015 RMNBLM. All rights reserved.
//

import UIKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Node and all it's descendants while playing
    private var rootNode = SKNode()
    private var nextBall : Ball!
    private var innerCircle : Circle!
    private var middleCircle : Circle!
    private var outerCircle : Circle!
    private var score : Score!
    
    // Node and all it's descendants when game over
    private var gameoverNode = SKNode()
    private var isGameOver = false
    private var replayButton : Button!
    private var gameoverScoreLabel : SKLabelNode!
    
    override func didMoveToView(view: SKView) {
        // Setup Scene
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = Colors.Background
        
        // Setup Scene Physics
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRectMake(-(self.size.width / 2), -(self.size.height / 2), self.size.width, self.size.height))
        self.physicsBody?.categoryBitMask = PhysicsCategory.border.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.ball.rawValue
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.dynamic = true
        
        initializeStartGameLayer()
        initializeGameOverLayer()
    }
    
    private func initializeStartGameLayer() {
        self.addChild(rootNode)
        
        var scorePosition = CGPoint(x: 0, y: -(self.size.height / 2) + 32)
        score = Score(position: scorePosition)
        rootNode.addChild(score)
        
        var circlePosition = CGPoint(x: 0, y: self.size.height / 4)
        outerCircle = Circle(circleColor: Colors.LightBlue, arcColor: Colors.Blue, position: circlePosition, radius: 100.0, thickness: 40.0, clockwise: true, secondsPerRound: 1.2, pointsPerHit: 1)
        rootNode.addChild(outerCircle.fadeIn())
        middleCircle = Circle(circleColor: Colors.LightOrange, arcColor: Colors.Orange, position: circlePosition, radius: 50, thickness: 25.0, clockwise: false, secondsPerRound: 1.8, pointsPerHit: 2)
        rootNode.addChild(middleCircle.fadeIn())
        innerCircle = Circle(circleColor: Colors.LightRed, arcColor: Colors.Red, position: circlePosition, radius: 20.0, thickness: 18.0, clockwise: true, secondsPerRound: 2.4, pointsPerHit: 3)
        rootNode.addChild(innerCircle.fadeIn())
        
        addBall()
    }
    
    private func initializeGameOverLayer() {
        self.addChild(gameoverNode)
        
        gameoverNode.zPosition = 1
        gameoverNode.hidden = true
        
        var content = SKNode()
        var image = SKSpriteNode(imageNamed: "highscore")
        image.position = CGPoint(x: 0, y: 30)
        content.addChild(image)
        
        gameoverScoreLabel = SKLabelNode()
        gameoverScoreLabel.position = CGPoint(x: 0, y: -30)
        content.addChild(gameoverScoreLabel)
        
        var scoreContent = Button(position: CGPoint(x: 0, y: 80), color: Colors.Red, content: content, radius: 100)
        gameoverNode.addChild(scoreContent.fadeIn())
        
        replayButton = Button(position: CGPoint(x: 0, y: -80), color: Colors.Red, content: SKSpriteNode(imageNamed: "replay"), radius: 30)
        gameoverNode.addChild(replayButton.fadeIn())
    }
    
    private func addBall() {
        var ballPosition = CGPoint(x: 0, y: -(size.height / 4))
        nextBall = Ball(color: Colors.randomBallColor(), position: ballPosition).fadeIn()
        rootNode.addChild(nextBall)
    }
    
    private func removeBall(ball: Ball) {
        
    }
    
    private func shootBall() {
        nextBall.shoot()
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if isGameOver {
            let touch = touches.anyObject() as UITouch
            let location = touch.locationInNode(gameoverNode)
            
            if (replayButton.containsPoint(location)) {
                reset()
            }
        } else {
            println("*** SHOOT ***")
            shootBall()
            addBall()
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        println("did begin contact")
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        println("did end contact")
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        println("contact mask \(contactMask)")
        switch (contactMask) {
            case PhysicsCategory.ball.rawValue | PhysicsCategory.arc.rawValue:
                var ball : Ball
                var circle : Circle
            
                if contact.bodyA.categoryBitMask == PhysicsCategory.ball.rawValue {
                    ball = contact.bodyA.node as Ball
                    circle = contact.bodyB.node?.parent as Circle // parent because the arc's parent
                } else {
                    ball = contact.bodyB.node as Ball
                    circle = contact.bodyA.node?.parent as Circle // parent because the arc's parent
                }
                ballDidCollideWithCircle(ball, circle: circle)
                
                break
            case PhysicsCategory.border.rawValue | PhysicsCategory.ball.rawValue:
                var ball : Ball
                
                if contact.bodyA.categoryBitMask == PhysicsCategory.ball.rawValue {
                    ball = contact.bodyA.node as Ball
                } else{
                    ball = contact.bodyB.node as Ball
                }
                
                ballDidCollideWithBorder(ball)
                break
            default:
                return
        }
    }
    
    private func ballDidCollideWithCircle(ball: Ball, circle: Circle) {
        println("ball did collide with circle")
        // because of the complex shape of the arc's physicsbody
        // there are multiple contacts when a ball collides with an arc
        // so this is a fix to avoid multiple points being counted to the score
        ball.physicsBody!.categoryBitMask = PhysicsCategory.none.rawValue
        ball.hidden = true
        ball.runAction(SKAction.removeFromParent())
        
        if (ball.nodeColor == circle.nodeColor) {
            println("=== score \(circle.pointsPerHit)")
            self.score.increaseByWithColor(UInt32(circle.pointsPerHit), color: ball.nodeColor)
        } else {
            println("=== game is over")
            gameOver()
        }
    }
    
    private func ballDidCollideWithBorder(ball: Ball) {
        println("ball did collide with border")
        ball.runAction(SKAction.removeFromParent())
    }
    
    private func gameOver() {
        isGameOver = true
        rootNode.alpha = 0.1
        gameoverNode.hidden = false
        
        gameoverScoreLabel.text = "Score \(self.score.getScore())"
        replayButton.fadeIn()
    }
    
    private func reset() {
        isGameOver = false
        rootNode.alpha = 1.0
        
        gameoverNode.hidden = true
        score.reset()
    }
}
