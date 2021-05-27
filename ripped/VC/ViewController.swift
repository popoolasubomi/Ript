//
//  ViewController.swift
//  ripped
//
//  Created by Ogooluwasubomi Ayotomi Popoola on 5/27/21.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var soloBtn: UIButton!
    @IBOutlet weak var challengeBtn: UIButton!
    
    var randUser: PFUser!
    var timeTrack = 0
    var timer = Timer()
    var activityView: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginUser(name: "alice", password: "alice")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        PFUser.current()?.setObject(false, forKey: "looking")
        PFUser.current()?.saveInBackground()
    }
    
    func loginUser(name: String, password: String) {
        PFUser.logInWithUsername(inBackground: name, password: password)
    }
    
    func showActivityIndicatory() {
        let container: UIView = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 80, height: 80) // Set X and Y whatever you want
        container.backgroundColor = .clear

        activityView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityView.center = self.view.center

        container.addSubview(activityView)
        self.view.addSubview(container)
        activityView.startAnimating()
    }
    
    func noRandUserAlert(){
        let alert = UIAlertController(title: "Couldn't find User", message: "No user found", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)

        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
          // your code with delay
          alert.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func getRandUser(){
        let query = PFUser.query()!
        query.whereKey("username", notEqualTo: PFUser.current()!.username!)
        query.whereKey("looking", equalTo: true)
        query.findObjectsInBackground { (objects, error) in
            if (error == nil){
                self.timeTrack += 1
                if (!objects!.isEmpty){
                    self.randUser = (objects![0] as! PFUser)
                    self.timer.invalidate()
                    self.activityView.stopAnimating()
                    self.performSegue(withIdentifier: "challengeSegue", sender: nil)
                } else{
                    if (self.timeTrack == 20){
                        self.timer.invalidate()
                        self.activityView.stopAnimating()
                        self.timeTrack = 0
                        self.noRandUserAlert()
                        PFUser.current()?.setObject(false, forKey: "looking")
                        PFUser.current()?.saveInBackground()
                    }
                }
            }
        }
    }
    
    @IBAction func didTapSolo(_ sender: Any) {
        self.performSegue(withIdentifier: "soloSegue", sender: nil)
    }
    
    @IBAction func didTapChallenge(_ sender: Any) {
        showActivityIndicatory()
        PFUser.current()?.setObject(true, forKey: "looking")
        PFUser.current()?.saveInBackground()
        self.timer = Timer.scheduledTimer(timeInterval: 1,
            target: self,
            selector: #selector(getRandUser),
            userInfo: nil,
            repeats: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "challengeSegue"){
            let randChallengeController = segue.destination as! ChallengeViewController
            randChallengeController.opponent = randUser
        }
    }
}

