//
//  Circle.swift
//  Arculars
//
//  Created by Roman Blum on 09/03/15.
//  Copyright (c) 2015 RMNBLM. All rights reserved.
//

import UIKit
import SpriteKit

class Circle : SKShapeNode {
    
    private var action : SKAction!
    private var arc : SKShapeNode!
    let nodeColor : UIColor!
    
    var pointsPerHit = 0
    let sizeOfArc = CGFloat(M_PI / 2) // in radians
    
    init(circleColor: UIColor, arcColor: UIColor, position: CGPoint, radius: CGFloat, thickness: CGFloat, clockwise: Bool, secondsPerRound: NSTimeInterval, pointsPerHit: Int) {
        super.init()
        
        var circlepath = CGPathCreateMutable()
        CGPathAddArc(circlepath, nil, 0, 0, radius, CGFloat(M_PI * 2), 0, true)
        self.path = circlepath
        self.lineWidth = thickness
        self.zPosition = 0
        self.strokeColor = circleColor
        self.position = position
        
        var circleOffset = SKShapeNode(circleOfRadius: radius)
        circleOffset.strokeColor = circleColor.darkerColor(0.1)
        circleOffset.lineWidth = thickness
        circleOffset.position = CGPoint(x: 0, y: -3)
        circleOffset.zPosition = -1
        self.addChild(circleOffset)
        
        let arcpath = UIBezierPath(arcCenter: CGPoint(x: 0, y: 0), radius: radius, startAngle: 0.0, endAngle: sizeOfArc, clockwise: true)
        arc = SKShapeNode(path: arcpath.CGPath)
        arc.lineCap = kCGLineCapRound
        arc.strokeColor = arcColor
        arc.antialiased = true
        arc.zPosition = 1
        arc.lineWidth = thickness + 0.5 // one pixel more because of the linewidth of the circle itself
        
        // Setup PhysicsBody of Arc
        var bodypath : CGMutablePath = CGPathCreateMutable();
        var offsetangle = CGFloat(self.sizeOfArc / 9)
        
        var p1 = CGPointApplyAffineTransform(CGPoint(x: 0, y: CGFloat(radius - (thickness / 2))), CGAffineTransformMakeRotation(offsetangle))
        CGPathMoveToPoint(bodypath, nil, p1.x, p1.y)
        var p2 = CGPointApplyAffineTransform(CGPoint(x: 0, y: CGFloat(radius + (thickness / 2))), CGAffineTransformMakeRotation(offsetangle))
        CGPathAddLineToPoint(bodypath, nil, p2.x, p2.y)
        CGPathAddArc(bodypath, nil, 0, 0, CGFloat(radius + (thickness / 2)), CGFloat(sizeOfArc + offsetangle), -CGFloat(offsetangle), true)
        var p3 = CGPointApplyAffineTransform(CGPoint(x: CGFloat(radius - (thickness / 2)), y: 0), CGAffineTransformMakeRotation(-offsetangle))
        CGPathAddLineToPoint(bodypath, nil, p3.x, p3.y)
        CGPathAddArc(bodypath, nil, 0, 0, CGFloat(radius - (thickness / 2)), -CGFloat(offsetangle), CGFloat(sizeOfArc + offsetangle), false)
        CGPathCloseSubpath(bodypath)
        
        arc.physicsBody = SKPhysicsBody(polygonFromPath: bodypath)
        arc.physicsBody!.categoryBitMask = PhysicsCategory.arc.rawValue
        arc.physicsBody!.contactTestBitMask = PhysicsCategory.ball.rawValue
        arc.physicsBody!.collisionBitMask = 0
        arc.physicsBody!.usesPreciseCollisionDetection = true
        arc.physicsBody!.dynamic = false

        // Setup animation
        var rotationangle : CGFloat
        if clockwise {
            rotationangle = CGFloat(2 * M_PI)
        }
        else {
            rotationangle = -CGFloat(2 * M_PI)
        }
        action = SKAction.repeatActionForever(SKAction.rotateByAngle(rotationangle, duration: secondsPerRound))
        arc.runAction(action)
        
        self.nodeColor = arcColor
        self.pointsPerHit = pointsPerHit
        
        self.addChild(arc)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fadeIn() -> Circle {
        
        // disable the physicsbody because otherwise this will fail
        let temp = arc.physicsBody
        arc.physicsBody = nil
        
        self.xScale = 0.0
        self.yScale = 0.0
        
        self.runAction(
            SKAction.sequence([
                SKAction.scaleTo(1.05, duration: 0.1),
                SKAction.scaleTo(0.95, duration: 0.1),
                SKAction.scaleTo(1.0, duration: 0.1)
                ]), completion: {()
            self.arc.physicsBody = temp
        })
        
        return self
    }
    
    func modifySpeedBy(factor: CGFloat) {
        action!.speed *= factor
    }
    
}