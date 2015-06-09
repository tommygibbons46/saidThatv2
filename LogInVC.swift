//
//  LogInVC.swift
//  ParseStarterProject
//
//  Created by Thomas Gibbons on 5/6/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit


class LogInVC: UIViewController, UITextFieldDelegate
{
    
    @IBOutlet weak var cloud: UIImageView!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var currentUserPhoneNumber : String?
    var theCurrentUser : PassiveUser?
    @IBOutlet weak var flipCloud: UIImageView!
    var formattedPhoneNumber : String?
    let numberToolbar : UIToolbar = UIToolbar()

    @IBOutlet weak var logIngButton: UIButton!
    @IBOutlet weak var puffyCloud: UIImageView!
    
    @IBOutlet weak var phoneNumberCloud: UIImageView!

    
    @IBOutlet weak var passwordCloud: UIImageView!
    
    override func viewDidAppear(animated: Bool)
    {
        self.queryLocalDataStore()

    }
    override func viewWillAppear(animated: Bool) {
        self.cloud.hidden = false
        self.phoneNumberTextField.hidden = false
        self.passwordTextField.hidden = true
        self.flipCloud.hidden = true
        self.logIngButton.enabled = false
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let phoneNumber: AnyObject? = defaults.objectForKey("phoneNumber")
        if phoneNumber != nil
        {
            self.phoneNumberTextField.text = phoneNumber as! String
        }
    }
    
    
    @IBAction func logInButtonTap(sender: UIButton)
    {
        self.manualLogIn()
    }
    
    func showAlert(withString: String)
    {
        let alert = UIAlertController(title: "There was an error with your password/username combination", message: withString, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "oKay", style: .Cancel, handler:
            {
                (action2) -> Void in
                self.passwordTextField.text = ""
            })
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func signUpButtonTap(sender: UIButton)
    {
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.passwordTextField.secureTextEntry = true
        numberToolbar.barStyle = UIBarStyle.Default
        numberToolbar.items=[
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Bordered, target: self, action: "hoopla"),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.Plain , target: self, action: "boopla")
        ]
        self.passwordTextField.delegate = self
        self.phoneNumberTextField.delegate = self
        numberToolbar.sizeToFit()
        phoneNumberTextField.inputAccessoryView = numberToolbar
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("SignupVC") as! SignupVC
        
    }
    
    func manualLogIn()
    {
        let logInQuery = PassiveUser.query()
        let phoneNumber = self.phoneNumberTextField.text
        let aString = phoneNumber.stringByReplacingOccurrencesOfString("+1", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let chars: [Character] = ["(", ")", "-", " ", "+"]
        formattedPhoneNumber = aString.stripCharactersInSet(chars)
        logInQuery!.whereKey("phoneNumber", equalTo: formattedPhoneNumber!)
        logInQuery?.whereKey("password", equalTo: self.passwordTextField.text.lowercaseString)
        logInQuery?.whereKey("verified", equalTo: 1)
        logInQuery!.findObjectsInBackgroundWithBlock
            {
                (returnedObjects, returnedError) -> Void in
                if returnedError == nil
                {
                    //println("we found: \(returnedObjects)")
                    if let usersArray = returnedObjects as? [PassiveUser]
                    {
                        for foundUser in usersArray
                        {
                            self.theCurrentUser = foundUser
                            let nextVC = QuotesVC(nibName: "QuotesVC", bundle: nil)
                            nextVC.theCurrentUser = foundUser
                            println(nextVC.theCurrentUser)
                            let defaults = NSUserDefaults.standardUserDefaults()
                            defaults.setObject(self.theCurrentUser?.phoneNumber, forKey: "phoneNumber")
                            defaults.setBool(true, forKey: "verified")
                            self.dismissViewControllerAnimated(true, completion: nil)
                            
                        }
                    }
                    else
                    {
                        println("won't let us in!")
                        let defaults = NSUserDefaults.standardUserDefaults()
                        defaults.setObject(self.formattedPhoneNumber, forKey: "phoneNumber")
                        defaults.setBool(true, forKey: "verified")
                        self.dismissViewControllerAnimated(true, completion: nil)
//                        but let's try to break through anyway
                        
                    }
                    if returnedObjects?.count > 0
                    {
                        //println("we found: \(returnedObjects)")
                    }
                    else
                    {
                        //println("there was an error: \(returnedError)")
                        let newQuery = PassiveUser.query()
                        newQuery?.whereKey("phoneNumber", equalTo: self.formattedPhoneNumber!)
                        newQuery?.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
                            if returnedError == nil
                            {
                                if results!.count > 0
                                {
                                    //println(self.formattedPhoneNumber)
                                    self.showAlert("...we recognize that number though...if you forgot your password, you can reset it by signing up again with the same phone number")
                                    self.passwordTextField.text = ""
                                }
                                else
                                {
                                    self.showAlert("We don't know anyone with that phone number, are you sure you signed up?")
                                    self.phoneNumberTextField.text = ""
                                    self.passwordTextField.text = ""
                                }
                            }
                        })
                    }
                }
        }
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) ///log in button is only enbaled once the user has entered a password
    {
        if textField == passwordTextField
        {
            logIngButton.enabled = true
        }
    }
    
    func boopla () {
        phoneNumberTextField.resignFirstResponder()
        phoneNumberTextField.hidden = true
        self.cloud.hidden = true
        self.flipCloud.hidden = false
        passwordTextField.hidden = false
        passwordTextField.becomeFirstResponder()

    }
    
    func hoopla () {
        phoneNumberTextField.text=""
        phoneNumberTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        passwordTextField.resignFirstResponder()
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "toSignUp"
        {
            
        }
        else
        {
            let quotesVC = segue.destinationViewController as! QuotesVC
            quotesVC.theCurrentUser = self.theCurrentUser
        }

    }
    
    
    func successfulSignUp(yes: Bool, forUser: PassiveUser)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    ///signUpVC delegate
    
    func queryLocalDataStore()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let objectId: AnyObject? =  defaults.objectForKey("verified")
        if objectId != nil
        {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    
    

}
