

import Foundation

class Quote: PFObject, PFSubclassing
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
        return "Quote"
    }
    
    @NSManaged var quoteText : String
    @NSManaged var saidBy : PassiveUser
    @NSManaged var activeAuthor : NSNumber
    @NSManaged var poster : PassiveUser
    @NSManaged var upvotes : PFRelation
    @NSManaged var isFlagged : NSNumber
    @NSManaged var likesCounter : NSNumber
    @NSManaged var quoteIsRiding : NSNumber
    @NSManaged var quoteIsClapped : NSNumber

    

    
    
    

    
}
