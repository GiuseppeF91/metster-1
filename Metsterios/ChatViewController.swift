//
//  ChatViewController.swift
//  Metsterios
//
//  Created by iT on 5/13/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//


import UIKit
import Firebase
import Haneke

class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource,UITableViewDelegate {
    
    var messages = [Message]()
    var messagepicid = [String]()
    var avatars = Dictionary<String, UIImage>()
    
    var senderImageUrl: String! = ""
    var batchMessages = true
    var ref: Firebase!
    
    var groupId :String!
    var username :String!
    var profilephoto :String!
    var sender_id : String!
    var chatid : String!
    // *** STEP 1: STORE FIREBASE REFERENCES
    var messagesRef: Firebase!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var buddyChatTable: UITableView!
    @IBOutlet weak var textmessage: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    var timerReload:NSTimer!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        lblUsername!.text = username;
        
        print ("Enter chat view controller")
        print ("FROM : \(Users.sharedInstance().from_chat!)")
        print ("To: \(Users.sharedInstance().to_chat!)")
        
        let f = Users.sharedInstance().from_chat! as! String
        let t = Users.sharedInstance().to_chat! as! String
        
        let a = Int(f as String)
        let b = Int(t as String)
        
        print (a)
        print (b)
        
        print (f.compare(t))
        let diff = f.compare(t)
        print(diff.rawValue)
        
        chatid = "\(Users.sharedInstance().from_chat!)-\(Users.sharedInstance().to_chat!)"
        if (diff.rawValue > 0){
            chatid = "\(Users.sharedInstance().from_chat!)-\(Users.sharedInstance().to_chat!)"
        } else {
            chatid = "\(Users.sharedInstance().to_chat!)-\(Users.sharedInstance().from_chat!)"
        }
        
