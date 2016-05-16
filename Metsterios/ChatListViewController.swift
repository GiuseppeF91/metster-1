//
//  ChatListViewController.swift
//  Metsterios
//
//  Created by iT on 5/16/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import Firebase
import Haneke

class ChatListViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource{

    var chatHistoryArray : NSMutableArray = []
    @IBOutlet weak var tblChatHistory: UITableView!

    
    var recentRef: Firebase!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupFirebase()
    }
    
    
    func setupFirebase() {
        // *** STEP 2: SETUP FIREBASE
        recentRef = Firebase(url: "https://metster-chat.firebaseio.com/Recent")
        
        let query = recentRef.queryOrderedByChild("userId").queryEqualToValue(Users.sharedInstance().fbid) as! FQuery
        
        // *** STEP 4: RECEIVE MESSAGES FROM FIREBASE (limited to latest 25 messages)
        query.observeEventType(FEventType.Value, withBlock: { (snapshot :FDataSnapshot!) in
            
            self.chatHistoryArray.removeAllObjects()
            
            if !snapshot.value.isEqual(NSNull())
            {
                let arrayValues = snapshot.value.allValues as NSArray
                let sorted = arrayValues.sortedArrayUsingComparator {
                    (obj1, obj2) -> NSComparisonResult in
                    
                    let recent1 = obj1 as! NSDictionary
                    let recent2 = obj2 as! NSDictionary
                    let date1 = NSDate.dateFromMilliseconds(recent1.objectForKey("date") as! String)  as NSDate
                    
                    let date2 = NSDate.dateFromMilliseconds(recent2.objectForKey("date") as! String)  as NSDate
                    
                    return date2.compare(date1)
                } as NSArray
                
                for recent in sorted
                {
                    self.chatHistoryArray.addObject(recent)
                    
                }
                
                self.tblChatHistory.reloadData()
            }
        })
        
        
    }
    
    
    
    //MARK : Table View delegate & data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatHistoryArray.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : ChatHistoryTableViewCell
        
        
        
        cell = tableView.dequeueReusableCellWithIdentifier("ChatHistoryCell", forIndexPath: indexPath)   as! ChatHistoryTableViewCell
        
        let messageDic = self.chatHistoryArray.objectAtIndex(Int(indexPath.row)) as! NSDictionary
        let access = messageDic.objectForKey("userId") as! String
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
                        cell.imgPhoto.image = image
                        cache.set(value: image.asData(), key: access)
                    })
                }
            }
            task.resume()
            
        }
        
        cache.fetch(key: access).onSuccess { data in
            print ("data was found in cache for a friend")
            let image : UIImage = UIImage(data: data)!
            cell.imgPhoto.image = image
        }
        
        cell.lblName.text = messageDic.objectForKey("userName") as!  String
        cell.lblMessage.text = messageDic.objectForKey("lastMessage") as!  String
        cell.lblTime.text = NSDate.dateDiff(messageDic.objectForKey("date") as!  String)
        
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let messageDic = self.chatHistoryArray.objectAtIndex(Int(indexPath.row)) as! NSDictionary
        
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        let chatViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        chatViewController.groupId = messageDic["groupId"] as! String
        chatViewController.sender_id = Users.sharedInstance().fbid  as! String
        chatViewController.username = Users.sharedInstance().name as! String
        
        self.presentViewController(chatViewController, animated: true, completion: nil)

        
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        print ("enter select option")
        
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            print("delete button tapped")
            print(Users.sharedInstance().event_id)
        }
        delete.backgroundColor = darkBlue
        
        return [delete]
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
