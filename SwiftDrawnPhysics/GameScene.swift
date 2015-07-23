//
//  GameScene.swift
//  SwiftDrawnPhysics
//
//  Created by Trent Sartain on 6/23/14.
//  Copyright (c) 2014 Trent Sartain. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var clearButton = SKLabelNode()
    var objectArray = Array<SKNode>()
    var currentPath = CGPathCreateMutable()
    var currentDrawing = SKShapeNode()
    let lineWidth : CGFloat = 4
    
    override func didMoveToView(view: SKView) {
        setupScene()
        setupGlobals()
        setupGestureRecognizers()
    }
    
    override func update(currentTime: CFTimeInterval) {
        
    }
    
    func setupScene(){
        self.backgroundColor = UIColor.whiteColor()
        self.physicsWorld.gravity = CGVectorMake(0, -9.8)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        clearButton = SKLabelNode(text: "Clear Items")
        clearButton.fontColor = UIColor.blackColor()
        clearButton.fontSize = 20
        clearButton.position = CGPoint(x: self.size.width/2, y: self.size.height-25)
        self.addChild(clearButton)
    }
    
    func setupGlobals(){
        currentDrawing.strokeColor = UIColor.blackColor()
        currentDrawing.lineWidth = lineWidth
    }
    
    func setupGestureRecognizers(){
        self.view?.addGestureRecognizer(UITapGestureRecognizer(target:self, action:Selector("handleTap:")))
        self.view?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: Selector("handlePan:")))
    }
    
    func handleTap(tapReco:UITapGestureRecognizer){
        let touchLoc = self.convertPointFromView(tapReco.locationInView(tapReco.view))
        
        var nodes = self.nodesAtPoint(touchLoc)
        for node in nodes{
            if node as! SKNode == clearButton{
                for item in objectArray {
                    item.removeFromParent()
                }
                objectArray = Array<SKNode>()
            }
        }
    }
    
    func handlePan(panReco:UIPanGestureRecognizer){
        let touchLoc = self.convertPointFromView(panReco.locationInView(panReco.view))
        
        if panReco.state == UIGestureRecognizerState.Began{
            CGPathMoveToPoint(currentPath, nil, touchLoc.x, touchLoc.y)
        }
        else if panReco.state == UIGestureRecognizerState.Changed{
            CGPathAddLineToPoint(currentPath, nil, touchLoc.x, touchLoc.y)
            adjustDrawing()
        }
        else if panReco.state == UIGestureRecognizerState.Ended{
            CGPathAddLineToPoint(currentPath, nil, touchLoc.x, touchLoc.y)
            CGPathCloseSubpath(currentPath)
            
            addObject()
            
            currentDrawing.removeFromParent()
            currentPath = CGPathCreateMutable()
        }
    }
    
    func addObject(){
        let shapeNode = SKShapeNode(path: currentPath)
        shapeNode.strokeColor = getRandomColor()
        shapeNode.fillColor = getRandomColor()
        shapeNode.lineWidth = lineWidth
        
        //TRICKY: You must add the node to the scene before calling self.view.textureFromNode()or you will not get the retina (HQ) version of the texture to pass to the SKSpriteNode
        self.addChild(shapeNode)
        let spriteNode = SKSpriteNode(texture: self.view?.textureFromNode(shapeNode), size: shapeNode.frame.size)
        shapeNode.removeFromParent()
        
        //TRICKY: You must set the position of the spriteNode to the center of the shapeNode's frame to maintain alignment
        spriteNode.position = CGPoint(x: shapeNode.frame.width/2, y: shapeNode.frame.height/2)
        spriteNode.physicsBody = SKPhysicsBody(texture: spriteNode.texture, alphaThreshold: 0.99, size: spriteNode.size)
        self.addChild(spriteNode)
        objectArray.append(spriteNode)
    }
    
    func adjustDrawing(){
        currentDrawing.removeFromParent()
        currentDrawing.path = currentPath
        self.addChild(currentDrawing)
    }
    
    func getRandomColor() -> UIColor{
        let hue = (CGFloat(arc4random() % 256)) / 256.0
        let saturation = ((CGFloat(arc4random() % 128)) / 256.0) + 0.5
        let brightness = ((CGFloat(arc4random() % 128)) / 256.0) + 0.5
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
}