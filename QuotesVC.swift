
//
//  ViewController.swift
//  saidThat
//
//  Created by Thomas Gibbons on 5/1/15.
//  Copyright (c) 2015 Thomas Gibbons. All rights reserved.
//
import UIKit
import Parse

class QuotesVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, flagDelegate
{
    var quotes : [Quote] = []
    var selectedQuote : Quote?
    var theCurrentUser : PassiveUser?
    var userToDelete: PFObject?
    var refreshControl = UIRefreshControl()
    var phoneNumber: AnyObject?
    var quotesIClap: [Quote] = []
    var myClaps : [Clap] = []
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
      

    override func viewDidLoad()
    {
        super.viewDidLoad()
        UIStatusBarStyle.LightContent
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor(red: 162/255, green: 221/255, blue: 150/255, alpha: 1.0)
        self.refreshControl.tintColor = UIColor(red: 218/255, green: 172/255, blue: 226/255, alpha: 1.0)
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents:UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        self.tableView.separatorColor = UIColor.lightGrayColor()



    }
    

    func refresh(sender: AnyObject)
    {
        if self.segmentControl.selectedSegmentIndex == 0
        {
            queryForQuotes()
        }
        else if self.segmentControl.selectedSegmentIndex == 1
        {
            queryForFriendQuotes()
        }
        else if self.segmentControl.selectedSegmentIndex == 2
        {
            queryForMyQuotes()
        }
    }
    
    @IBAction func signOutButton(sender: AnyObject)
    {
        self.performSegueWithIdentifier("myProfile", sender: self)
    }
    
    func queryLocalDataStore()
    {
        let logInQuery = PassiveUser.query()
        logInQuery!.whereKey("phoneNumber", equalTo: phoneNumber!)
        logInQuery!.findObjectsInBackgroundWithBlock
            {
                (returnedObjects, returnedError) -> Void in
                if returnedError == nil
                {
                    
                    if let usersArray = returnedObjects as? [PassiveUser]
                    {
                        for foundUser in usersArray
                        {
                            self.theCurrentUser = foundUser
                            self.findMyClaps()
                            println("user successfully logged as current user")
                        }
                    }
                }
        }
    }

