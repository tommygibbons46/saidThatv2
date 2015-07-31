//
//  QuoteCell.swift
//  ParseStarterProject
//
//  Created by Thomas Gibbons on 5/7/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit

protocol flagDelegate
{
    
    func theUserHitFlagButton(yes: Bool, forCell: Quote)
    
    func theUserDoubleTapped(yes: Bool, forCell: QuoteCell, andQuote: Quote)
    
    func createLike(quoteToLike: Quote, forCell: QuoteCell)
    func deleteLike(quoteToLike: Quote, forCell: QuoteCell)
    
    func sendToLikeVC(withQuote: Quote)
    
    func sendToAuthor(forQuote: Quote)
    func sendToPoster(forQuote: Quote)
}

class QuoteCell: UITableViewCell, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var clapImage: UIImageView!
    
    @IBOutlet weak var clapImage2: UIImageView!
    @IBOutlet weak var qTextLabel: UILabel!
    
    @IBOutlet weak var posterButton: UIButton!
    
    @IBOutlet weak var saidbyPicture: UIImageView!
    
    @IBOutlet weak var quoteDetails: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var likeButton2: UIButton!
    @IBOutlet weak var quoteDetails2: UILabel!
    @IBOutlet weak var posterButton2: UIButton!
    @IBOutlet weak var qTextLabel2: UILabel!
    @IBOutlet weak var authorButton2: UIButton!
    @IBOutlet weak var authorButton: UIButton!
    
    @IBOutlet weak var applaudButton: UIButton!
    @IBOutlet weak var applaudButton2: UIButton!
    @IBOutlet weak var flagButton2: UIButton!
    var iClapped : Bool?
    var iClapped2 : Bool?
    
    var programImage : UIImageView!
    
    var alert : UIAlertController!
    var delegate: flagDelegate?
    var selectedQuote : Quote?
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
//        self.qTextLabel.numberOfLines = 0
//        self.qTextLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.addDoubleTap()
    }
    
    
    func addDoubleTap()
    {
        let doubleTap = UITapGestureRecognizer(target: self, action: "addApplause:")
        doubleTap.numberOfTapsRequired = 2
        self.contentView.addGestureRecognizer(doubleTap)
    }
    
    func addApplause(recognizer: UITapGestureRecognizer)
    {
        delegate?.theUserDoubleTapped(true, forCell: self, andQuote: selectedQuote!)
    }
    
    
    @IBAction func applaudButton2Tap(sender: AnyObject)
    {
        if iClapped2 == true
        {
            delegate?.deleteLike(selectedQuote!, forCell: self)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.clapImage2.alpha = 1.0
                }) { (finished) -> Void in
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.clapImage2.alpha = 0.0
                        }, completion: nil)
            }

        }
        else
        {
            delegate?.createLike(selectedQuote!, forCell: self)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.clapImage2.alpha = 1.0
                }) { (finished) -> Void in
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.clapImage2.alpha = 0.0
                        }, completion: nil)
            }
        }
        
    }
    
    @IBAction func flagButton2tap(sender: AnyObject)
    {
        //println("flag tapped")

        delegate?.theUserHitFlagButton(true, forCell: selectedQuote!)
    }
    @IBAction func authorButtonTap(sender: AnyObject)
    {
        delegate?.sendToAuthor(selectedQuote!)
    }
    
    @IBAction func posterButton2Tap(sender: AnyObject)
    {
        println("poster child 2")
        delegate?.sendToPoster(selectedQuote!)
    }
    
    @IBAction func authorButton2Tap(sender: AnyObject)
    {
        delegate?.sendToAuthor(selectedQuote!)
    }
    @IBAction func posterButtonTap(sender: AnyObject)
    {
        println("poster child 1")
        delegate?.sendToPoster(selectedQuote!)
    }
    
    
    @IBAction func postaButtonTap(sender: UIButton)
    {
        println("hello my friend")
    }

    @IBAction func applauseTap(sender: AnyObject)
    {
        if iClapped == true
        {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.clapImage.alpha = 1.0
                }) { (finished) -> Void in
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.clapImage.alpha = 0.0
                        }, completion: nil)
            }
            delegate?.deleteLike(selectedQuote!, forCell: self)
        }
        else
        {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.clapImage.alpha = 1.0
                }) { (finished) -> Void in
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.clapImage.alpha = 0.0
                        }, completion: nil)
            }
            delegate?.createLike(selectedQuote!, forCell: self)
        }
        
    }
    @IBAction func flagButtonTap(sender: AnyObject)
    {
        //println("flag tapped")
        delegate?.theUserHitFlagButton(true, forCell: selectedQuote!)
    }
    

    @IBAction func likeButton2Tap(sender: AnyObject)
        
    {
        delegate?.sendToLikeVC(selectedQuote!)
    }
    @IBAction func likeButtonTap(sender: AnyObject)
    {
        delegate?.sendToLikeVC(selectedQuote!)
    }
    
    

    
}
