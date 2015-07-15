//
//  GameScene.swift
//  Gravity Cube
//
//  Created by Mac User on 7/7/15.
//  Copyright (c) 2015 Keith Kaiser. All rights reserved.
//




//17 and 56

import SpriteKit
import iAd
import StoreKit
import MediaPlayer

var removeBanner = 0

//Function to make putting in colors using hexes a lot easier
func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
//Collision bitmasks
enum bodyType: UInt32 {
    case Cube = 1
    case TopEnemy = 2
    case BottomEnemy = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate, ADBannerViewDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    var play = SKSpriteNode(imageNamed: "play.png")
    var help = SKSpriteNode(imageNamed: "help.png")
    var noAds = SKSpriteNode(imageNamed: "no_ads.png")
    var logo = SKSpriteNode(imageNamed: "logo.png")
    var endGame = false
    
    //Init all of the objects
    var cube = SKShapeNode()
    var topRect = SKShapeNode()
    var bottomRect = SKShapeNode()
    var topEnemy = SKShapeNode()
    var bottomEnemy = SKShapeNode()
    var scoreLabel = SKLabelNode()
    var highScoreLabel = SKLabelNode()
    var speedUp = SKLabelNode()
    var endBackground = SKShapeNode()
    var fScreenNode = SKShapeNode()
    var retryNode = SKShapeNode()
    var removeAdsNode = SKShapeNode()
    var removeAdsLabel = SKLabelNode()
    var instructions = SKSpriteNode(imageNamed: "instructions.png")
    var retry = SKLabelNode()
    var bannerView: ADBannerView!
    var contactDetector = false
    var enemyColor = UIColor()
    var bgColor = UIColor()
    var labelColor = UIColor()
    var refresh = SKSpriteNode(imageNamed: "refresh.png")
    var ableToPurchase = true
    
    var back = SKSpriteNode(imageNamed: "back.png")
    
    //Bools, intergers, and other random
    var number = 0
    var counter = -1
    var score = 0
    var highScore: Int!
    var restart = false
    var spawn = true
    var newCount = false
    var newNewCount = false
    var newNewNewCount = false
    var wait = false
    var waitTime = 120
    var otherNumber = 1
    var adNumber = -1

    var noAdBool = NSUserDefaults.standardUserDefaults().boolForKey("noMoreAds")
    
