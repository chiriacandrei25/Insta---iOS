//
//  SignInViewController.swift
//  Insta
//
//  Created by user169878 on 4/24/20.
//  Copyright © 2020 Algopedia. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var floatingLabel: UILabel!
    @IBOutlet weak var fbLoginButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.backgroundColor = UIColor.clear
        emailTextField.tintColor = UIColor.white
        emailTextField.textColor = UIColor.white
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        let bottomLayerEmail = CALayer()
        bottomLayerEmail.frame = CGRect(x: 0, y:29, width: 1000, height: 5)
        bottomLayerEmail.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        
        emailTextField.layer.addSublayer(bottomLayerEmail)
        
        passwordTextField.backgroundColor = UIColor.clear
        passwordTextField.tintColor = UIColor.white
        passwordTextField.textColor = UIColor.white
        passwordTextField.attributedPlaceholder = NSAttributedString(string:passwordTextField.placeholder!, attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.6)])
        let bottomLayerPassword = CALayer()
        bottomLayerPassword.frame = CGRect(x: 0, y:29, width: 1000, height: 5)
        bottomLayerPassword.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        passwordTextField.layer.addSublayer(bottomLayerPassword)
        
        //animationOnSignIn()
        handleButtons()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       view.endEditing(true)
    }
    
    func handleButtons() {
        emailTextField.addTarget(self, action: #selector(SignInViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignInViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
        fbLoginButton.addTarget(self, action: #selector(loginFB), for: .touchUpInside)

    }
    
    func animationOnSignIn()
    {
          //  print(1)
        	let flash = CABasicAnimation(keyPath: "backgroundColor")
            flash.duration = 1
            flash.fromValue = UIColor.red.cgColor
            flash.toValue = UIColor.blue.cgColor
            flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            flash.autoreverses = true
            flash.repeatCount = 3000
        self.signInButton.layer.add(flash, forKey: "backgroundColor")
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.signInButton.layer.removeAllAnimations()
        self.floatingLabel.layer.removeAllAnimations()
    }
    	
    func animationOnFloatingLabel()
    {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.y"
        animation.values = [-10, 50, -10]
        animation.keyTimes = [0, 0.5, 1]
        animation.duration = 2
        animation.isAdditive = true
        animation.repeatCount = 3000
        self.floatingLabel.layer.add(animation, forKey: "move")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        animationOnSignIn()
        animationOnFloatingLabel()
    }
    
    @objc func loginFB()
    {
        let accessToken = FBSDKLoginKit.AccessToken.current
        guard let accessTokenString = accessToken?.tokenString else
         { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        Auth.auth().signIn(with: credentials, completion: {(user, error) in
            if error != nil
            {
                print("FB login error: ", error as Any)
            }
            print("Successfully logged in with our user")
            self.performSegue(withIdentifier: "signInToTabbarVC", sender: nil)
        })
    }
    
    @objc func textFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty else {
                signInButton.setTitleColor(UIColor.lightText, for: UIControl.State.normal)
                signInButton.isEnabled = false
                return
        }
        
        signInButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        signInButton.isEnabled = true
    }
    
    @IBAction func signInButton_TouchUpInside(_ sender: Any) {
        view.endEditing(true)
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            self.performSegue(withIdentifier: "signInToTabbarVC", sender: nil)
        })
    }
}