        print(chatid as String)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardShowNotifier:"), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardHideNotifier:"), name: UIKeyboardWillHideNotification, object: nil)
        self.buddyChatTable.estimatedRowHeight = 60
        self.buddyChatTable.rowHeight = UITableViewAutomaticDimension
        setupFirebase()
        
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    @IBAction func tapedButton(sender: UIButton) {
        
        if sender == btnBack {
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }else if sender == sendButton {
            
            if (textmessage.text?.stringByReplacingOccurrencesOfString(" ", withString: "") == "")
            {
                return;
            }
            sendMessage(textmessage.text, sender: sender_id)
            
            
        }
        
    }
    
    
    func setupFirebase() {
        // *** STEP 2: SETUP FIREBASE
        messagesRef = Firebase(url: "https://metster-chat.firebaseio.com/messages/" + self.chatid)
        
        // *** STEP 4: RECEIVE MESSAGES FROM FIREBASE (limited to latest 25 messages)
        messagesRef.observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
            let text = snapshot.value["text"] as? String
            let sender = snapshot.value["sender"] as? String
            let imageUrl = snapshot.value["imageUrl"] as? String
            
            let message = Message(text: text, sender: sender, imageUrl: imageUrl)
            self.messages.append(message)
            self.messagepicid.append(sender!)
            if self.timerReload != nil
            {
                self.timerReload.invalidate()
            }
            
            self.timerReload = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: Selector("onChatReload"), userInfo: nil, repeats: false)
            
            
        })
        
        
    }
    func onChatReload()
    {
        
        self.buddyChatTable.reloadData()
        let indexpath = NSIndexPath(forRow: self.messages.count-1, inSection: 0)
        self.buddyChatTable .scrollToRowAtIndexPath(indexpath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
    }
    func sendMessage(text: String!, sender: String!) {
        // *** STEP 3: ADD A MESSAGE TO FIREBASE
        messagesRef.childByAutoId().setValue([
            "text":text,
            "sender":sender,
            "imageUrl":senderImageUrl
            ])
        
        self.textmessage.text = ""
        
    }
    
    
    
    // method for tableview
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return self.messages.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        let constraints :CGSize  = CGSizeMake(((self.view.frame.size.width)/2 + 8.0),100000)
        
        var wrapperViewHeight = 0.0 as CGFloat
        
        let message = messages[indexPath.row]

        
        
        // print(usrid)
        let messageString = message.text() as NSString
        let textView: UITextView = UITextView()
        
        
        textView.font = UIFont.systemFontOfSize(14.0)
        textView.textContainerInset = UIEdgeInsetsZero
        textView.backgroundColor = UIColor.clearColor()
        
        
        /* Disable scroll and editing */
        textView.editable = false
        textView.scrollEnabled = false
        
        
        messageString.boundingRectWithSize(constraints, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)], context: nil)
        
        
        textView.text = messageString as String
        textView.textColor = UIColor.blackColor()
        
        let sizeMessage:CGSize = textView.sizeThatFits(constraints)
        
        wrapperViewHeight =  4.0 + sizeMessage.height+52  + 4.0;
        
        return wrapperViewHeight;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : UITableViewCell
        
        cell = tableView.dequeueReusableCellWithIdentifier("ChatCell", forIndexPath: indexPath)
        
        for view  in cell.contentView.subviews
        {
            view.removeFromSuperview()
        }
        
        
        let constraints :CGSize  = CGSizeMake(((self.view.frame.size.width)/2 + 30.0),100000)
        var  wrapperViewX = 0.0 as CGFloat
        var  wrapperViewWidth = 0.0 as CGFloat
        var wrapperViewHeight = 0.0 as CGFloat
        
        let message = messages[indexPath.row]
        
        
        let messageString = message.text() as NSString
        
        let wrapperView: UIView  = UIView()
        let textView: UITextView = UITextView()
        var imageView:UIImageView  = UIImageView()
        let imageBubble:UIImageView = UIImageView()
        
        
        /* Disable scroll and editing */
        textView.editable = false
        textView.scrollEnabled = false
        
        
        messageString.boundingRectWithSize(constraints, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)], context: nil)
        
        
        textView.text = messageString as String
        textView.textColor = UIColor.blackColor()
        
        let sizeMessage:CGSize = textView.sizeThatFits(constraints)
        
        
        textView.frame = CGRectMake(15,37, sizeMessage.width, sizeMessage.height)
        imageBubble.frame = CGRectMake(0,0, constraints.width+35, sizeMessage.height+52);
        
        
        imageView.frame = CGRectMake(15, 10, 10, 10)
        imageView.layer.borderWidth = 0.3
        //profImage?.layer.cornerRadius = 5
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.blackColor().CGColor
        imageView.layer.cornerRadius = imageView.frame.width/2
        imageView.clipsToBounds = true
        
        wrapperView.layer.cornerRadius = 5
        wrapperView.clipsToBounds = true
        
        textView.font = UIFont.systemFontOfSize(14.0)
        textView.textContainerInset = UIEdgeInsetsZero
        textView.backgroundColor = UIColor.clearColor()
        
        
        wrapperView.addSubview(imageView)
        wrapperView.addSubview(imageBubble)
        wrapperView.addSubview(textView)
        
        if message.sender().compare(sender_id) == NSComparisonResult.OrderedSame
        {
            
            wrapperViewX = self.view.frame.size.width - (constraints.width+35) - 14
            imageBubble.image = UIImage(named: "bubble_mine.png")?.resizableImageWithCapInsets(UIEdgeInsetsMake(7, 7, 16, 16))
            
            
        } else {
            wrapperViewX = 7.0
            imageBubble.image = UIImage(named: "bubble_someone.png")?.resizableImageWithCapInsets(UIEdgeInsetsMake(7, 16, 16, 7))
        }
        
        wrapperViewWidth = 4.0 + imageBubble.frame.size.width + 4.0;
        wrapperViewHeight =  4.0 + imageBubble.frame.size.height  + 4.0;
        
        
        wrapperView.frame  = CGRectMake(wrapperViewX, 7.0, wrapperViewWidth, wrapperViewHeight)
    
        
        let usrid = messagepicid[indexPath.row]
        
        let access = usrid
        let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(access)/picture?type=large")
        print("image for ")
        print("http://graph.facebook.com/\(access)/picture?type=large")
        //---- cache image management
        let cache = Shared.dataCache
        cache.fetch(key: access).onFailure { data in
            
            print (access)
            let task = NSURLSession.sharedSession().dataTaskWithURL(facebookProfileUrl!
            ) { (responseData, responseUrl, error) -> Void in
                if let data = responseData{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let image : UIImage = UIImage(data: data)!.resizableImageWithCapInsets(UIEdgeInsetsMake(7, 16, 16, 7))
                        imageView.image = image
                        cache.set(value: image.asData(), key: access)
                    })
                }
            }
            task.resume()
            
        }
        
        cache.fetch(key: access).onSuccess { data in
            print ("data was found in cache for a friend")
            let image : UIImage = UIImage(data: data)!
            imageView.image = image
        }
        //imageView.hidden = false
        //-----
        
        
        let _formatter:NSDateFormatter = NSDateFormatter()
        _formatter.locale = NSLocale.currentLocale()
        
        _formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        _formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        _formatter.doesRelativeDateFormatting = true;
        
        let timeString:NSString = _formatter.stringFromDate(message.date())
        
        let timeLabel:UILabel = UILabel()
        timeLabel.font  = UIFont.systemFontOfSize(10)
        timeLabel.textColor = UIColor.whiteColor()
        timeLabel.numberOfLines = 0
        timeLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        messageString.boundingRectWithSize(constraints, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)], context: nil)
        
        let timeRect:CGRect  = timeString.boundingRectWithSize(constraints, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(10)], context: nil)
        let sizeTime:CGSize  = timeRect.size;
        timeLabel.text = timeString as String
        
        if message.sender().compare(sender_id) == NSComparisonResult.OrderedSame
        {
            
            
            wrapperView.backgroundColor = UIColor.clearColor()
            
            timeLabel.frame = CGRectMake(wrapperViewWidth-sizeTime.width-15, 10, sizeTime.width, sizeTime.height)
            
        } else {
            
            
            wrapperView.backgroundColor = UIColor.clearColor()
            
            timeLabel.frame = CGRectMake(15, 10, sizeTime.width, sizeTime.height)
            
        }
        
        wrapperView.addSubview(timeLabel)
        
        cell.contentView.addSubview(wrapperView)
        
        
        
        return cell
    }
    
    
    
    func keyboardShowNotifier(notification : NSNotification)
    {
        
        
        var info = notification.userInfo!
        let keyboardFrame :CGRect = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
        self.bottomConstraint.constant = keyboardFrame.size.height
        self.bottomView.updateConstraintsIfNeeded()
        self.bottomView.layoutIfNeeded()
        
    }
    
    func keyboardHideNotifier(notification : NSNotification)
    {
        
        self.bottomConstraint.constant = 0
        self.bottomView.updateConstraintsIfNeeded()
        self.bottomView.layoutIfNeeded()
        
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}