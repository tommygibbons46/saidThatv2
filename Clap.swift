//
//  Clap.swift
//  saidThat
//
//  Created by Thomas Gibbons on 7/13/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation

class Clap: PFObject, PFSubclassing {
    
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
        return "Clap"
    }
    
    @NSManaged var clapper : PassiveUser
    @NSManaged var quoteClapped : Quote
    


    
    
    
    
    

   
}
