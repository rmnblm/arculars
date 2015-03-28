//
//  GameoverScene.swift
//  Arculars
//
//  Created by Roman Blum on 22/03/15.
//  Copyright (c) 2015 RMNBLM. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
import Social

class GameoverScene: SKScene {
    
    var sceneDelegate : SceneDelegate?
    
    // Node and all it's descendants
    private var rootNode = SKNode()
    
    private var replay : SKShapeNode!
    private var tomenu : SKShapeNode!
    
    private var facebook : SKShapeNode!
    private var twitter : SKShapeNode!
    private var whatsapp : SKShapeNode!
    private var shareother : SKShapeNode!
    
    private var ttpLabel : SKLabelNode!
    private var score : SKLabelNode!
    private var hscore : SKLabelNode!
    
    override init(size: CGSize) {
        super.init(size: size)
        
        // Setup Scene
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = Colors.Background
        
        // Add Root Node
        self.addChild(rootNode)
        
        initScene()
    }
    
    private func initScene() {
        var radius = self.size.height / 21
        
        ttpLabel = SKLabelNode(text: "TAP TO PLAY")
        ttpLabel.fontName = "Avenir"
        ttpLabel.fontSize = self.size.height / 32
        ttpLabel.position = CGPoint(x: 0, y: 0)
        
        rootNode.addChild(ttpLabel)
        
        var gameoverLabel = SKLabelNode(text: "GAME OVER!")
        gameoverLabel.fontName = "Avenir-Black"
        gameoverLabel.fontColor = Colors.FontColor
        gameoverLabel.fontSize = self.size.height / 20
        gameoverLabel.position = CGPoint(x: 0, y: (self.size.height / 2) - (self.size.height / 5))
        rootNode.addChild(gameoverLabel)
        
        var scoreLabel = SKLabelNode(text: "YOUR SCORE")
        scoreLabel.fontName = "Avenir-Light"
        scoreLabel.fontColor = Colors.AppColorThree
        scoreLabel.fontSize = self.size.height / 48
        scoreLabel.position = CGPoint(x: -self.size.width / 6, y: self.size.height / 4)
        
        score = SKLabelNode()
        score.fontName = "Avenir"
        score.fontColor = Colors.AppColorThree
        score.fontSize = self.size.height / 20
        score.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        score.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        score.position = CGPoint(x: 0, y: -scoreLabel.frame.size.height * 2)
        scoreLabel.addChild(score)
        
        rootNode.addChild(scoreLabel)
        
        var hscoreLabel = SKLabelNode(text: "HIGH SCORE")
        hscoreLabel.fontName = "Avenir-Light"
        hscoreLabel.fontSize = self.size.height / 48
        hscoreLabel.fontColor = Colors.FontColor
        hscoreLabel.position = CGPoint(x: self.size.width / 6, y: self.size.height / 4)
        
        hscore = SKLabelNode()
        hscore.fontName = "Avenir"
        hscore.fontColor = Colors.FontColor
        hscore.fontSize = self.size.height / 20
        hscore.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        hscore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        hscore.position = CGPoint(x: 0, y: -scoreLabel.frame.size.height * 2)
        hscoreLabel.addChild(hscore)
        
        rootNode.addChild(hscoreLabel)
        
        facebook = SKShapeNode(circleOfRadius: radius)
        facebook.fillColor = Colors.FacebookBlue
        facebook.strokeColor = Colors.FacebookBlue
        facebook.antialiased = true
        facebook.lineWidth = 1
        facebook.zPosition = 3
        facebook.position = CGPoint(x: -(self.size.width / 2) + (self.size.width / 5), y: -(self.size.height / 4))
        facebook.addChild(SKSpriteNode(imageNamed: "icon-facebook"))
        rootNode.addChild(facebook)
        
        twitter = SKShapeNode(circleOfRadius: radius)
        twitter.fillColor = Colors.TwitterBlue
        twitter.strokeColor = Colors.TwitterBlue
        twitter.antialiased = true
        twitter.lineWidth = 1
        twitter.zPosition = 4
        twitter.position = CGPoint(x: -(self.size.width / 2) + ((self.size.width / 5) * 2), y: -(self.size.height / 4))
        var twitterSprite = SKSpriteNode(imageNamed: "icon-twitter")
        twitter.addChild(twitterSprite)
        rootNode.addChild(twitter)
        
        whatsapp = SKShapeNode(circleOfRadius: radius)
        whatsapp.fillColor = Colors.WhatsAppGreen
        whatsapp.strokeColor = Colors.WhatsAppGreen
        whatsapp.antialiased = true
        whatsapp.lineWidth = 1
        whatsapp.zPosition = 2
        whatsapp.position = CGPoint(x: -(self.size.width / 2) + ((self.size.width / 5) * 3), y: -(self.size.height / 4))
        whatsapp.addChild(SKSpriteNode(imageNamed: "icon-whatsapp"))
        rootNode.addChild(whatsapp)
        
        shareother = SKShapeNode(circleOfRadius: radius)
        shareother.fillColor = Colors.SharingGray
        shareother.strokeColor = Colors.SharingGray
        shareother.antialiased = true
        shareother.lineWidth = 1
        shareother.zPosition = 1
        shareother.position = CGPoint(x: -(self.size.width / 2) + ((self.size.width / 5) * 4), y: -(self.size.height / 4))
        shareother.addChild(SKSpriteNode(imageNamed: "icon-share"))
        rootNode.addChild(shareother)
        
        var tomenuLabel = SKLabelNode(text: "BACK TO MENU")
        tomenuLabel.fontName = "Avenir"
        tomenuLabel.fontColor = Colors.FontColor
        tomenuLabel.fontSize = self.size.height / 32
        tomenu = SKShapeNode(rect: CGRect(x: -(self.size.width / 2), y: -(self.size.height / 2), width: self.size.width, height: tomenuLabel.frame.height * 4))
        tomenu.lineWidth = 0
        tomenu.fillColor = UIColor.clearColor()
        tomenu.strokeColor = UIColor.clearColor()
        tomenuLabel.position = CGPoint(x: 0, y: -(self.size.height / 2) + (tomenuLabel.frame.height * 1.5))
        tomenu.addChild(tomenuLabel)
        rootNode.addChild(tomenu)
    }
    
    override func didMoveToView(view: SKView) {
        var lastscore = StatsHandler.getLastscore(Globals.currentGameType)
        var highscore = StatsHandler.getHighscore(Globals.currentGameType)
        
        ttpLabel.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.fadeAlphaTo(0.0, duration: 0.2),
            SKAction.fadeAlphaTo(1.0, duration: 0.2),
            SKAction.waitForDuration(1.5)
            ])), withKey: "blinking")
        
        score.text = "\(lastscore)"
        hscore.text = "\(highscore)"
        
        self.runAction(SKAction.fadeInWithDuration(0.15))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(rootNode)
            
            if (tomenu.containsPoint(location)) {
                self.runAction(SKAction.fadeOutWithDuration(0.3), completion: { ()
                    self.sceneDelegate!.showMenuScene()
                })
            } else if (twitter.containsPoint(location)) {
                self.sceneDelegate!.shareOnTwitter()
            } else if (facebook.containsPoint(location)) {
                self.sceneDelegate!.shareOnFacebook()
            } else if (whatsapp.containsPoint(location)) {
                self.sceneDelegate!.shareOnWhatsApp()
            } else if (shareother.containsPoint(location)) {
                self.sceneDelegate!.shareOnOther()
            } else {
                self.runAction(SKAction.fadeOutWithDuration(0.15), completion: { ()
                    self.sceneDelegate!.startGame()
                })
            }
        }
    }
}