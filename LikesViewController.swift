//
//  likesViewController.swift
//  ParseStarterProject
//
//  Created by Thomas Gibbons on 5/13/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class LikesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, flaggerDelegate
{
    
    var quoteWithLikes : Quote?
    var likes : [Clap] = []
    var userToShow : PassiveUser?
    var theCurrentUser: PassiveUser?
    var usersFollows : [Follow] = []
    var usersFollowsPeople : [PassiveUser] = []

    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.title = "Applause"
        navigationController?.navigationBar.translucent = false;
        self.queryforlikers()
        self.queryToFindWhoIFollow()
    }
    
    
    func queryforlikers()
    {
        
        
//        
//        let relation = self.quoteWithLikes?.relationForKey("upvotes")
//        let query = relation?.query()
//        query?.includeKey("liker")
//        query?.findObjectsInBackgroundWithBlock({ (returnedLikers, error) -> Void in
//            if error == nil
//            {
//                self.likes = returnedLikers as! [Clap]
//                for like in self.likes
//                {
//                }
//                self.tableView.reloadData()
//            }
//        })
//        
        let clapQuery = Clap.query()
        clapQuery?.whereKey("quoteClapped", equalTo: quoteWithLikes!)
        clapQuery?.includeKey("clapper")
        clapQuery?.findObjectsInBackgroundWithBlock({ (returnedLikers, error) -> Void in
            if error == nil
            {
                self.likes = returnedLikers as! [Clap]
                self.tableView.reloadData()
            }
        })

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellID") as! UserCell
        let upvote = self.likes[indexPath.row]
        if indexPath.row % 2 == 1
        {
            cell.profileImage.backgroundColor = UIColor(red: 218/255, green: 172/255, blue: 226/255, alpha: 1.0)
            cell.followButton.backgroundColor = UIColor(red: 162/255, green: 221/255, blue: 150/255, alpha: 1.0)
        }
        else
        {
            cell.profileImage.backgroundColor = UIColor(red: 162/255, green: 221/255, blue: 150/255, alpha: 1.0)
            cell.followButton.backgroundColor = UIColor(red: 218/255, green: 172/255, blue: 226/255, alpha: 1.0)
        }
        cell.theCurrentUser = self.theCurrentUser
        cell.selectedUser = upvote.clapper
        self.userToShow = upvote.clapper
        cell.profileImage.contentMode = UIViewContentMode.Center
        if userToShow!.hasPhoto.isEqualToNumber(0)
        {
            cell.profileImage.image = UIImage(named: "miniflatbubble")
//            cell.profileImage.contentMode = UIViewContentMode.Center
        }
        else
        {
            cell.profileImage.contentMode = UIViewContentMode.ScaleAspectFit
                upvote.clapper.profilePic.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if error == nil
                {
                    let image = UIImage(data:data!)
                    cell.profileImage.image = image
//                    cell.profileImage.contentMode = UIViewContentMode.ScaleAspectFit
                }
            })
        }
//        if userToShow!.hasPhoto.isEqualToNumber(1)
//        {
//                upvote.liker.profilePic.getDataInBackgroundWithBlock({ (data, error) -> Void in
//                if error == nil
//                {
//                    let image = UIImage(data:data!)
//                    cell.profileImage.image = image
//                    cell.profileImage.contentMode = UIViewContentMode.ScaleAspectFit
//                }
//            })
//        }
     
        if cell.theCurrentUser == upvote.clapper
        {
            cell.followButton.hidden = true
        }
        else
        {
            cell.followButton.hidden = false
        }
        let string = upvote.clapper.firstName + " " + upvote.clapper.lastName
        if contains(self.usersFollowsPeople, upvote.clapper)
        {
            cell.isFollowing = true
            cell.followButton.setTitle("Unfollow", forState: UIControlState.Normal)
        }
        else
        {
            cell.isFollowing = false
            cell.followButton.setTitle("Follow", forState: UIControlState.Normal)
        }
        cell.userButton.setTitle(string, forState: UIControlState.Normal)
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.likes.count
    }

    func toTheUserProfile(yes: Bool, forUser: PassiveUser)
    {
        self.userToShow = forUser
        self.performSegueWithIdentifier("showProfile", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let profileVC = segue.destinationViewController as! ProfileVC
        profileVC.selectedUser = self.userToShow
        profileVC.theCurrentUser = self.theCurrentUser
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
                    self.sendPush(to)
                    self.usersFollows.append(newFollow)
                    self.usersFollowsPeople.append(newFollow.to)
                    self.tableView.reloadData()
                }
        }
    }
    
    func sendPush(receiverOfNotification: PassiveUser)
    {
        let pusher = PFInstallation.query()
        pusher!.whereKey("deviceOwner", equalTo: receiverOfNotification)
        let push = PFPush()
        push.setQuery(pusher) // Set our Installation query
        let message = "\(self.theCurrentUser!.firstName) \(self.theCurrentUser!.lastName) is now following you"
        push.setMessage(message)
        push.sendPushInBackground()
        println("push should be sent")
    }
    
    func deleteFollow(to: PassiveUser, from: PassiveUser)
    {
        
        if contains(self.usersFollowsPeople, to)
        {
            //println("yes we have this users follow person")
            //for every follow in usersFollows where the to matches this to here, delete
            for follow in self.usersFollows
            {
            
                if follow.to == to
                {
                    let i = find(self.usersFollows, follow)
                    self.usersFollows.removeAtIndex(i!)
                    let u = find(self.usersFollowsPeople, follow.to)
                    self.usersFollowsPeople.removeAtIndex(u!)
                    follow.deleteInBackgroundWithBlock({ (success, error) -> Void in
                        if error == nil
                        {
                            //println("we deleted this guy")
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        }
//        let query = Follow.query()
//        query?.whereKey("to", equalTo: to)
//        query?.whereKey("from", equalTo: from)
//        query?.findObjectsInBackgroundWithBlock({ (follows, error) -> Void in
//            if error == nil
//            {
//                let followsToDelete = follows as! [Follow]
////                followsToDelete.delete
//                
//                ///deleting followers is being a biotch
//            }
//        })
        
    }
    
    func queryToFindWhoIFollow()
    {
        let followerCheckQuery = Follow.query()
        followerCheckQuery?.whereKey("from", equalTo: self.theCurrentUser!)
        followerCheckQuery?.findObjectsInBackgroundWithBlock(
            {
                (results, error) -> Void in
                if error == nil
                    {
                       self.usersFollows =  results as! [Follow]
                        for follow in self.usersFollows
                        {
                            self.usersFollowsPeople.append(follow.to)
                        }
                        self.tableView.reloadData()

                    }
            })
    }



}
