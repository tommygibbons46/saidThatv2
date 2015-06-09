//
//  PostQuoteVC.swift
//  saidThat
//
//  Created by Thomas Gibbons on 5/1/15.
//  Copyright (c) 2015 Thomas Gibbons. All rights reserved.
//

import UIKit
import Parse
import AddressBookUI


class PostQuoteVC: UIViewController, UITextViewDelegate, UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate
{
    @IBOutlet weak var submitButtonTap: UIButton!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var quoteTextView: UITextView!
    @IBOutlet weak var placeHolderText: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var otherCloud: UIImageView!
    @IBOutlet weak var originalCloud: UIImageView!
    @IBOutlet weak var saidThat: UILabel!
    @IBOutlet weak var thisPerson: UILabel!
    @IBOutlet weak var quoteItHereButton: UIButton!
    var userToSave: PassiveUser!
    var haveSeenContacts: Bool?
    var isUserActive: Bool?
    var theCurrentUser: PassiveUser?
    var formattedString: String?
    var nameString : String?
    let numberToolbar : UIToolbar = UIToolbar()
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.phoneNumberTextField.delegate = self
        self.quoteTextView.textColor = UIColor.lightGrayColor()
        self.personName.hidden = true
        self.submitButtonTap.hidden = true
        self.haveSeenContacts = false
        self.checkButton.hidden = true
        self.isUserActive = false
        self.otherCloud.hidden=true
        self.profileButton.hidden = true
        self.navigationItem.titleView?.tintColor = UIColor.whiteColor()


//        numberToolbar.barStyle = UIBarStyle.Default
//        numberToolbar.items=[
//            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Bordered, target: self, action: "hoopla"),
//            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil),
//            UIBarButtonItem(title: "Apply", style: UIBarButtonItemStyle.Plain , target: self, action: "boopla")
//        ]
//        numberToolbar.sizeToFit()
//        phoneNumberTextField.inputAccessoryView = numberToolbar
    }
    
    override func viewWillAppear(animated: Bool)
    {
        self.checkButton.hidden = true
    }
    
    override func viewDidAppear(animated: Bool)
    {
        self.checkButton.hidden = true
    }

    @IBAction func profileButtonTap(sender: AnyObject)
    {
        self.checkButton.hidden = true
        self.performSegueWithIdentifier("toProfile", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let profVC = segue.destinationViewController as! ProfileVC
        profVC.theCurrentUser = self.theCurrentUser
        profVC.selectedUser = self.userToSave
        
    }
    
    @IBAction func checkButtonTap(sender: UIButton)
    {
        //query to find user matching this phone number
        let query = PassiveUser.query()
        let phoneNumber = self.phoneNumberTextField.text
        let aString = phoneNumber.stringByReplacingOccurrencesOfString("+1", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        let chars: [Character] = ["(", ")", "-", " ", "+"]
        formattedString = aString.stripCharactersInSet(chars)
        query!.whereKey("phoneNumber", equalTo: formattedString!)
        query!.findObjectsInBackgroundWithBlock
        {
                (returnedObjects, returnedError) -> Void in
                if returnedError == nil
                {
                    if returnedObjects!.count > 0
                    {
                        //println("user is already active")
                        //println(returnedObjects)
                        if let objects = returnedObjects as? [PassiveUser]
                        {
                            for foundUser in objects
                            {
                                self.nameString = NSString(format: "%@ %@", foundUser.firstName, foundUser.lastName) as String
//                                self.personName.hidden = false
                                self.checkButton.hidden = true
//                                self.personName.textAlignment = NSTextAlignment.Center
//                                self.personName.text = nameString as String
                                self.userToSave = foundUser
                                self.profileButton.hidden = false
                                self.profileButton.setTitle(self.nameString, forState: UIControlState.Normal)
                                self.isUserActive = true
                            }
                        }
                    }
                    else
                    {
                        self.giveNewUserInfo()
                    }
                }
        }
    }
    
    @IBAction func profButtonHit(sender: AnyObject)
        {
            //println("prof button tap")
        }
    @IBAction func quoteItHereTap(sender: AnyObject)
    {
        let textLength = count(self.phoneNumberTextField.text)
        
        if textLength > 0
        {
            self.quoteTextView.editable = true
            self.quoteTextView.becomeFirstResponder()
            self.quoteItHereButton.hidden = true
            self.quoteTextView.textColor = UIColor.blackColor()
            self.otherCloud.hidden = false
            self.originalCloud.hidden = true
            self.thisPerson.hidden = true
            self.personName.hidden = true
            self.phoneNumberTextField.hidden = true
            self.saidThat.hidden = true
            self.submitButtonTap.hidden = false
            self.profileButton.hidden = true
            self.navigationItem.titleView?.tintColor = UIColor.whiteColor()
            self.navigationItem.title = self.nameString
            let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
            self.view.addGestureRecognizer(tap)
            
        }
        //what was this doing?
//        if self.personName.hidden == false
//        {
//            self.submitButtonTap.hidden = false
//
//        }
    }
    
    func dismissKeyboard()
    {
        self.quoteTextView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(textView: UITextView)
    {
        
        
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        if haveSeenContacts == false
        {
            self.resignFirstResponder() // should make the keyboard not appear
            let picker = ABPeoplePickerNavigationController()
            picker.peoplePickerDelegate = self
            self.presentViewController(picker, animated: true, completion: nil)
        }
        else
        {
            if self.profileButton.hidden == false
            {
                self.checkButton.hidden = true
            }
            else
            {
                self.checkButton.hidden = false
            }
        }
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecord!)
    {
        let firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty).takeRetainedValue() as! String
        let lastName = ABRecordCopyValue(person, kABPersonLastNameProperty).takeRetainedValue() as! String
        self.nameString = NSString(format: "%@ %@", firstName, lastName) as String
        personName.hidden = false
        checkButton.hidden = true
        self.personName.text = nameString
        let phoneNumbers: ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
        if (ABMultiValueGetCount(phoneNumbers)>0 )
        {
            let index = 0 as CFIndex
            var phoneNumber = ABMultiValueCopyValueAtIndex(phoneNumbers, index).takeRetainedValue() as! String
            self.phoneNumberTextField.text = phoneNumber
            let firstNumber = first(phoneNumber)
            if firstNumber == "1"
            {
                phoneNumber = dropFirst(phoneNumber)
            }
            let aString = phoneNumber.stringByReplacingOccurrencesOfString("+1", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let chars: [Character] = ["(", ")", "-", " ", "+"]
            formattedString = aString.stripCharactersInSet(chars)
            doesThisUserExist(firstName, lastName: lastName, phoneNumber: formattedString!)
        }
        
    }
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController!)
    {
        haveSeenContacts = true
    }
    
    
    
///submit a quote
    @IBAction func submitButtonTap(sender: AnyObject)
    {
        let string = self.personName.text! + " " + "saidThat!"
        let alert = UIAlertController(title: self.quoteTextView.text, message: string, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "saidThat", style: .Default , handler:
            {
                (action2) -> Void in
                alert .dismissViewControllerAnimated(true, completion: nil)
                self.saveQuoteforUser()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default , handler:
            {
                (action1) -> Void in
                alert .dismissViewControllerAnimated(true, completion: nil)
            }))
     
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    /// enter new user info in alert view and save that user
    func giveNewUserInfo() -> Void
    {
        let newString = NSString(format: "%@ is about to sign up", self.phoneNumberTextField.text)
        let alert = UIAlertController(title: newString as String, message: "their name is", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler
        {
            (textField) -> Void in
            textField.placeholder = "firstName"
        }
        alert.addTextFieldWithConfigurationHandler
        {
                (textField) -> Void in
                textField.placeholder = "lastName"
        }
        alert.addAction(UIAlertAction(title: "oKay", style: .Default, handler:
            {
                (action1) -> Void in
                let firstNameTextField = alert.textFields![0] as! UITextField
                let lastNameTextField = alert.textFields![1] as! UITextField
                self.createNewUser(firstNameTextField.text, lastName: lastNameTextField.text)
            }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler:
            {
                (action1) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func createNewUser(firstName: String, lastName: String) -> Void
    {
        let quotedUser = PassiveUser(className: "PassiveUser")
        quotedUser.phoneNumber = self.formattedString!
        quotedUser.firstName = firstName
        quotedUser.lastName = lastName
        quotedUser.verified = 0
        quotedUser.hasPhoto = 0
        var userACL = PFACL()
        userACL.setPublicWriteAccess(true)
        userACL.setPublicReadAccess(true)
        quotedUser.ACL = userACL
        quotedUser.saveInBackgroundWithBlock
            {
                (success: Bool, error: NSError?) -> Void in
                if success
                {
                    //println("New Passive User has been saved.")
                    self.checkButton.hidden = true
                    self.personName.hidden = false
                    self.nameString = NSString(format: "%@ %@", quotedUser.firstName, quotedUser.lastName) as String
                    self.personName.textAlignment = NSTextAlignment.Center
                    self.personName.text = self.nameString
                    self.userToSave = quotedUser
                }
        }
    }
    
    func saveQuoteforUser()
    {
        let quote = Quote(className: "Quote")
        quote.quoteText = self.quoteTextView.text
        quote.saidBy = self.userToSave
        quote.poster = self.theCurrentUser!
        quote.likesCounter = 0
        quote.quoteIsRiding = 0
        var quoteACL = PFACL()
        quoteACL.setPublicWriteAccess(true)
        quoteACL.setPublicReadAccess(true)
        quote.ACL = quoteACL
        quote.saveInBackgroundWithBlock
            {
                (success: Bool, error: NSError?) -> Void in
                if success
                {
                    //println("saved user and quote")
                    self.navigationController?.popViewControllerAnimated(true)
                    self.sendText()
                }
            }

    }
    
    func doesThisUserExist(firstName: String, lastName: String, phoneNumber: String)
    {
        let query = PassiveUser.query()
        query!.whereKey("phoneNumber", equalTo: phoneNumber)
        query!.findObjectsInBackgroundWithBlock
            {
                (returnedObjects, returnedError) -> Void in
                if returnedError == nil
                {
                    if returnedObjects!.count > 0
                    {
                        //println("this user exists")
                        if let objects = returnedObjects as? [PassiveUser]
                        {
                            for foundUser in objects
                            {
                                self.nameString = NSString(format: "%@ %@", foundUser.firstName, foundUser.lastName) as String
                                self.checkButton.hidden = true
                                self.personName.hidden = true
                                self.profileButton.hidden = false
                                self.profileButton.setTitle(self.nameString, forState: UIControlState.Normal)
                                self.userToSave = foundUser
                            }
                        }
                    }
                    else
                    {
                        self.createNewUser(firstName, lastName: lastName)
                    }
                }
            }
    }

    
    func sendText()
    {
        
        let firstName = self.theCurrentUser!.firstName
        let lastName = self.theCurrentUser!.lastName
        
        PFCloud.callFunctionInBackground("sendUserText", withParameters: ["phoneNumber":self.phoneNumberTextField.text, "firstName": firstName, "lastName": lastName, "text": self.quoteTextView.text],
            block: {
                    (success, error) -> Void in
                    if error == nil
                    {
                        //println("sent a text to that number")
                    }
                

        })
    }
    

    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {

        return count(textView.text) + (count(text) - range.length) <= 200
    }

}