    override func viewDidAppear(animated: Bool)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let verified: AnyObject? =  defaults.objectForKey("verified")
        phoneNumber = defaults.objectForKey("phoneNumber")
        if verified == nil
        {
            self.performSegueWithIdentifier("sendToLogin", sender: self)
        }
        else
        {
            queryLocalDataStore()
        }

    }
    
    override func viewWillAppear(animated: Bool)
    {
        if self.segmentControl.selectedSegmentIndex == 0
        {
            self.queryForQuotes()
        }
        else if self.segmentControl.selectedSegmentIndex == 1
        {
            self.queryForFriendQuotes()
        }
        else if self.segmentControl.selectedSegmentIndex == 2
        {
            self.queryForMyQuotes()
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let identifier = String("cellID")
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! QuoteCell
        cell.clapImage.alpha = 0.0
        let quoteToShow = self.quotes[indexPath.row]
        let quoteToShowText = quoteToShow.quoteText
        cell.qTextLabel.text = "\"" + quoteToShowText + "\""
        cell.saidbyPicture.frame.size = CGSizeMake(40, 40)
        
        
        //CHECKS IF CLAPPED
        
        if contains(self.quotesIClap, quoteToShow)
        {
            cell.iClapped = true
            cell.applaudButton.setTitle("Unapplaud", forState: UIControlState.Normal)
        }
        else
        {
            cell.iClapped = false
            cell.applaudButton.setTitle("Applaud", forState: UIControlState.Normal)
        }

        cell.saidbyPicture.layer.cornerRadius = cell.saidbyPicture.frame.height/2
        cell.saidbyPicture.clipsToBounds = true
        cell.saidbyPicture.backgroundColor = UIColor(red: 162/255, green: 221/255, blue: 150/255, alpha: 1.0)
        if quoteToShow.saidBy.hasPhoto.isEqualToNumber(0)
        {
            cell.saidbyPicture.contentMode = UIViewContentMode.Center
            cell.saidbyPicture.image = UIImage(named: "miniflatbubble")
            
        }
        if quoteToShow.saidBy.hasPhoto.isEqualToNumber(1)
        {
            cell.saidbyPicture.contentMode = UIViewContentMode.ScaleAspectFit
            quoteToShow.saidBy.profilePic.getDataInBackgroundWithBlock { (data, error) -> Void in
                if error == nil
                {
                    
                    cell.saidbyPicture.image = UIImage(data: data!)
                }
            }
        }
     
        if quoteToShow.likesCounter.integerValue < 5
        {
            cell.qTextLabel.font = cell.qTextLabel.font.fontWithSize(14)
        }
        else if quoteToShow.likesCounter.integerValue > 25
        {
            cell.qTextLabel.font = cell.qTextLabel.font.fontWithSize(36)
        }
        else
        {
            let number = CGFloat(quoteToShow.likesCounter.integerValue + 11)
            cell.qTextLabel.font = cell.qTextLabel.font.fontWithSize(number)
        }
        cell.qTextLabel.numberOfLines = 0
        
        cell.delegate = self
        cell.selectedQuote = quoteToShow
        let newNumber = quoteToShow.likesCounter.integerValue
        let numberString = String(stringInterpolationSegment: newNumber)
        cell.likeButton.setTitle(numberString, forState: UIControlState.Normal)
        let date1 = quoteToShow.createdAt
        let date2 = NSDate()
        let dateString = date2.offsetFrom(date1!)
        let firstNameString = quoteToShow.saidBy["firstName"] as! String
        let lastNameString = quoteToShow.saidBy["lastName"] as! String
        let postFirstNameString = quoteToShow.poster["firstName"] as! String
        let postLastNameString = quoteToShow.poster["lastName"] as! String
        let newString = NSString(format: "%@ %@ posted by %@ %@  %@", firstNameString, lastNameString, postFirstNameString, postLastNameString, dateString)
        cell.quoteDetails!.text = dateString as String
        cell.authorButton.setTitle(firstNameString + " " + lastNameString, forState: UIControlState.Normal)
        cell.posterButton.setTitle(postFirstNameString + " " + postLastNameString, forState: UIControlState.Normal)
    

        if cell.selectedQuote!.quoteIsRiding.isEqualToNumber(1)
        {
            cell.backgroundColor = UIColor(red: 162/255, green: 221/255, blue: 150/255, alpha: 1.0)
            cell.qTextLabel.textColor = UIColor.whiteColor()
            cell.applaudButton.tintColor = UIColor.whiteColor()
        }
        else
        {
            cell.backgroundColor = UIColor.whiteColor()
            cell.qTextLabel.textColor = UIColor.blackColor()
            cell.applaudButton.tintColor = UIColor(red: 162/255, green: 221/255, blue: 150/255, alpha: 1.0)
        }
        cell.contentView.layoutIfNeeded()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }
    
    func findMyClaps()
    {
        let myClaps = Clap.query()
        myClaps?.whereKey("clapper", equalTo: self.theCurrentUser!)
        myClaps?.findObjectsInBackgroundWithBlock({ (myClapQs, error) -> Void in
            if error == nil
            {
                if let clapsArray = myClapQs as? [Clap]
                {
                    for clap in clapsArray
                    {
                        self.myClaps.append(clap)
                        let clappedQuote = clap.quoteClapped
                        self.quotesIClap.append(clappedQuote)
                    }
                }
                self.tableView.reloadData()
            }
        })

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "profile"
        {
            let profileVC = segue.destinationViewController as! ProfileVC
            profileVC.theCurrentUser = self.theCurrentUser
            profileVC.selectedUser = self.selectedQuote?.saidBy
        }
        else if segue.identifier == "myProfile"
        {
            let profileVC = segue.destinationViewController as! ProfileVC
            profileVC.theCurrentUser = self.theCurrentUser
            profileVC.selectedUser = self.theCurrentUser
        }
            
        else if segue.identifier == "toLikes"
        {
            let likesVC = segue.destinationViewController as! LikesViewController
            likesVC.quoteWithLikes = self.selectedQuote
            likesVC.theCurrentUser = self.theCurrentUser
        }
        else if segue.identifier == "postQuote"
        {
            let postQuoteVC = segue.destinationViewController as! PostQuoteVC
            postQuoteVC.theCurrentUser = self.theCurrentUser
        }
        else if segue.identifier == "posterProfile"
        {
            let profileVC = segue.destinationViewController as! ProfileVC
            profileVC.theCurrentUser = self.theCurrentUser
            profileVC.selectedUser = self.selectedQuote?.poster
        }
        

        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.quotes.count
    }

    func queryForQuotes() -> Void

    {
        let queryQuotes = Quote.query()
        queryQuotes?.includeKey("saidBy")
        queryQuotes?.includeKey("poster")
        queryQuotes?.orderByDescending("createdAt")
        queryQuotes?.findObjectsInBackgroundWithBlock(
        {
                (returnedQuotes, error) -> Void in
                if error == nil
                {
                    self.quotes = returnedQuotes as! [Quote]
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    self.tableView.setNeedsUpdateConstraints()
                    self.tableView.updateConstraintsIfNeeded()
                    self.tableView.layoutIfNeeded()
                    self.tableView.reloadData()

                }
        })
    }
    
    func queryForFriendQuotes() -> Void
        
    {
        let queryForMyFriends = Follow.query()
        queryForMyFriends?.whereKey("from", equalTo: self.theCurrentUser!)

        let queryForFriendsSpokes = PFQuery(className: "Quote")
        queryForFriendsSpokes.whereKey("saidBy", matchesKey: "to", inQuery: queryForMyFriends!)
        
        
        let queryForFriendsPosts = PFQuery(className: "Quote")
        queryForFriendsPosts.whereKey("poster", matchesKey: "to", inQuery: queryForMyFriends!)
        
        let compoundQuery = PFQuery.orQueryWithSubqueries([queryForFriendsSpokes,queryForFriendsPosts])
        compoundQuery.orderByDescending("createdAt")
        compoundQuery.includeKey("saidBy")
        compoundQuery.includeKey("poster")
        compoundQuery.findObjectsInBackgroundWithBlock(
            {
                (returnedQuotes, error) -> Void in
                if error == nil
                {
                    self.quotes = returnedQuotes as! [Quote]
                    self.tableView.reloadData()
                    self.tableView.setNeedsUpdateConstraints()
                    self.tableView.updateConstraintsIfNeeded()
                    self.tableView.layoutIfNeeded()
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                }
                self.tableView.reloadData()
        })
    }
    
    func queryForMyQuotes()
    {
        let queryQuotes = PFQuery(className: "Quote")
        queryQuotes.whereKey("saidBy", equalTo: self.theCurrentUser!)
        let queryMoreQuotes = PFQuery(className: "Quote")
        queryMoreQuotes.whereKey("poster", equalTo: self.theCurrentUser!)
        var compoundQuery = PFQuery.orQueryWithSubqueries([queryQuotes,queryMoreQuotes])
        compoundQuery.orderByDescending("createdAt")
        compoundQuery.includeKey("saidBy")
        compoundQuery.includeKey("poster")
        compoundQuery.findObjectsInBackgroundWithBlock(
            {
                (returnedQuotes, error) -> Void in
                if error == nil
                {
                    self.quotes = returnedQuotes as! [Quote]
                    self.tableView.reloadData()
                    self.tableView.setNeedsUpdateConstraints()
                    self.tableView.updateConstraintsIfNeeded()
                    self.tableView.layoutIfNeeded()
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
        })
    }
    
    
    @IBAction func segmentControlTap(sender: UISegmentedControl)
    {
        if sender.selectedSegmentIndex == 0
        {
            //query for all quotes
            queryForQuotes()
        }
        else if sender.selectedSegmentIndex == 1
        {
            queryForFriendQuotes()
            //query for my friends quotes
            
        }
        else if sender.selectedSegmentIndex == 2
        {
            queryForMyQuotes()
            
            //show only my quotes
        }
    }

    
    
    
    // flagged cell delegate
    
    func theUserHitFlagButton(yes: Bool, forCell: Quote)
    {
       
        let alert = UIAlertController(title: "Shouldn't have saidThat...", message: "If you select okay, a saidThat moderator will examine the content and potentially ban the parties involved within 12 hours", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "oKay", style: .Default , handler:
            {
                (action2) -> Void in
                alert.dismissViewControllerAnimated(true, completion: nil)
                forCell.isFlagged = 1
                forCell.saveEventually()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default , handler:
            {
                (action1) -> Void in
        }))
                
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    func theUserDoubleTapped(yes: Bool, forCell: QuoteCell, andQuote: Quote)
    {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            forCell.clapImage.alpha = 1.0
        }) { (finished) -> Void in
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                forCell.clapImage.alpha = 0.0
            }, completion: nil)
        }
        if forCell.iClapped == false
        {
            self.createLike(andQuote, forCell: forCell)
        }
        else
        {
            self.deleteLike(andQuote, forCell: forCell)
        }
    }
    
    
    func createLike(quoteToLike: Quote, forCell: QuoteCell)
    {
        let clap = Clap()
        clap.clapper = self.theCurrentUser!
        clap.quoteClapped = quoteToLike
        clap.saveInBackgroundWithBlock { (success, error) -> Void in
            if success
            {
                println("clap saved")
                forCell.applaudButton.setTitle("Unapplaud", forState: UIControlState.Normal)
                self.myClaps.append(clap)
                self.quotesIClap.append(clap.quoteClapped)
                forCell.iClapped = true
                let newNumber = quoteToLike.likesCounter.integerValue + 1
                forCell.likeButton.setTitle(String(newNumber), forState: UIControlState.Normal)
                quoteToLike.incrementKey("likesCounter", byAmount: 1)
                quoteToLike.saveInBackgroundWithBlock
                    { (success, error) -> Void in
                        if error == nil
                        {
                            let pushQueryOne = PFInstallation.query()
                            pushQueryOne!.whereKey("deviceOwner", equalTo: quoteToLike.saidBy)
                            let pushQueryTwo = PFInstallation.query()
                            pushQueryTwo?.whereKey("deviceOwner", equalTo: quoteToLike.poster)
                            let compoundPushQuery = PFQuery.orQueryWithSubqueries([pushQueryOne!, pushQueryTwo!])
                            let push = PFPush()
                            push.setQuery(compoundPushQuery) // Set our Installation query
                            let name = "\(self.theCurrentUser!.firstName) \(self.theCurrentUser!.lastName) applauds your saidThat"
                            push.setMessage(name)
                            push.sendPushInBackground()
                            println("push should be sent")
                            //println("quote was saved, was the countersaved?")
                        }
                }

                
                
                
            }
        }
        
    }
    
    func deleteLike(quoteToLike: Quote, forCell: QuoteCell)
    {
        //we need to find the clap object associated with this quote and then delete it
        
        //iterate through our array of claps if our clap.quote = quoteToLike, delete that quote
        
        for clap in myClaps
        {
            if clap.quoteClapped == quoteToLike
            {
                
                clap.deleteInBackgroundWithBlock({ (success, error) -> Void in
                    if success
                    {
                        forCell.applaudButton.setTitle("Applaud", forState: .Normal)
                        let u = find(self.quotesIClap, clap.quoteClapped)
                        self.quotesIClap.removeAtIndex(u!)
                        let i = find(self.myClaps, clap)
                        self.myClaps.removeAtIndex(i!)
                        forCell.iClapped = false
                        let newNumber = quoteToLike.likesCounter.integerValue - 1
                        forCell.likeButton.setTitle(String(newNumber), forState: UIControlState.Normal)
                        quoteToLike.incrementKey("likesCounter", byAmount: -1)
                        quoteToLike.saveInBackgroundWithBlock
                            { (success, error) -> Void in
                                if error == nil
                                {
                                
                                }
                            }
                        
                    }
                })
            }
        }
        
    }
    
    
    func sendToPoster(forQuote: Quote)
    {
        println("1 called")
        self.selectedQuote = forQuote
        self.performSegueWithIdentifier("posterProfile", sender: nil)
    }
    
    func sendToAuthor(forQuote: Quote)
    {
        println("called")

        self.selectedQuote = forQuote
        self.performSegueWithIdentifier("profile", sender: nil)
    }
    
    func sendToLikeVC(withQuote: Quote)
    {
        self.selectedQuote = withQuote
        

    }
//unwind segue for sign out
    @IBAction func logOutSegue (segue:UIStoryboardSegue)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(nil, forKey: "verified")
        self.queryLocalDataStore()
    }
    
}

