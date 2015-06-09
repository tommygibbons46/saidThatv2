//
//  Follow.swift
//  ParseStarterProject
//
//  Created by Thomas Gibbons on 5/6/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class Follow: PFObject, PFSubclassing


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
        return "Follow"
    }
    
    @NSManaged var friendTime : NSDate
    @NSManaged var from : PassiveUser
    @NSManaged var to : PassiveUser
    
    
}