    //Function that deletes ads from the scene
    func noMoreAds() {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "noMoreAds")
        NSUserDefaults.standardUserDefaults().synchronize()
        adNumber = -1
        noAds = SKSpriteNode(imageNamed: "NoImage")
        removeBanner = 1
        ableToPurchase = false
    }
    

    
    override func didMoveToView(view: SKView) {
        physicsWorld.contactDelegate = self
        
        //Creating scene sizes so the app works universally
        let scene = self.frame.size
        let sceneWidth = self.frame.width
        let sceneHeight = self.frame.height
        
        //The three main color groups in the game
        bgColor = UIColor.whiteColor()
        enemyColor = UIColor.brownColor()
        labelColor = UIColor.blackColor()
        
        //Starting bg color
        backgroundColor = UIColor.whiteColor()
        
        //The NSUserDefault for if there is ads
        if NSUserDefaults.standardUserDefaults().boolForKey("noMoreAds") == false {
            adNumber = 2
            println("still ads")
        }
        else {
            adNumber = -1
            ableToPurchase = false
            removeBanner = 1
            noAds = SKSpriteNode(imageNamed: "NoImage")
        }
        
        
  
        if ableToPurchase == false {
            removeBanner = 1
            adNumber = -1
            noAds = SKSpriteNode(imageNamed: "NoImage")
        }
        
        //Make the cube
        cube = SKShapeNode(rectOfSize: CGSizeMake(sceneHeight/25, sceneHeight/25))
        cube.position = CGPointMake(sceneWidth/8, sceneHeight/2.15)
        cube.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(sceneHeight/25, sceneHeight/25))
        cube.physicsBody?.dynamic = true
        cube.physicsBody?.affectedByGravity = false
        cube.physicsBody?.restitution = 0
        cube.physicsBody?.friction = 0
        cube.physicsBody?.categoryBitMask = bodyType.Cube.rawValue
        cube.physicsBody?.collisionBitMask = bodyType.TopEnemy.rawValue
        cube.physicsBody?.contactTestBitMask = bodyType.TopEnemy.rawValue
        
        
        
        
        //making top and bottom barriers
        topRect = SKShapeNode(rectOfSize: CGSizeMake(sceneWidth, sceneHeight/40))
        topRect.position = CGPointMake(sceneWidth/2, sceneHeight/1.8)
        topRect.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(sceneWidth, sceneHeight/40))
        topRect.physicsBody?.dynamic = false
        topRect.physicsBody?.restitution = 0
        topRect.physicsBody?.friction = 0
        

        
        bottomRect = SKShapeNode(rectOfSize: CGSizeMake(sceneWidth, sceneHeight/40))
        bottomRect.position = CGPointMake(sceneWidth/2, sceneHeight/2.3)
        bottomRect.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(sceneWidth, sceneHeight/40))
        bottomRect.physicsBody?.dynamic = false
        bottomRect.physicsBody?.restitution = 0
        bottomRect.physicsBody?.friction = 0
        
        
        // Set IAPS
        if(SKPaymentQueue.canMakePayments()) {
            println("IAP is enabled, loading")
            var productID:NSSet = NSSet(objects: "com.keithkaiser.gravitycube.removeads")
            var request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as Set<NSObject>)
            request.delegate = self
            request.start()
        } else {
            println("please enable IAPS")
        }

        //No Enemies
        var counter = -1
        
        //Properties for score label
        scoreLabel = SKLabelNode(fontNamed: "Exo2-SemiBoldItalic")
        scoreLabel.fontSize = 60
        scoreLabel.position = CGPointMake(sceneWidth/2,sceneHeight/1.5)
        
        //Detecting width and height in interger form
            var bounds = UIScreen.mainScreen().bounds
            var width = bounds.size.width
            var height = bounds.size.height
        
        //All of the menu buttons
        play.name = "playButton"
        play.position = CGPointMake(sceneWidth/2, sceneHeight/2)
        play.userInteractionEnabled = false
        if width < 1024 {
            play.setScale(0.25)
        }
        else {
            play.setScale(0.5)
        }
        self.addChild(play)
        
        instructions.position = CGPointMake(sceneWidth/2, sceneHeight/2)

        
        help.name = "helpButton"
        help.position = CGPointMake(sceneWidth/20, sceneHeight/4)
        help.userInteractionEnabled = false
        help.setScale(0.25)
        self.addChild(help)
        
        back.name = "back"
        back.position = CGPointMake(sceneWidth/20, sceneHeight/1.25)
        back.userInteractionEnabled = false
        back.setScale(0.25)
        
        noAds.name = "noMoreAds"
        noAds.position = CGPointMake(sceneWidth/8, sceneHeight/4)
        noAds.userInteractionEnabled = false
        noAds.setScale(0.5)
        self.addChild(noAds)
        
        refresh.name = "refresh"
        refresh.position = CGPointMake(sceneWidth/5, sceneHeight/4)
        refresh.userInteractionEnabled = false
        refresh.setScale(0.25)
        refresh.zPosition = 300
        self.addChild(refresh)
        
        logo.position = CGPointMake(sceneWidth/2, sceneHeight/1.5)
        self.addChild(logo)
    
        
        
        
        
     
    }
    //Unused function?
    func removeChildren() {
        let sceneWidth = self.frame.width
        let sceneHeight = self.frame.height
        
        var fScreenNode = SKShapeNode(rectOfSize: CGSizeMake(sceneWidth, sceneHeight))
        fScreenNode.zPosition = 200
        fScreenNode.position = CGPointMake(sceneWidth/2, sceneHeight/2)
        self.addChild(fScreenNode)
        
    }
    
    

    //Function for when contact starts
    func didBeginContact(contact: SKPhysicsContact) {
        let scene = self.frame.size
        let sceneWidth = self.frame.width
        let sceneHeight = self.frame.height
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch(contactMask) {
        case bodyType.Cube.rawValue | bodyType.TopEnemy.rawValue:
            println("Contact Made")
            endGame = true
            highScoreLabel = SKLabelNode(fontNamed: "Exo2-SemiBoldItalic")
            highScoreLabel.fontSize = 30
            highScoreLabel.position = CGPointMake(sceneWidth/2, sceneHeight/4)
            highScoreLabel.text = "High Score: \(highScore)"
            highScoreLabel.zPosition = 51
            
            retryNode = SKShapeNode(rectOfSize: CGSizeMake(sceneWidth/8, sceneHeight/8))
            retryNode.name = "retry"
            retryNode.userInteractionEnabled = false
            retryNode.position = CGPointMake(sceneWidth/2, sceneHeight/2)
            retryNode.zPosition = 70
            
            retry = SKLabelNode(fontNamed: "Exo2-SemiBoldItalic")
            retry.text = "Retry"
            retry.name = "retry"
            retry.fontSize = 30
            retry.position = CGPointMake(sceneWidth/2, sceneHeight/2)
            retry.zPosition = 70

            
            
            number = 0
            counter = -1
            spawn = false
            contactDetector = true
            
            
            //Setting the interger for high score if it is the first launch on the device
            let firstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("FirstLaunch")
            if firstLaunch {
                println("Not First Launch")
            }
            else {
                println("First launch, setting default")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstLaunch")
                NSUserDefaults.standardUserDefaults().integerForKey("highscore")
                NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "highscore")
                NSUserDefaults.standardUserDefaults().synchronize()
            }


        default:
            return
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let sceneHeight = self.frame.height
        
        if endGame == false {
        //Make the impulses different based on what position the cube is at
        cube.physicsBody?.dynamic = true
        func pushUp(){
            cube.physicsBody!.applyImpulse(CGVectorMake(0, 40))
        }
        func pushDown() {
            cube.physicsBody!.applyImpulse(CGVectorMake(0, -40))
        }
        if cube.position.y > sceneHeight/2 {
            pushDown()
        }
        else{
            pushUp()
        }
        }
        let touch =  touches.first as? UITouch
        let positionInScene = touch!.locationInNode(self)
        let touchedNode = self.nodeAtPoint(positionInScene)
        if endGame == true {
            if let name = touchedNode.name {
                if name == "retry" {
            self.removeAllChildren()
            self.retry.removeFromParent()
            self.retryNode.removeFromParent()
            self.highScoreLabel.removeFromParent()
            topEnemy.removeFromParent()
            bottomEnemy.removeFromParent()
            self.addChild(cube)
            self.addChild(scoreLabel)
            self.addChild(topRect)
            self.addChild(bottomRect)

            counter = 25
            newCount = false
            newNewCount = false
            newNewNewCount = false
            number = 1
            otherNumber = 1
            contactDetector = false
            
            score = 0
            endGame = false
            spawn = true
            }
            }

        }

        
        if let name = touchedNode.name
        {
            if name == "playButton"
            {
                self.refresh.removeFromParent()
                self.removeAdsNode.removeFromParent()
                self.removeAdsLabel.removeFromParent()
                self.logo.removeFromParent()
                self.noAds.removeFromParent()
                self.help.removeFromParent()
                
                self.addChild(cube)
                self.addChild(topRect)
                self.addChild(bottomRect)
                self.addChild(scoreLabel)
            
                self.play.removeFromParent()
                counter = 30
                number = 1
            }
        }
        
        if let name = touchedNode.name{
        if name == "helpButton" {
            self.logo.removeFromParent()
            self.help.removeFromParent()
            self.noAds.removeFromParent()
            self.play.removeFromParent()
            self.refresh.removeFromParent()
            self.addChild(instructions)
            self.addChild(back)
        }
        }
        if let name = touchedNode.name {
            if name == "back" {
                self.instructions.removeFromParent()
                self.back.removeFromParent()
                self.addChild(help)
                self.addChild(noAds)
                self.addChild(play)
                self.addChild(logo)
                self.addChild(refresh)
            }
        }
        if let name = touchedNode.name {
            if name == "noMoreAds" {
                if ableToPurchase == true {
                    for product in list {
                        var prodID = product.productIdentifier
                        if(prodID == "com.keithkaiser.gravitycube.removeads") {
                            p = product
                            buyProduct()
                            break;
                        }
                    }
                }
            }

                }
        if let name = touchedNode.name {
            if name == "refresh" {
                SKPaymentQueue.defaultQueue().addTransactionObserver(self)
                SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
            }
        }
            
        }
        
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        cube.physicsBody?.dynamic = false



    }
    
   
    override func update(currentTime: CFTimeInterval) {
        //specify frame sizes
        let scene = self.frame.size
        let sceneWidth = self.frame.width
        let sceneHeight = self.frame.height
        
        let random = arc4random_uniform(2)
        
        func createEnemies() {
            if random == 0 {
                topEnemy = SKShapeNode(rectOfSize: CGSizeMake(sceneHeight/35, sceneHeight/25))
                topEnemy.position = CGPointMake(sceneWidth/1.01, sceneHeight/1.9)
                topEnemy.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(sceneHeight/35, sceneHeight/25))
                topEnemy.physicsBody?.affectedByGravity = false
                topEnemy.physicsBody?.restitution = 0
                topEnemy.physicsBody?.friction = 0
                topEnemy.physicsBody!.categoryBitMask = bodyType.TopEnemy.rawValue
                topEnemy.zPosition = 49
                
                self.addChild(topEnemy)
                topEnemy.physicsBody!.applyImpulse(CGVectorMake(-20,0))
                
                if score > 30 {
                    topEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                    wait = true
                    
                    bgColor = UIColor.blackColor()
                    enemyColor = UIColorFromRGB(0x6600CC)
                    labelColor = UIColorFromRGB(0xCC99FF)
                }
                if score > 60 {
                    topEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                    wait = true
                    
                    
                    bgColor = UIColor.whiteColor()
                    enemyColor = UIColorFromRGB(0x00994C)
                    labelColor = UIColorFromRGB(0x66FF66)
                }
                if score > 80{
                    topEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                    wait = true
                    newCount = true
                    bgColor = UIColorFromRGB(0xFF9999)
                    enemyColor = UIColorFromRGB(0xFF3333)
                    labelColor = UIColor.whiteColor()
                }
                if score > 100 {
                    topEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                    wait = true
                    bgColor = UIColor.blackColor()
                    enemyColor = UIColorFromRGB(0x808080)
                    labelColor = UIColor.whiteColor()
                }
                if score > 120 {
                    topEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                    wait = true
                    
                    newNewCount = true
                    
                    bgColor = UIColor.whiteColor()
                    enemyColor = UIColor.brownColor()
                    labelColor = UIColor.blackColor()
                }
                if score > 140 {
                    topEnemy.physicsBody!.applyImpulse(CGVectorMake(-5, 0))
                    wait = true
                    
                    bgColor = UIColor.blackColor()
                    enemyColor = UIColorFromRGB(0x6600CC)
                    labelColor = UIColorFromRGB(0xCC99FF)
                }

                
            }
            else if random == 1 {
                bottomEnemy = SKShapeNode(rectOfSize: CGSizeMake(sceneHeight/35, sceneHeight/25))
                bottomEnemy.position = CGPointMake(sceneWidth/1.01, sceneHeight/2.15)
                bottomEnemy.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(sceneHeight/35, sceneHeight/25))
                bottomEnemy.physicsBody?.affectedByGravity = false
                bottomEnemy.physicsBody?.restitution = 0
                bottomEnemy.physicsBody?.friction = 0
                bottomEnemy.physicsBody!.categoryBitMask = bodyType.TopEnemy.rawValue
                bottomEnemy.zPosition = 49
                
                self.addChild(bottomEnemy)
                bottomEnemy.physicsBody!.applyImpulse(CGVectorMake(-20,0))
                if score > 30 {
                    bottomEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                    wait = true
                    
                    bgColor = UIColor.blackColor()
                    enemyColor = UIColorFromRGB(0x6600CC)
                    labelColor = UIColorFromRGB(0xCC99FF)
                }
                if score > 60{
                    bottomEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                    wait = true
                    
                    bgColor = UIColor.whiteColor()
                    enemyColor = UIColorFromRGB(0x00994C)
                    labelColor = UIColorFromRGB(0x66FF66)
                }
                if score > 80 {
                    bottomEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                    wait = true
                    
                    bgColor = UIColorFromRGB(0xFF9999)
                    enemyColor = UIColorFromRGB(0xFF3333)
                    labelColor = UIColor.whiteColor()
                }
                if score > 100 {
                    bottomEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                    wait = true
                    
                    bgColor = UIColor.blackColor()
                    enemyColor = UIColorFromRGB(0x808080)
                    labelColor = UIColor.whiteColor()
                }
                if score > 120 {
                    bottomEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                    wait = true
                    
                    bgColor = UIColor.whiteColor()
                    enemyColor = UIColor.brownColor()
                    labelColor = UIColor.blackColor()
                }
                if score > 140 {
                    bottomEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                    wait = true
                    
                    bgColor = UIColor.blackColor()
                    enemyColor = UIColorFromRGB(0x6600CC)
                    labelColor = UIColorFromRGB(0xCC99FF)
                }
            }
            else {
                var random2 = arc4random_uniform(2)
                if random2 == 1 {
                    topEnemy = SKShapeNode(rectOfSize: CGSizeMake(sceneHeight/35, sceneHeight/25))
                    topEnemy.position = CGPointMake(sceneWidth/1.01, sceneHeight/1.9)
                    topEnemy.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(sceneHeight/35, sceneHeight/25))
                    topEnemy.physicsBody?.affectedByGravity = false
                    topEnemy.physicsBody?.restitution = 0
                    topEnemy.physicsBody?.friction = 0
                    topEnemy.physicsBody!.categoryBitMask = bodyType.TopEnemy.rawValue
                    topEnemy.zPosition = 49
                    
                    self.addChild(topEnemy)
                    topEnemy.physicsBody!.applyImpulse(CGVectorMake(-20,0))
                    if score > 30 {
                        topEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                        wait = true
                        
                        bgColor = UIColor.blackColor()
                        enemyColor = UIColorFromRGB(0x6600CC)
                        labelColor = UIColorFromRGB(0xCC99FF)
                    }
                    if score > 60 {
                        topEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                        wait = true
                        
                        bgColor = UIColor.whiteColor()
                        enemyColor = UIColorFromRGB(0x00994C)
                        labelColor = UIColorFromRGB(0x66FF66)
                    }
                    if score > 80 {
                        topEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                        wait = true
                        newCount = true
                        bgColor = UIColorFromRGB(0xFF9999)
                        enemyColor = UIColorFromRGB(0xFF3333)
                        labelColor = UIColor.whiteColor()
                    }
                    if score > 100 {
                        topEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                        wait = true
                        
                        bgColor = UIColor.blackColor()
                        enemyColor = UIColorFromRGB(0x808080)
                        labelColor = UIColor.whiteColor()
                    }
                    if score > 120 {
                        topEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                        wait = true
                        
                        bgColor = UIColor.whiteColor()
                        enemyColor = UIColor.brownColor()
                        labelColor = UIColor.blackColor()
                    }
                    if score > 140 {
                        topEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                        wait = true
                        
                        bgColor = UIColor.blackColor()
                        enemyColor = UIColorFromRGB(0x6600CC)
                        labelColor = UIColorFromRGB(0xCC99FF)
                    }
                }
                else {
                    bottomEnemy = SKShapeNode(rectOfSize: CGSizeMake(sceneHeight/35, sceneHeight/25))
                    bottomEnemy.position = CGPointMake(sceneWidth/1.01, sceneHeight/2.15)
                    bottomEnemy.fillColor = UIColor.brownColor()
                    bottomEnemy.strokeColor = UIColor.brownColor()
                    bottomEnemy.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(sceneHeight/35, sceneHeight/25))
                    bottomEnemy.physicsBody?.affectedByGravity = false
                    bottomEnemy.physicsBody?.restitution = 0
                    bottomEnemy.physicsBody?.friction = 0
                    bottomEnemy.physicsBody!.categoryBitMask = bodyType.TopEnemy.rawValue
                    bottomEnemy.zPosition = 49
                    
                    self.addChild(bottomEnemy)
                    bottomEnemy.physicsBody!.applyImpulse(CGVectorMake(-20,0))
                    if score > 30{
                        bottomEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                        wait = true
                        
                        bgColor = UIColor.blackColor()
                        enemyColor = UIColorFromRGB(0x6600CC)
                        labelColor = UIColorFromRGB(0xCC99FF)
                    }
                    if score > 60  {
                        bottomEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                        wait = true
                        
                        bgColor = UIColor.whiteColor()
                        enemyColor = UIColorFromRGB(0x00994C)
                        labelColor = UIColorFromRGB(0x66FF66)
                    }
                    if score > 80 {
                        bottomEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                        wait = true
                        bgColor = UIColorFromRGB(0xFF9999)
                        enemyColor = UIColorFromRGB(0xFFFFFF)
                        labelColor = UIColor.whiteColor()
                    }
                    if score > 100 {
                        bottomEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                        wait = true
                        
                        bgColor = UIColor.blackColor()
                        enemyColor = UIColorFromRGB(0x808080)
                        labelColor = UIColor.whiteColor()
                    }
                    if score > 120 {
                        bottomEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                        wait = true
                        
                        bgColor = UIColor.whiteColor()
                        enemyColor = UIColor.brownColor()
                        labelColor = UIColor.blackColor()
                    }
                    if score > 140 {
                        bottomEnemy.physicsBody!.applyImpulse(CGVectorMake(-3, 0))
                        wait = true
                        
                        bgColor = UIColor.blackColor()
                        enemyColor = UIColorFromRGB(0x6600CC)
                        labelColor = UIColorFromRGB(0xCC99FF)
                    }
                }
            }
            number = 0
            score++
            
            
            if score > NSUserDefaults.standardUserDefaults().integerForKey("highscore") {
                NSUserDefaults.standardUserDefaults().setInteger(score, forKey: "highscore")
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        scoreLabel.text = "\(score)"
        //removes the nodes once they reach the end of the screen
        self.nodeAtPoint(CGPointMake(sceneWidth/100, sceneHeight/2.15)).removeFromParent()
        self.nodeAtPoint(CGPointMake(sceneWidth/100, sceneHeight/1.9)).removeFromParent()
        

        
        if counter == 0 {
            if newCount == true && newNewCount == false {
                counter = 20
            }
            else if newNewCount == true && newCount == true {
                counter = 15
            }
            else if newNewCount == true && newNewNewCount == true {
                counter = 11
            }
            else {
            counter = 25
            }
            number = 1
        }
        
        if spawn == true {
        if number == 1 {
            createEnemies()
        }
        }
        
        func contactTrue() {
            let setUpGameOver = SKAction.sequence([
                SKAction.waitForDuration(1.3),
                SKAction.runBlock(self.removeChildren)
                ])
            self.runAction(setUpGameOver)
            
            
            if adNumber == -1 {
                
            }
            else if adNumber != -1 && adNumber < 4 {
                adNumber++
            }
            else if adNumber == 4 {
                adNumber = 0
                RevMobAds.session().showFullscreen()
            }
            
            
            
            topEnemy.fillColor = UIColor.whiteColor()
            bottomEnemy.fillColor = UIColor.whiteColor()
            topEnemy.strokeColor = UIColor.whiteColor()
            bottomEnemy.strokeColor = UIColor.whiteColor()
            
            highScoreLabel.fontColor = labelColor
            
            let scaleIn2 = SKAction.scaleTo(2.0, duration: 1.3)
            self.addChild(highScoreLabel)
            highScoreLabel.runAction(scaleIn2)
            self.addChild(retryNode)
            retryNode.runAction(scaleIn2)
            self.addChild(retry)
            retry.runAction(scaleIn2)
            
            
            
            
        }
        
        if contactDetector == true && otherNumber == 1 {
            contactTrue()
            otherNumber = 0
        }

        
        highScore = NSUserDefaults.standardUserDefaults().integerForKey("highscore")
        counter--
        backgroundColor = bgColor
        topEnemy.fillColor = enemyColor
        topEnemy.strokeColor = enemyColor
        bottomEnemy.fillColor = enemyColor
        bottomEnemy.strokeColor = enemyColor
        topRect.fillColor = enemyColor
        topRect.strokeColor = enemyColor
        bottomRect.fillColor = enemyColor
        bottomRect.strokeColor = enemyColor
        scoreLabel.fontColor = labelColor
        cube.fillColor = labelColor
        cube.strokeColor = labelColor
        
        retryNode.fillColor = bgColor
        retryNode.strokeColor = bgColor
        
        retry.fontColor = labelColor
        
        fScreenNode.fillColor = bgColor
        fScreenNode.strokeColor = bgColor
        

        
        
    }
    //In App Purchases
    var list = [SKProduct]()
    var p = SKProduct()
    
    func buyProduct() {
        println("buy " + p.productIdentifier)
        var pay = SKPayment(product: p)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(pay as SKPayment)
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        println("product request")
        var myProduct = response.products
        
        for product in myProduct {
            println("product added")
            println(product.productIdentifier)
            println(product.localizedTitle)
            println(product.localizedDescription)
            println(product.price)
            
            list.append(product as! SKProduct)
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
        println("transactions restored")
        
        var purchasedItemIDS = []
        for transaction in queue.transactions {
            var t: SKPaymentTransaction = transaction as! SKPaymentTransaction
            
            let prodID = t.payment.productIdentifier as String
            
            switch prodID {
            case "com.keithkaiser.gravitycube.removeads":
                println("remove ads")
                noMoreAds()
            default:
                println("IAP not setup")
            }
            
        }
        
        var alert = UIAlertView(title: "Thank You", message: "Your purchase(s) were restored.", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        println("add paymnet")
        
        for transaction:AnyObject in transactions {
            var trans = transaction as! SKPaymentTransaction
            println(trans.error)
            
            switch trans.transactionState {
                
            case .Purchased:
                println("buy, ok unlock iap here")
                println(p.productIdentifier)
                
                let prodID = p.productIdentifier as String
                switch prodID {
                case "com.keithkaiser.gravitycube.removeads":
                    println("remove ads")
                    noMoreAds()
                    var alert = UIAlertView(title: "Thank You", message: "You may have to restart the app before the banner ads are removed.", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                default:
                    println("IAP not setup")
                }
                
                queue.finishTransaction(trans)
                break;
            case .Failed:
                println("buy error")
                queue.finishTransaction(trans)
                break;
            default:
                println("default")
                break;
                
            }
        }
    }
    
    func finishTransaction(trans:SKPaymentTransaction)
    {
        println("finish trans")
    }
    func paymentQueue(queue: SKPaymentQueue!, removedTransactions transactions: [AnyObject]!)
    {
        println("remove trans");
    }
}


