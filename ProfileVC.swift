//
//  ProfileVC.swift
//  ParseStarterProject
//
//  Created by Thomas Gibbons on 5/5/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController, UITableViewDataSource, UITableViewDelegate,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, flagDelegate, flaggerDelegate
{
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var quotesLabel: UILabel!
    @IBOutlet weak var quotesCountLabel: UILabel!
    @IBOutlet weak var postsCountLabel: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    
    var selectedUser : PassiveUser?
    var userToShow : PassiveUser?
    var selectedQuote : Quote?
    var quotes : [Quote] = []
    var posts : [Quote] = []
    var followers : [Follow] = []
    var theCurrentUsersFollowsTo : [Follow] = []
    var theCurrentUsersFollowsToUser: [PassiveUser] = []
    var following : [Follow] = []
    var usersFollowsPeople : [PassiveUser] = []
    var followsToDelete : Follow?
    var showActive : Bool?
    var theCurrentUser: PassiveUser?
    var tableNumber: NSNumber?
    var quoteToDelete: Quote?
    var myClaps : [Clap] = []
    var quotesIClap: [Quote] = []

    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        let firstNameString = self.selectedUser?.valueForKey("firstName") as! String
        let lastNameString = self.selectedUser?.valueForKey("lastName") as! String
        let space = " "
        let title = firstNameString + space + lastNameString
        self.navigationItem.titleView?.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = NSDictionary(object: UIColor.whiteColor(), forKey: NSForegroundColorAttributeName) as [NSObject : AnyObject]
        self.navigationItem.title = title
        self.ownProfileCheck()
        self.queryForMyQuotes()
        self.queryForPosts()
        self.queryForSelectedUserFollowers()
        self.queryForSelectedUserFollowees()
        self.queryForWhoTheCurrentUserIsFollowing()
        self.setUpLabels()
        tableNumber = 1
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
    }
    
    func ownProfileCheck()
    {
        if self.selectedUser == self.theCurrentUser
        {
            //println("looking at your own profile")
            self.profilePic.userInteractionEnabled = true
            self.followButton.hidden = true
            //add gesture recognizer
            let photoTap = UITapGestureRecognizer(target: self, action: "changePhoto:")
            self.profilePic.addGestureRecognizer(photoTap)
        }
        else
        {
            self.signOutButton.hidden = true
        }
        if self.selectedUser?.profilePic == nil
        {
            //println("setting up profile bubble")
            setUpProfilePicture(UIImage(named:"profileBubble")!)
            profilePic.contentMode = UIViewContentMode.Center
        }
        else
        {
            //println("setting up profile image")
            profilePic.contentMode = UIViewContentMode.ScaleAspectFit
            self.selectedUser?.profilePic.getDataInBackgroundWithBlock({ (imageData, error) -> Void in
                if error == nil
                {
                    let imageToRender = UIImage(data:imageData!)
                    self.profilePic.image = imageToRender
                    self.setUpProfilePicture(imageToRender!)
                    
                }
            })
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
       
        if self.theCurrentUser == self.selectedUser
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?
    {
        //
        if (self.selectedUser == self.theCurrentUser && (tableNumber!.isEqualToNumber(1) || tableNumber!.isEqualToNumber(2)))
        {
            var removeAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "remove" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
                if self.tableNumber!.isEqualToNumber(1)
                {
                    self.quoteToDelete = self.quotes[indexPath.row]
                    self.quoteToDelete?.deleteInBackgroundWithBlock({ (success, error) -> Void in
                        if error == nil
                        {
                            //println("we deleted this quote")
                            self.quotes.removeAtIndex(indexPath.row)
                            self.tableView.reloadData()
                        }
                    })
                }
                else
                {
                    self.quoteToDelete = self.posts[indexPath.row]
                    self.quoteToDelete?.deleteInBackgroundWithBlock({ (success, error) -> Void in
                        if error == nil
                        {
                            //println("we deleted this quote")
                            self.posts.removeAtIndex(indexPath.row)
                            self.tableView.reloadData()
                        }
                    })
                }
            })
            removeAction.backgroundColor = UIColor(red: 218/255, green: 172/255, blue: 226/255, alpha: 1.0)
            
            var rideAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "let it ride" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
                ///we just need to check the table number than look in the array
               
                
                if self.tableNumber!.isEqualToNumber(1)
                {
                    let quoteToMark = self.quotes[indexPath.row]
                    quoteToMark.quoteIsRiding = 1
                    self.showRideAlert(quoteToMark)
                }
                else
                {
                    let quoteToMark = self.posts[indexPath.row]
                    quoteToMark.quoteIsRiding = 1
                    self.showRideAlert(quoteToMark)
                }
                self.quoteToDelete?.deleteInBackgroundWithBlock({ (success, error) -> Void in
                    //println("we deleted this quote")
                })
            
            })
            rideAction.backgroundColor = UIColor(red: 162/255, green: 221/255, blue: 150/255, alpha: 1.0)
            
            return [removeAction,rideAction]
        }
        else
        {
            return nil
        }
        
    }
    
    
    func showRideAlert(forQuote: Quote)
    {
        let alert = UIAlertController(title: "This person never saidThat...but we'll let it ride", message: "we'll mark it green so people know this wasn't actually said", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "oKay", style: .Default, handler:
            {
                (action2) -> Void in
                forQuote.quoteIsRiding = 1
                forQuote.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if error == nil
                    {
                        //println("we have created a green quote")
                        self.tableView.reloadData()
                    }
                })
            }))
        alert.addAction(UIAlertAction(title: "neverMind", style: .Cancel, handler:            {
            (action2) -> Void in
            forQuote.quoteIsRiding = 1
            forQuote.saveInBackgroundWithBlock({ (success, error) -> Void in
                if error == nil
                {
                    //println("we have created a green quote")
                    //println("jk no we didn't")
                }
            })
        }))
        presentViewController(alert, animated: true, completion: nil)
    }

    
    func setUpProfilePicture(withimage: UIImage)
    {
       
        let imageSizeHeight = self.profilePic.frame.size.height/2
        let imageSizeWidth = self.profilePic.frame.size.width/2
        self.profilePic.image = withimage
        self.profilePic.layer.masksToBounds = false
        self.profilePic.layer.borderColor = UIColor.clearColor().CGColor
        self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width/10
        self.profilePic.clipsToBounds = true
    }
    
    func setUpLabels()
    {
        let postsTap = UITapGestureRecognizer(target: self, action: "showPosts:")
        let postsTap2 = UITapGestureRecognizer(target: self, action: "showPosts:")
        self.postsCountLabel.userInteractionEnabled = true
        self.postsLabel.addGestureRecognizer(postsTap)
        self.postsCountLabel.addGestureRecognizer(postsTap2)
        let quotesTap = UITapGestureRecognizer(target: self, action: "showQuotes:")
        let quotesTap2 = UITapGestureRecognizer(target: self, action: "showQuotes:")
        self.quotesCountLabel.userInteractionEnabled = true
        self.quotesLabel.addGestureRecognizer(quotesTap)
        self.quotesCountLabel.addGestureRecognizer(quotesTap2)
        let followersTap = UITapGestureRecognizer(target: self, action: "showFollowers:")
        let followersTap2 = UITapGestureRecognizer(target: self, action: "showFollowers:")
        self.followersCountLabel.userInteractionEnabled = true
        self.followersLabel.addGestureRecognizer(followersTap)
        self.followersCountLabel.addGestureRecognizer(followersTap2)
        let followingTap = UITapGestureRecognizer(target: self, action: "showFollowing:")
        let followingTap2 = UITapGestureRecognizer(target: self, action: "showFollowing:")
        self.followingCountLabel.userInteractionEnabled = true
        self.followingLabel.addGestureRecognizer(followingTap)
        self.followingCountLabel.addGestureRecognizer(followingTap2)
    }
    
    
    @IBAction func followButton(sender: AnyObject)
    {
        
        if followsToDelete != nil //delete follow
        {
            let follow = followsToDelete
            let i = find(self.followers, follow!)
            follow?.deleteInBackgroundWithBlock({ (success, error) -> Void in
                if error == nil
                {
                    self.followers.removeAtIndex(i!)
                    self.tableView.reloadData()
                    let newNumber = self.followers.count
                    self.followersCountLabel.text = String(newNumber)
                    self.followButton.setTitle("Follow", forState: UIControlState.Normal)
                    self.followsToDelete = nil
                }
            })

        }
        else //create follow
        {
            let newFollow = Follow(className: "Follow")
            newFollow.from = self.theCurrentUser!
            newFollow.to = self.selectedUser!
            var newFollowACL = PFACL()
            newFollowACL.setPublicWriteAccess(true)
            newFollowACL.setPublicReadAccess(true)

            newFollow.ACL = newFollowACL
            newFollow.saveInBackgroundWithBlock
                {
                    (succeeded, error) -> Void in
                    if error == nil
                    {
                        //println("follow saved")
                        self.followButton.setTitle("Unfollow", forState: UIControlState.Normal)
                        let newNumber = self.followers.count + 1
                        self.followersCountLabel.text = String(newNumber)
                        self.followsToDelete = newFollow
                        self.followers.append(newFollow)
                        self.tableView.reloadData()
                        
                    }
                }
        }

        
    }
    
    
    func queryForPosts()
    {
        let queryQuotes = Quote.query()
        queryQuotes!.whereKey("poster", equalTo: self.selectedUser!)
        queryQuotes?.includeKey("saidBy")
//        queryQuotes!.includeKey("upvotes")
        queryQuotes?.orderByDescending("likesCounter")
        queryQuotes!.findObjectsInBackgroundWithBlock(
            {
                (returnedQuotes, error) -> Void in
                if error == nil
                {
                    self.posts = returnedQuotes as! [Quote]
                    self.postsCountLabel.text = String(self.posts.count)
                    self.tableView.rowHeight = UITableViewAutomaticDimension
                    self.tableView.estimatedRowHeight = 100
                    self.tableView.reloadData()
                    self.tableView.setNeedsLayout()
                    self.tableView.layoutIfNeeded()
                    self.tableView.reloadData()
                    println(self.posts)
                }
        })

    
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        //quotes = 1 posts = 2 followers = 3 following = 4
        if tableNumber!.isEqualToNumber(1)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("quote") as! QuoteCell
            cell.clapImage2.alpha = 0.0
            let quoteToShow = self.quotes[indexPath.row]
            cell.qTextLabel2.text = "\"" + quoteToShow.quoteText + "\""
            cell.qTextLabel2.font = cell.qTextLabel2.font.fontWithSize(14)
            cell.delegate = self
            cell.selectedQuote = quoteToShow
            let newNumber = quoteToShow.likesCounter.integerValue
            let numberString = String(stringInterpolationSegment: newNumber)
            cell.likeButton2.setTitle(numberString, forState: UIControlState.Normal)
            let date1 = quoteToShow.createdAt
            let date2 = NSDate()
            let dateString = date2.offsetFrom(date1!)
            let firstNameString = quoteToShow.saidBy["firstName"] as! String
            let lastNameString = quoteToShow.saidBy["lastName"] as! String
            let postFirstNameString = quoteToShow.poster["firstName"] as! String
            let postLastNameString = quoteToShow.poster["lastName"] as! String
            let newString = NSString(format: "-%@ %@ posted by %@ %@  %@", firstNameString, lastNameString, postFirstNameString, postLastNameString, dateString)
            cell.quoteDetails2!.text = dateString as String
            cell.authorButton2.setTitle("-"+firstNameString + " " + lastNameString, forState: UIControlState.Normal)
            cell.posterButton2.setTitle(postFirstNameString + " " + postLastNameString, forState: UIControlState.Normal)
            if cell.selectedQuote!.quoteIsRiding.isEqualToNumber(1)
            {
                cell.backgroundColor = UIColor(red: 162/255, green: 221/255, blue: 150/255, alpha: 1.0)
                cell.qTextLabel2.textColor = UIColor.whiteColor()
                cell.applaudButton2.tintColor = UIColor.whiteColor()
            }
            else
            {
                cell.backgroundColor = UIColor.whiteColor()
                cell.qTextLabel2.textColor = UIColor.blackColor()
                cell.applaudButton2.tintColor = UIColor(red: 162/255, green: 221/255, blue: 150/255, alpha: 1.0)
            }
            if contains(self.quotesIClap, quoteToShow)
            {
                cell.iClapped2 = true
                cell.applaudButton2.setTitle("Unapplaud", forState: UIControlState.Normal)
            }
            else
            {
                cell.iClapped2 = false
                cell.applaudButton2.setTitle("Applaud", forState: UIControlState.Normal)
            }
            return cell
        }
        else if tableNumber!.isEqualToNumber(2)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("quote") as! QuoteCell
            cell.clapImage2.alpha = 0.0
            let quoteToShow = self.posts[indexPath.row]
            cell.selectedQuote = quoteToShow
            cell.qTextLabel2.text = "\"" + quoteToShow.quoteText + "\""
            cell.qTextLabel2.font = cell.qTextLabel2.font.fontWithSize(14)
            cell.delegate = self
            let newNumber = quoteToShow.likesCounter.integerValue
            let numberString = String(stringInterpolationSegment: newNumber)
            cell.likeButton2.setTitle(numberString, forState: UIControlState.Normal)
            let date1 = quoteToShow.createdAt
            let date2 = NSDate()
            let dateString = date2.offsetFrom(date1!)
            let firstNameString = quoteToShow.saidBy["firstName"] as! String
            let lastNameString = quoteToShow.saidBy["lastName"] as! String
            let postFirstNameString = quoteToShow.poster["firstName"] as! String
            let postLastNameString = quoteToShow.poster["lastName"] as! String
            let newString = NSString(format: "-%@ %@ posted by %@ %@  %@", firstNameString, lastNameString, postFirstNameString, postLastNameString, dateString)
            cell.quoteDetails2!.text = dateString as String
            cell.authorButton2.setTitle("-"+firstNameString + " " + lastNameString, forState: UIControlState.Normal)
            cell.posterButton2.setTitle(postFirstNameString + " " + postLastNameString, forState: UIControlState.Normal)
            if cell.selectedQuote!.quoteIsRiding.isEqualToNumber(1)
            {
                cell.backgroundColor = UIColor(red: 162/255, green: 221/255, blue: 150/255, alpha: 1.0)
                cell.qTextLabel2.textColor = UIColor.whiteColor()
                cell.applaudButton2.tintColor = UIColor.whiteColor()
            }
            else
            {
                cell.backgroundColor = UIColor.whiteColor()
                cell.qTextLabel2.textColor = UIColor.blackColor()
                cell.applaudButton2.tintColor = UIColor(red: 162/255, green: 221/255, blue: 150/255, alpha: 1.0)
            }
            self.tableView.rowHeight = UITableViewAutomaticDimension
            self.tableView.estimatedRowHeight = 100
            if contains(self.quotesIClap, quoteToShow)
            {
                cell.iClapped2 = true
                cell.applaudButton2.setTitle("Unapplaud", forState: UIControlState.Normal)
            }
            else
            {
                cell.iClapped2 = false
                cell.applaudButton2.setTitle("Applaud", forState: UIControlState.Normal)
            }
            return cell
        }
        else if tableNumber!.isEqualToNumber(3) //the selected users followers - he is to, they are from
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("user") as! UserCell
            let followerObject = self.followers[indexPath.row]
            if indexPath.row % 2 == 1
            {
                cell.profileImage2.backgroundColor = UIColor(red: 218/255, green: 172/255, blue: 226/255, alpha: 1.0)
                cell.followButton2.backgroundColor = UIColor(red: 162/255, green: 221/255, blue: 150/255, alpha: 1.0)

            }
            else
            {
                cell.profileImage2.backgroundColor = UIColor(red: 162/255, green: 221/255, blue: 150/255, alpha: 1.0)
                cell.followButton2.backgroundColor = UIColor(red: 218/255, green: 172/255, blue: 226/255, alpha: 1.0)
            }
            cell.theCurrentUser = self.theCurrentUser
            cell.selectedUser = followerObject.from
            let userForRow = followerObject.from
            
            if userForRow.hasPhoto.isEqualToNumber(1)
            {
                userForRow.profilePic.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil
                {
                    if data != nil
                    {
                        let image = UIImage(data:data!)
                        cell.profileImage2.image = image
                        cell.profileImage2.contentMode = UIViewContentMode.ScaleAspectFit
                        //                    not able to make circle but who cares
                    }
                }
                })
            }
            else if userForRow.hasPhoto.isEqualToNumber(0)
            {
                cell.profileImage2.image = UIImage(named: "flatCloudHigherResSized")
                cell.profileImage2.contentMode = UIViewContentMode.Center
            }
            
            if cell.theCurrentUser == followerObject.from
            {
                cell.followButton2.hidden = true
            }
            else
            {
                cell.followButton2.hidden = false
            }
            if contains(self.theCurrentUsersFollowsToUser, userForRow)
            {
                cell.isFollowing2 = true
                cell.followButton2.setTitle("Unfollow", forState: UIControlState.Normal)
            }
            else
            {
                cell.isFollowing2 = false
                cell.followButton2.setTitle("Follow", forState: UIControlState.Normal)
            }
            let string = followerObject.from.firstName + " " + followerObject.from.lastName
            cell.userButton2.setTitle(string, forState: UIControlState.Normal)
            cell.delegate = self
            return cell
        }
        else //tableview# is 4 list of who the profiled selected User is following they are to, he is from
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("user") as! UserCell
            let followeeObject = self.following[indexPath.row]
            if indexPath.row % 2 == 1
            {
                cell.profileImage2.backgroundColor = UIColor(red: 218/255, green: 172/255, blue: 226/255, alpha: 1.0)
                cell.followButton2.backgroundColor = UIColor(red: 162/255, green: 221/255, blue: 150/255, alpha: 1.0)
                
            }
            else
            {
                cell.profileImage2.backgroundColor = UIColor(red: 162/255, green: 221/255, blue: 150/255, alpha: 1.0)
                cell.followButton2.backgroundColor = UIColor(red: 218/255, green: 172/255, blue: 226/255, alpha: 1.0)
            }
            cell.theCurrentUser = self.theCurrentUser
            cell.selectedUser = followeeObject.to
            if cell.theCurrentUser == followeeObject.to
            {
                cell.followButton2.hidden = true
            }
            else
            {
                cell.followButton2.hidden = false
            }
            let userForRow = followeeObject.to
            
            if userForRow.hasPhoto.isEqualToNumber(1)
            {
                userForRow.profilePic.getDataInBackgroundWithBlock({ (data, error) -> Void in
                    if error == nil
                    {
                        if data != nil
                        {
                            let image = UIImage(data:data!)

                            cell.profileImage2.image = image
                            cell.profileImage2.contentMode = UIViewContentMode.ScaleAspectFit


                        }
                            //                    not able to make circle but who cares
                    
                    }
                })
            }
            else if userForRow.hasPhoto.isEqualToNumber(0)
            {
                cell.profileImage2.image = UIImage(named: "flatCloudHigherResSized")
                cell.profileImage2.contentMode = UIViewContentMode.Center
            }

            if contains(self.theCurrentUsersFollowsToUser, userForRow)
            {
                cell.isFollowing2 = true
                cell.followButton2.setTitle("Unfollow", forState: UIControlState.Normal)
            }
            else
            {
                cell.isFollowing2 = false
                cell.followButton2.setTitle("Follow", forState: UIControlState.Normal)
            }
            let string = followeeObject.to.firstName + " " + followeeObject.to.lastName
            cell.userButton2.setTitle(string, forState: UIControlState.Normal)
            cell.delegate = self
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableNumber!.isEqualToNumber(1)
        {
            return self.quotes.count
        }
        else if tableNumber!.isEqualToNumber(2)
        {
            return self.posts.count
        }
        else if tableNumber!.isEqualToNumber(3)
        {
            return self.followers.count
        }
        else
        {
            return self.following.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func queryForWhoTheCurrentUserIsFollowing()
    {
        let followerCheckQuery = Follow.query()
        followerCheckQuery?.whereKey("from", equalTo: self.theCurrentUser!)
        followerCheckQuery?.findObjectsInBackgroundWithBlock(
            {
                (results, error) -> Void in
                if results!.count > 0
                {
                    if let objects = results as? [Follow]
                    {
                        self.theCurrentUsersFollowsTo = objects
                        for follow in self.theCurrentUsersFollowsTo
                            {
                                if follow.to == self.selectedUser
                                {
                                    self.followsToDelete = follow
                                    self.followButton.setTitle("Unfollow", forState: UIControlState.Normal)
                                }
                                self.theCurrentUsersFollowsToUser.append(follow.to)
                            }
                    }
                }
                else
                {
                    self.followButton.setTitle("Follow", forState: UIControlState.Normal)

                }
            })
    }
    
    
    func queryForSelectedUserFollowers()
    {
        let followers = Follow.query()
        followers?.whereKey("to", equalTo: self.selectedUser!)
        followers?.includeKey("from")
        followers?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error == nil
            {
                self.followersCountLabel.text = String(objects!.count)

                if let results = objects as? [Follow]
                {
                    self.followers = results
//                    println(self.followers)
//                    println(self.followers.count)
//                    for follow in self.followers
//                    {
//                        println(follow.from)
//                        println(follow.from.firstName)
//                    }

                    self.followersCountLabel.text = String(self.followers.count)
                    self.tableView.setNeedsLayout()
                    self.tableView.layoutIfNeeded()
                    self.tableView.reloadData()
                }
            }
        })
    }

    func queryForSelectedUserFollowees()
    {
        let following = Follow.query()
        following?.whereKey("from", equalTo: self.selectedUser!)
        following?.includeKey("to")
        following?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error == nil
            {
                self.followingCountLabel.text = String(objects!.count)
                
                
                if let results = objects as? [Follow]
                {
                    self.following = results
                    //println(self.following)
                    //println(self.following.count)
                    for follow in self.following
                    {
                        //println(follow.to)
                        //println(follow.to.firstName)
                    }
                    self.followingCountLabel.text = String(self.following.count)
                    self.tableView.setNeedsLayout()
                    self.tableView.layoutIfNeeded()
                    self.tableView.reloadData()
                }
            }
        })
    }
    func showQuotes(sender: UITapGestureRecognizer)
    {
        tableNumber = 1
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        tableView.reloadData()
        
//        self.queryForMyQuotes()
    }
    func showPosts(sender: UITapGestureRecognizer)
    {
        tableNumber = 2
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        tableView.reloadData()
//        self.queryForPosts()
    }
    func showFollowers(sender: UITapGestureRecognizer)
    {
        tableNumber = 3
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        tableView.reloadData()
        
//        self.queryForSelectedUserFollowers()
    }
    func showFollowing(sender: UITapGestureRecognizer)
    {
        tableNumber = 4
//        self.queryForSelectedUserFollowees()
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
    }
    
    func showAlertOnViewController()
    {
        let alert = UIAlertController(title: nil, message: "Camera", preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .Default, handler: { (action1) -> Void in
            self.showTakePhotoView()
        }))
        alert.addAction(UIAlertAction(title: "Choose From Library", style: .Default, handler: { (action2) -> Void in
            self.showChooseFromLibrary()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action3) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    func showTakePhotoView()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .Camera
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func showChooseFromLibrary()
    {
        let imagePicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
        {
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(imagePicker: UIImagePickerController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        dismissViewControllerAnimated(true, completion: nil)

        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        self.profilePic.contentMode = UIViewContentMode.ScaleAspectFit
        self.profilePic.image = image
        let imageData = UIImageJPEGRepresentation(image, 0.25)
        self.theCurrentUser?.profilePic = PFFile(name: "image", data: imageData)
        self.theCurrentUser?.hasPhoto = 1
        self.theCurrentUser!.saveInBackgroundWithBlock
            {
                (success, error) -> Void in
                if (success)
                {
                    //println("saved img file to user")
                }
                else
                {
                    //println("no saved")
                }
        }
    }
    
    func changePhoto(sender: UITapGestureRecognizer)
    {
        //println("have a tap")
        self.showAlertOnViewController()
    }

    //flag delegates
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
        //println("double tap here")
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            forCell.clapImage2.alpha = 1.0
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    forCell.clapImage2.alpha = 0.0
                    }, completion: nil)
        }
        if forCell.iClapped2 == false
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
                forCell.applaudButton2.setTitle("Unapplaud", forState: UIControlState.Normal)
                self.myClaps.append(clap)
                self.quotesIClap.append(clap.quoteClapped)
                forCell.iClapped2 = true
                let newNumber = quoteToLike.likesCounter.integerValue + 1
                forCell.likeButton2.setTitle(String(newNumber), forState: UIControlState.Normal)
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
                        println("we deleted this like")
                        forCell.applaudButton2.setTitle("Applaud", forState: .Normal)
                        let u = find(self.quotesIClap, clap.quoteClapped)
                        println("the array is \(self.quotesIClap.count) and we are looking at \(u)")
                        self.quotesIClap.removeAtIndex(u!)
                        println("three")
                        let i = find(self.myClaps, clap)
                        println("the array is \(self.myClaps.count) and we are looking at \(i)")
                        self.myClaps.removeAtIndex(i!)
                        forCell.iClapped2 = false
                        let newNumber = quoteToLike.likesCounter.integerValue - 1
                        forCell.likeButton2.setTitle(String(newNumber), forState: UIControlState.Normal)
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
            }
        })
        
    }
    
    
    func sendToPoster(forQuote: Quote)
    {
        self.selectedQuote = forQuote
        let differentProfVC = storyboard?.instantiateViewControllerWithIdentifier("profile") as! ProfileVC
        differentProfVC.selectedUser = forQuote.poster
        differentProfVC.theCurrentUser = self.theCurrentUser
        self.navigationController?.showViewController(differentProfVC, sender: nil)
//        self.presentViewController(differentProfVC, animated: true, completion: nil)
    }
    
    func sendToAuthor(forQuote: Quote)
    {
        self.selectedQuote = forQuote
        let differentProfVC = storyboard?.instantiateViewControllerWithIdentifier("profile") as! ProfileVC
        
        differentProfVC.selectedUser = forQuote.saidBy
        differentProfVC.theCurrentUser = self.theCurrentUser
        self.navigationController?.showViewController(differentProfVC, sender: nil)
        
    }
    
    func sendToLikeVC(withQuote: Quote)
    {
        self.selectedQuote = withQuote
        self.performSegueWithIdentifier("showLikes", sender: nil)
    }

    //flagger delegates
    
    func toTheUserProfile(yes: Bool, forUser: PassiveUser)
    {
        let differentProfVC = storyboard?.instantiateViewControllerWithIdentifier("profile") as! ProfileVC
        differentProfVC.selectedUser = forUser
        differentProfVC.theCurrentUser = self.theCurrentUser
        self.navigationController?.showViewController(differentProfVC, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "toPost"
        {
            let postVC = segue.destinationViewController as! PostQuoteVC
            postVC.theCurrentUser = self.theCurrentUser
        }
        if segue.identifier == "showLikes"
        {
            let likeVC = segue.destinationViewController as! LikesViewController
            likeVC.quoteWithLikes = self.selectedQuote
            likeVC.theCurrentUser = self.theCurrentUser
        }

//        {
//            let profileVC = segue.destinationViewController as! ProfileVC
//            profileVC.selectedUser = self.userToShow
//            profileVC.theCurrentUser = self.theCurrentUser
//        }
        
    }
    
    func addFollow(to: PassiveUser, from: PassiveUser)
    {
        let newFollow = Follow(className: "Follow")
        newFollow.from = from
        newFollow.to = to
        var newFollowACL = PFACL()
        newFollowACL.setPublicWriteAccess(true)
        newFollowACL.setPublicReadAccess(true)
        
        newFollow.ACL = newFollowACL
        newFollow.saveInBackgroundWithBlock
            {
                (succeeded, error) -> Void in
                if error == nil
                {
                    //println("follow saved")
                    self.sendPush()
                    self.theCurrentUsersFollowsTo.append(newFollow)
                    self.theCurrentUsersFollowsToUser.append(newFollow.to)//change these arrays
                    self.tableView.reloadData()
                    if from == self.selectedUser // the current user is looking at his own profile and just followed someone (presumably who was following him)
                    {
//                        self.followingCountLabel.text = self.followingCountLabel.text + 1
                        let int : String = self.followingCountLabel.text!
                        let intIntValue = int.toInt()! + 1
                        self.followingCountLabel.text = String(intIntValue)
                    }
                    if to == self.selectedUser // the current user just followed the selected User  profile somehow through who that person follows (unlikely event)
                    {
                        let int : String = self.followersCountLabel.text!
                        let intIntValue = int.toInt()! + 1
                        self.followersCountLabel.text = String(intIntValue)
                    }
                }
        }
    }
    
    func sendPush()
    {
        let pusher = PFInstallation.query()
        pusher!.whereKey("deviceOwner", equalTo: self.selectedUser!)
        let push = PFPush()
        push.setQuery(pusher) // Set our Installation query
        let message = "\(self.theCurrentUser!.firstName) \(self.theCurrentUser!.lastName) is now following you"
        push.setMessage(message)
        push.sendPushInBackground()
        println("push should be sent")
    }
    
    
    
    func deleteFollow(to: PassiveUser, from: PassiveUser)
    {
        
        if contains(self.theCurrentUsersFollowsToUser, to)
        {
            //println("yes we have this users follow person")
            //for every follow in usersFollows where the to matches this to here, delete
            for follow in self.theCurrentUsersFollowsTo
            {
                
                if follow.to == to
                {
                    let i = find(self.theCurrentUsersFollowsTo, follow)
                    self.theCurrentUsersFollowsTo.removeAtIndex(i!)
                    let u = find(self.theCurrentUsersFollowsToUser, follow.to)
                    self.theCurrentUsersFollowsToUser.removeAtIndex(u!)
                    follow.deleteInBackgroundWithBlock({ (success, error) -> Void in
                        if error == nil
                        {
                            //println("we deleted this guy")
                            if from == self.selectedUser //the current user is looking at his own profile and just unfollowed someone (presumably who was following him)
                            {
                                //                              let int = self.followingCountLabel.text
                                let int: String = self.followingCountLabel.text!
                                let intIntValue = int.toInt()! - 1
                                self.followingCountLabel.text = String(intIntValue)
                            }
                            if to == self.selectedUser //I just unfollowed you (unlikely..how could you follow yourself)
                            {
                                let int : String = self.followingCountLabel.text!
                                let intOther: String = self.followersCountLabel.text!
                                let intIntValue = int.toInt()! - 1
                                let intOtherIntValue = intOther.toInt()! - 1
                                self.followingCountLabel.text = String(intIntValue)
                                self.followersCountLabel.text = String(intOtherIntValue)
                            }
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        }
    }
    
    func queryForMyQuotes()
    {
        let queryQuotes = Quote.query()
        queryQuotes!.whereKey("saidBy", equalTo: self.selectedUser!)
        let queryMoreQuotes = PFQuery(className: "Quote")
        queryQuotes?.orderByDescending("likesCounter")
        queryQuotes!.findObjectsInBackgroundWithBlock(
            {
                (returnedQuotes, error) -> Void in
                if error == nil
                {
                    self.quotes = returnedQuotes as! [Quote]
                    self.quotesCountLabel.text = String(self.quotes.count)
                    self.tableView.reloadData()
                    self.tableView.setNeedsLayout()
                    self.tableView.layoutIfNeeded()
                    self.tableView.reloadData()
                }
        })
    }


}
