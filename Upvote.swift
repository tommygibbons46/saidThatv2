//
//  Upvote.swift
//  ParseStarterProject
//
//  Created by Thomas Gibbons on 5/6/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class Upvote: PFObject, PFSubclassing
{
    override class func initialize()
    {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken)
            {
                self.registerSubclass()
            }
    }
    
    class func parseClassName() -> String
    {
        return "Upvote"
    }
    
    @NSManaged var liker : PassiveUser
    @NSManaged var quote : Quote    
    
}
