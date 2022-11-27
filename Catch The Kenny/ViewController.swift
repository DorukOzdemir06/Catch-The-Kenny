//
//  ViewController.swift
//  Catch The Kenny
//
//  Created by Doruk Özdemir on 26.11.2022.
//

import UIKit
import AVFoundation

public extension UIView {

    func shake(count : Float = 4,for duration : TimeInterval = 0.5,withTranslation translation : Float = 5) {

        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var leftBorder: UILabel!
    @IBOutlet weak var rightBorder: UILabel!
    @IBOutlet weak var kenny: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var highscore: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var countDown: UILabel!
    
    var tim: Timer!
    var tim2: Timer!
    var tim3: Timer!
    var scoreVar = 0
    var timeVar = 15
    var hscoreVar = 0
    var countDownVar = 3
    var strtmsg: UIAlertController!
    
    //--
    
    func changeColorScore()->Void{
        score.textColor = UIColor.systemYellow
        DispatchQueue.main.asyncAfter(deadline: .now() + 1/3.0) {
            self.score.textColor = UIColor.black
        }
    }
    
    
    let screenSize = UIScreen.main.bounds
    func randomLocationGenerator()->(CGFloat,CGFloat){
        let bottomLimit = time.frame.origin.y + 25
        let topLimit = highscore.frame.origin.y-150
        let wideLimitRight = rightBorder.frame.origin.x-50
        let wideLimitLeft = leftBorder.frame.origin.x+50
        
        return (CGFloat.random(in: wideLimitLeft...wideLimitRight), CGFloat.random(in: bottomLimit...topLimit) )
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        time.text = "Time: \(timeVar)"
        score.text = "Score: \(scoreVar)"
        
        if UserDefaults.standard.object(forKey: "hscore") != nil{
            hscoreVar = UserDefaults.standard.object(forKey: "hscore") as! Int
        }
        highscore.text = "Highscore: \(hscoreVar)"
    }
    
    @objc func increaseScore()->(){
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        score.shake()
        changeColorScore()
        
        scoreVar += 1
        score.text = "Score: \(scoreVar)"
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        strtmsg = UIAlertController(title: "Press 'PLAY' to start the game", message: nil, preferredStyle: .alert)
        
        let startBut = UIAlertAction(title: "PLAY", style: .cancel){
            (UIAlertAction) in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            self.tim = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.cntDown), userInfo: nil, repeats: true)
        }
            
        strtmsg.addAction(startBut)
        
        
        present(strtmsg,animated: true)
        
        
        let pressKenny = UITapGestureRecognizer(target: self, action: #selector( increaseScore ))
        kenny.addGestureRecognizer(pressKenny)
    }
    
    @objc func cntDown()->Void{
        
        
        if(countDownVar == 0) {
            countDown.text = "GO"
            self.kenny.isHidden = false
            countDownVar -= 1
        }
        else if (countDownVar == -1){
            countDown.text = ""
            tim.invalidate()
            tim2 = Timer.scheduledTimer(timeInterval: 1/2.0, target: self, selector: #selector(startGame), userInfo: nil, repeats: true)
            tim3 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timer), userInfo: nil, repeats: true)
            kenny.isUserInteractionEnabled = true
            countDownVar = 3
        }
        else{
            countDown.text = String(countDownVar)
            countDownVar -= 1
        }
        
    }
    
    @objc func startGame()->Void{
        if timeVar > 0{
            
            let (a,b) = randomLocationGenerator()
            
            kenny.frame.origin.x = a
            kenny.frame.origin.y = b
            
        }
        else{
            let msg = UIAlertController(title: "", message: "Time is up!", preferredStyle: .alert)
            
            self.kenny.isHidden = true
            let replayBtn = UIAlertAction(title: "REPLAY", style: .cancel){
                (UIAlertAction) in
                self.scoreVar = 0
                self.timeVar = 15
                self.time.text = "Time: " + String(self.timeVar)
                self.score.text = "Score: " + String(self.scoreVar)
                
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                self.tim = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.cntDown), userInfo: nil, repeats: true)

            }
            
            let okBtn = UIAlertAction(title: "OK", style: .default){ [self]
                (UIAlertAction) in
                present(self.strtmsg,animated: true)
                self.scoreVar = 0
                self.timeVar = 15
                self.time.text = "Time: " + String(self.timeVar)
                self.score.text = "Score: " + String(self.scoreVar)
                
                    
            }
            
            msg.addAction(replayBtn)
            msg.addAction(okBtn)
            
            present(msg,animated: true)
            
            kenny.isUserInteractionEnabled = false
            tim2.invalidate()
            tim3.invalidate()
            
            
            if scoreVar > hscoreVar{
                hscoreVar = scoreVar
                UserDefaults.standard.set(hscoreVar, forKey: "hscore")
                highscore.text = "Highscore: \(hscoreVar)"
            }
        }

    }
    
    @objc func timer()->Void{
        timeVar -= 1
        time.text = "Time: \(timeVar)"
    }
    
    @IBAction func test(_ sender: Any) {
        
        
    }
}

