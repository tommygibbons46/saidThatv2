//
//  PassiveUser.swift
//  ParseStarterProject
//
//  Created by Thomas Gibbons on 5/6/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

class PassiveUser: PFObject, PFSubclassing
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
            return "PassiveUser"
        }
    
    
    @NSManaged var phoneNumber : String
    @NSManaged var firstName : String
    @NSManaged var lastName : String
    @NSManaged var password : String
    @NSManaged var verified : NSNumber
    @NSManaged var profilePic : PFFile
    @NSManaged var hasPhoto : NSNumber
    

    
    
    

}
