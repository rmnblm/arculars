//
//  GameViewController.swift
//  Arculars
//
//  Created by Roman Blum on 09/03/15.
//  Copyright (c) 2015 RMNBLM. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
import Social

class GameViewController: UIViewController, SceneDelegate {
    
    private var currentScene : SKScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        #if DEBUG
            /*
            skView.showsDrawCount = true
            skView.showsFPS = true
            skView.showsPhysics = true
            */
        #endif
        
        // Init Easy Game Center Singleton
        let gamecenter = GCHandler.sharedInstance {
            (resultPlayerAuthentified) -> Void in
            if resultPlayerAuthentified {
                // When player is authentified to Game Center
            } else {
                // Player not authentified to Game Center
                // No connexion internet or not authentified to Game Center
            }
        }
        GCHandler.delegate = self
        
        // Present the initial scene.
        if !NSUserDefaults.standardUserDefaults().boolForKey("hasPerformedFirstLaunch") {
            SettingsHandler.reset()
            StatsHandler.reset()
            RateHandler.reset()
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasPerformedFirstLaunch")
            NSUserDefaults.standardUserDefaults().synchronize()
            showHelpScene()
        } else {
            showMenuScene()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func shareScoreOnTwitter(score: Int, gameType: GameMode) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            var twitterSheet : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText("Check out my score in #ARCULARS! Download on " + Strings.ArcularsAppStore)
            twitterSheet.addURL(NSURL(fileURLWithPath: Strings.ArcularsAppStore))
            twitterSheet.addImage(getShareImage(score, gameMode: gameType))
            twitterSheet.completionHandler = {
                result -> Void in
                
                var getResult = result as SLComposeViewControllerResult
                switch(getResult) {
                    case SLComposeViewControllerResult.Cancelled:
                        #if DEBUG
                            println("Sharing on Twitter cancelled.")
                        #endif
                    break
                    case SLComposeViewControllerResult.Done:
                        #if DEBUG
                            println("Sharing on Twitter successful.")
                        #endif
                        GCHandler.reportAchievements(progress: 100.0, achievementIdentifier: "achievement.socialize.twitter", showBannnerIfCompleted: true)
                    break
                    default:
                        #if DEBUG
                            println("Error while sharing on Twitter.")
                        #endif
                    break
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            self.presentViewController(twitterSheet, animated: true, completion: nil)
        } else {
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func shareScoreOnFacebook(score: Int, gameType: GameMode) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            var facebookSheet : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("Check out my score in #ARCULARS! Download on " + Strings.ArcularsAppStore)
            facebookSheet.addURL(NSURL(fileURLWithPath: Strings.ArcularsAppStore))
            facebookSheet.addImage(getShareImage(score, gameMode: gameType))
            facebookSheet.completionHandler = {
                result -> Void in
                
                var getResult = result as SLComposeViewControllerResult
                switch(getResult) {
                case SLComposeViewControllerResult.Cancelled:
                    #if DEBUG
                        println("Sharing on Facebook cancelled.")
                    #endif
                    break
                case SLComposeViewControllerResult.Done:
                    #if DEBUG
                        println("Sharing on Facebook successful.")
                    #endif
                    GCHandler.reportAchievements(progress: 100.0, achievementIdentifier: "achievement.socialize.facebook", showBannnerIfCompleted: true)
                    break
                default:
                    #if DEBUG
                        println("Error while sharing on Facebook.")
                    #endif
                    break
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            self.presentViewController(facebookSheet, animated: true, completion: nil)
        } else {
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func shareScoreOnWhatsApp(score: Int, gameType: GameMode) {
        let textToShare = "Check out Arculars, an addictive App for iOS! Can you beat my high score? Download on " + Strings.ArcularsAppStore
        var escapedString = "whatsapp://send?text=" + textToShare.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        var whatsappURL : NSURL? = NSURL(string: escapedString)
        if (UIApplication.sharedApplication().canOpenURL(whatsappURL!)) {
            UIApplication.sharedApplication().openURL(whatsappURL!)
        }
    }
    
    func shareScoreOnOther(score: Int, gameType: GameMode) {
        let textToShare = "Check out Arculars, an addictive App for iOS! Can you beat my high score? Download on " + Strings.ArcularsAppStore
        let imageToShare = getShareImage(score, gameMode: gameType)
        let objectsToShare = [textToShare]
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        // For iPad only
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.sourceRect = CGRect(origin: CGPoint(x: -(view.frame.width / 2) + ((view.frame.width / 5) * 4), y: -(view.frame.height / 4)), size: CGSize(width: view.frame.width, height: view.frame.height))
        //
        
        activityViewController.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func showMenuScene() {
        // Create and configure the menu scene.
        var scene = MenuScene(size: self.view.bounds.size)
        scene.scaleMode = .AspectFill
        scene.sceneDelegate = self
        (self.view as! SKView).presentScene(scene)
    }
    
    func showGameScene(gameMode: GameMode) {
        // Create and configure the game scene.
        var scene = GameScene(size: self.view.bounds.size)
        scene.scaleMode = .AspectFill
        scene.sceneDelegate = self
        scene.gameMode = gameMode
        (self.view as! SKView).presentScene(scene)
    }
    
    func showStatsScene() {
        // Create and configure the stats scene.
        var scene = StatsScene(size: self.view.bounds.size)
        scene.scaleMode = .AspectFill
        scene.sceneDelegate = self
        (self.view as! SKView).presentScene(scene)
    }
    
    func showSettingsScene() {
        // Create and configure the settings scene.
        var scene = SettingsScene(size: self.view.bounds.size)
        scene.scaleMode = .AspectFill
        scene.sceneDelegate = self
        (self.view as! SKView).presentScene(scene)
    }
    
    func showGameoverScene(gameMode: GameMode) {
        // Create and configure the gameover scene.
        var scene = GameoverScene(size: self.view.bounds.size)
        scene.scaleMode = .AspectFill
        scene.sceneDelegate = self
        scene.gameMode = gameMode
        (self.view as! SKView).presentScene(scene)
    }
    
    func showAboutScene() {
        var scene = AboutScene(size: self.view.bounds.size)
        scene.scaleMode = .AspectFill
        scene.sceneDelegate = self
        (self.view as! SKView).presentScene(scene)
    }
    
    func showHelpScene() {
        var scene = HelpScene(size: self.view.bounds.size)
        scene.scaleMode = .AspectFill
        scene.sceneDelegate = self
        (self.view as! SKView).presentScene(scene)
    }
    
    func presentGameCenter() {
        if !GCHandler.isPlayerIdentifiedToGameCenter() {
            GCHandler.showGameCenterAuthentication(completion: {(result) -> Void in
                GCHandler.showGameCenterAchievements(completion: {(result) -> Void in
                    self.showMenuScene()
                })
            })
        } else {
            GCHandler.showGameCenterAchievements(completion: {(result) -> Void in
                self.showMenuScene()
            })
        }
    }
    
    func presentRateOnAppStore() {
        var refreshAlert = UIAlertController(title: "Rate Arculars", message: "If you enjoy using Arculars, would you mind taking a moment to rate it? It won't take more than a minute. Thanks for your support!", preferredStyle: UIAlertControllerStyle.Alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Rate Arculars", style: .Default, handler: { (action: UIAlertAction!) in
            RateHandler.dontShowAgain()
            let url = NSURL(string: "\(Strings.ArcularsAppStore)")
            UIApplication.sharedApplication().openURL(url!)
        }))
        refreshAlert.addAction(UIAlertAction(title: "Remind me later", style: .Default, handler: { (action: UIAlertAction!) in
            
        }))
        refreshAlert.addAction(UIAlertAction(title: "No, thanks", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction!) in
            RateHandler.dontShowAgain()
        }))
        
        self.presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    // MARK: - HELPER FUNCTIONS
    private func getShareImage(score: Int, gameMode: GameMode) -> UIImage {
        switch gameMode {
        case GameMode.Endless: return ShareImageHelper.createImage(score, image: "shareimage-endless")
        case GameMode.Endless: return ShareImageHelper.createImage(score, image: "shareimage-timed")
        default: return UIImage()
        }
    }
}
