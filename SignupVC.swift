//
//  SignupVC.swift
//  ParseStarterProject
//
//  Created by Thomas Gibbons on 5/6/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
protocol successSignUp
{
    func successfulSignUp(yes:Bool)
    
}

class SignupVC: UIViewController, UITextFieldDelegate
{

    @IBOutlet weak var flatbubbleFlip: UIImageView!
    @IBOutlet weak var flatBubble: UIImageView!
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    var updateAnExisting : Bool?
    var theCurrentUser : PassiveUser?
    var formattedPhoneNumber : String?
    var delegate: successSignUp?
    let numberToolbar : UIToolbar = UIToolbar()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.phoneNumberTextField.becomeFirstResponder()
        self.passwordTextField.secureTextEntry = true
        self.passwordTextField.delegate = self
        self.firstNameTextField.hidden = true
        self.lastNameTextField.hidden = true
        self.passwordTextField.hidden = true
        self.flatbubbleFlip.hidden = true
        self.signUpButton.hidden = true
        numberToolbar.barStyle = UIBarStyle.Default
        numberToolbar.items=[
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Bordered, target: self, action: "hoopla"),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.Plain , target: self, action: "boopla")
        ]
        numberToolbar.sizeToFit()
        phoneNumberTextField.inputAccessoryView = numberToolbar

    }
    
    func boopla () {
        phoneNumberTextField.resignFirstResponder()
        phoneNumberTextField.hidden = true
        self.flatBubble.hidden = true
        self.flatbubbleFlip.hidden = false
        firstNameTextField.hidden = false
        firstNameTextField.becomeFirstResponder()
    }
    
    func hoopla () {
        phoneNumberTextField.text=""
        phoneNumberTextField.resignFirstResponder()
    }
    
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        let characterCount = count(phoneNumberTextField.text)
        
        if textField.tag == 1
        {
        if characterCount == 9
        {
        }
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if textField.tag == 2
        {
            self.firstNameTextField.hidden = true
            self.lastNameTextField.hidden = false
            self.flatBubble.hidden = false
            self.flatbubbleFlip.hidden = true
            self.lastNameTextField.becomeFirstResponder()
        }
        else if textField.tag == 3
        {
            self.lastNameTextField.hidden = true
            self.passwordTextField.hidden = false
            self.flatBubble.hidden = true
            self.flatbubbleFlip.hidden = false
            self.passwordTextField.becomeFirstResponder()
        }
        else if textField.tag == 4
        {
            self.passwordTextField.resignFirstResponder()
        }
        
        return true
    }


    @IBAction func signUpButtonTap(sender: UIButton)
    {
        self.signUpPassiveUser()
    }
    
    @IBAction func returnToLogIn(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func signUpPassiveUser()
    {
        //lets check if people talk about this person already
        self.inputValidationCode()
        let phoneNumber = self.phoneNumberTextField.text
        let aString = phoneNumber.stringByReplacingOccurrencesOfString("+1", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let chars: [Character] = ["(", ")", "-", " ", "+"]
        formattedPhoneNumber = aString.stripCharactersInSet(chars)
        let query = PassiveUser.query()
        query!.whereKey("phoneNumber", equalTo: self.formattedPhoneNumber!)
        query!.getFirstObjectInBackgroundWithBlock
            {
                (returnedObjects, returnedError) -> Void in
                if returnedError == nil
                {
                    if returnedObjects != nil
                    {
                        //println("congrats, you already exist, do you want to update your info?")
                        self.updateAnExisting = true
                        if let object = returnedObjects as? PassiveUser
                        {
                            self.theCurrentUser = object
                            self.sendAnotherVerificationCode()
                            self.theCurrentUser!.firstName = self.firstNameTextField.text
                            self.theCurrentUser!.lastName = self.lastNameTextField.text
                            self.theCurrentUser!.password = self.passwordTextField.text.lowercaseString
                            self.theCurrentUser?.saveInBackgroundWithBlock(
                                { (success, error) -> Void in
                                if error == nil
                                    {
                                        //println("successful save")
                                    }
                                })
                        }
                    }
                }
                else
                {
                    //println("nope this person doesn't exist, we'll have to create you")
                    self.sendVerificationCode()
                }
            }
        }
    
    func textFieldDidBeginEditing(textField: UITextField) ///sign in button is only enbaled once the user has entered a password
    {
        if textField == passwordTextField
        {
            signUpButton.hidden     = false
        }
    }
    

    func sendVerificationCode()
    {
        self.theCurrentUser = PassiveUser(className: "PassiveUser")
        theCurrentUser!.password = self.passwordTextField.text.lowercaseString
        theCurrentUser!.phoneNumber = self.formattedPhoneNumber!
        theCurrentUser!.firstName = self.firstNameTextField.text
        theCurrentUser!.lastName = self.lastNameTextField.text
        theCurrentUser!.hasPhoto = 0
        theCurrentUser!.verified = 0
        var userACL = PFACL()
        userACL.setPublicWriteAccess(true)
        userACL.setPublicReadAccess(true)
        theCurrentUser!.ACL = userACL
        theCurrentUser!.saveInBackgroundWithBlock
            {
                (success: Bool, error: NSError?) -> Void in
                if success
                {
                    //println("New Passive User has been saved.")
                    PFCloud.callFunctionInBackground("sendVerificationCode", withParameters: ["phoneNumber": self.formattedPhoneNumber!, "firstName": self.firstNameTextField.text, "password": self.passwordTextField.text.lowercaseString, "lastName": self.lastNameTextField.text]) { (results, error) -> Void in
                        if error == nil
                        {
                            //println("sent verification code")
                        }
                    }
                }
            }
    }
    
    func checkVerificationCode(code: String)
    {
        PFCloud.callFunctionInBackground("verifyPhoneNumber", withParameters: ["phoneNumber":self.formattedPhoneNumber!, "phoneVerificationCode": code], block: { (success, error) -> Void in
            if error == nil
            {
                //println("verification code succeeded")
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(self.formattedPhoneNumber!, forKey: "phoneNumber")
                defaults.setBool(true, forKey: "verified")
                self.dismissViewControllerAnimated(true, completion: nil)
                
//                let alert = UIAlertController(title: "Agree to terms", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
//                alert.addAction(UIAlertAction(title: "I Agree", style: .Cancel, handler:
//                    {
//                        (action1) -> Void in
//                        let defaults = NSUserDefaults.standardUserDefaults()
//                        defaults.setObject(self.formattedPhoneNumber!, forKey: "phoneNumber")
//                        self.dismissViewControllerAnimated(true, completion: nil)
//                }))
//                alert.addAction(UIAlertAction(title: "I do not Agree", style: .Default, handler: nil))
//                
//                alert.addAction(UIAlertAction(title: "View Terms", style: .Default, handler: { (action2) -> Void in
//                    self.performSegueWithIdentifier("terms", sender: nil)
//                }))
//                self.presentViewController(alert, animated: true, completion: nil)
            }
            else
            {
                self.incorrectValidationCode()
            }
        })
    }
    

    
    
    ///we still need to fix this slightly ////
    func incorrectValidationCode()
    {
        
        let alert = UIAlertController(title: "Incorrect validation", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Send another code", style: .Cancel, handler:
            {
                (action1) -> Void in
                self.sendAnotherVerificationCode()
            }))
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    func sendAnotherVerificationCode()
    {
        self.inputValidationCode()
        PFCloud.callFunctionInBackground("sendAnotherVerificationCode", withParameters: ["phoneNumber": formattedPhoneNumber!]) { (results, error) -> Void in
            if error == nil
            {
                //println("sent verification code")
            }
        }
        
    }
    
    func inputValidationCode()
    {
        let alert = UIAlertController(title: "Validation", message: "A validation code has been sent to the number provided", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler
            {
                (textField) -> Void in
                textField.placeholder = "Validation Code"
                textField.keyboardType = UIKeyboardType.NumberPad
            }
        
        alert.addAction(UIAlertAction(title: "oKay", style: .Default, handler:
            {
                (action1) -> Void in
                
                let verificationTextField = alert.textFields![0] as! UITextField
                let verificationCode = verificationTextField.text
                
                self.checkVerificationCode(verificationCode)
                
            }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler:
            {
                (action1) -> Void in
                
            }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func unwindToSegue (segue : UIStoryboardSegue) {}

}
