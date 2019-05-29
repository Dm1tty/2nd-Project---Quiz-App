//
//  ViewController.swift
//  SecondProject
//
//  Created by Dzmitry Matsiulka on 5/26/19.
//  Copyright © 2019 Dzmitry Matsiulka. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
   
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var nextQuestionButton: UIButton!
    
    @IBOutlet weak var timerLabel: UILabel!
    var countdownTimer: Timer!
    var totalTime = 15

    
    
    var audioPlayer: AVAudioPlayer?
    
    var currentQuestion = 0
    var score = 0
    
    var questionProvider = QuestionProvider()
    var questions : [Question] = [Question]()
    
    @IBOutlet weak var gameOverView: UIView!
    @IBOutlet weak var gameOverTitle: UILabel!
    @IBOutlet weak var gameOverMessage: UILabel!
    
    
    @IBOutlet weak var answer1Button: UIButton!
    @IBOutlet weak var answer2Button: UIButton!
    @IBOutlet weak var answer3Button: UIButton!
    @IBOutlet weak var answer4Button: UIButton!
  
    
    var arrayOfButtons : [UIButton] = [UIButton]()
    var correctAnswer = ""
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      
        // loading questions from QuesetionProvider.swift
        questions = questionProvider.questionBank
        
       
        startNewGame()
    }
    
    
    
    func startNewGame(){
        currentQuestion = 0
        score = 0
        
        questions.shuffle()
        gameOverView.isHidden = true
        nextQuestion()
        
    }
    
    
    
    
    func nextQuestion(){
        // checking if there are questions left
        if currentQuestion != questions.count{
            
        // triggers when there are questions left
            
            startTimer()
            
        nextQuestionButton.isEnabled = false
        arrayOfButtons = [answer1Button,answer2Button,answer3Button,answer4Button]
           
            //unblock all the buttons which were locked after user picked an answer
            for button in arrayOfButtons{
                button.isEnabled = true
            }
            
            
            arrayOfButtons.shuffle()
            //give the correct answer to a random button
            //delete this button from the array
            arrayOfButtons.last!.setTitle(questions[currentQuestion].correctAnswer, for: .normal)
                arrayOfButtons.removeLast()
            
                fillButtonsWithDummyAnswers()
            
            
            // UPDATING UI WITH NEW QUESTION
        questionLabel.text = questions[currentQuestion].question
        correctAnswer = questions[currentQuestion].correctAnswer
        
            
        currentQuestion+=1
        questionNumberLabel.text = "Question: \(currentQuestion)/15"
        
}
        else{
            //no questions left
            print("Game over!")
           finishTheGame()
        }
    }
    
    
    @IBAction func answerButtonWasPressed(_ sender: UIButton) {
        endTimer()
        checkCorrectness(correct: correctAnswer, chosen: sender.titleLabel!.text!)
       
        // blocks all the buttons and unlocks them when a new question appears
        answer1Button.isEnabled = false
        answer2Button.isEnabled = false
        answer3Button.isEnabled = false
        answer4Button.isEnabled = false
    }
    
    func checkCorrectness(correct: String, chosen: String){
        if correct==chosen{
            
            print("You got it right!")
            score += 1
            
            playSound(whichOne: "correct")
            questionLabel.text = "You got it right."
            nextQuestionButton.isEnabled = true
        }
        else{
            print("You didnt get it right!")
            playSound(whichOne: "wrong")
            
            questionLabel.text = "You didn't get it right. The correct answer was \(questions[currentQuestion-1].correctAnswer)."
            nextQuestionButton.isEnabled = true
        }
        }
    
    
    func playSound(whichOne: String){
            do {
                if let fileURL = Bundle.main.path(forResource: whichOne, ofType: "wav") {
                    audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
                    audioPlayer?.play()
                } else {
                    print("No file with specified name exists")
                }
            } catch let error {
                print("Can't play the audio file failed with an error \(error.localizedDescription)")
            }
        }
    
    
    func startTimer() {
        totalTime = 15
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    @objc func updateTime() {
        timerLabel.text = "\(timeFormatted(totalTime))"
        
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
        }
    }
    
    func endTimer() {
        countdownTimer.invalidate()
        print("You didnt get it right!")
        playSound(whichOne: "wrong")
        
        questionLabel.text = "You didn't get it right. The correct answer was \(questions[currentQuestion-1].correctAnswer)."
        
        nextQuestionButton.isEnabled = true
        
        arrayOfButtons = [answer1Button,answer2Button,answer3Button,answer4Button]
        for button in arrayOfButtons{
            button.isEnabled = false
        }
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
    }

    
    
    @IBAction func nextQuestionButtonWasPressed(_ sender: Any) {
    nextQuestion()
    }

    
    @IBAction func restartQuiz(_ sender: Any) {
        startNewGame()
    }
    
    func finishTheGame(){
        gameOverView.isHidden = false
        gameOverTitle.text = "You got \(score)/15"
        
        switch score{
        case 15: gameOverMessage.text = "Great job. You got them all. Thank you for playing my game"
        case 12...14: gameOverMessage.text = "Good job. You can do better, just do it again."
        case 8...11: gameOverMessage.text = "You did okay, but definetely try one more time."
        default:
            gameOverMessage.text = "Someone doesn't know the lyrics at all. Do it again."
        }
    }
    
    
    func fillButtonsWithDummyAnswers(){
        var dummyIndexes = [Int]()
        var i = 0
        
        while dummyIndexes.count < 3{
            let randomNumber = Int.random(in: 0..<questions.count)
           
            if !dummyIndexes.contains(randomNumber) && currentQuestion != randomNumber{
                dummyIndexes.append(randomNumber)
            }
        }
        for int in dummyIndexes{
            arrayOfButtons[i].setTitle(questions[int].correctAnswer, for: .normal)
            i += 1
        }
    }
}

    
    


