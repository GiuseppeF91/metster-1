//
//  ProfileViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import Haneke
import AWSCognito
import AWSS3

class ProfileViewController: BaseVC,NSURLSessionDataDelegate ,UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    
    var mode = "edit"
    
    var logoutButton = LogoutButton(frame: CGRectMake(0, (screenHeight)-(screenHeight/15)-60, screenWidth, screenHeight/14.5))
    
    var notifyButton = ProfileButton(frame: CGRectMake(0, screenHeight/2 + (screenHeight/16)*2 + 20, screenWidth, screenHeight/14.5))
    var notifySwitch = UISwitch(frame:CGRectMake(20, screenHeight/2 + (screenHeight/16)*2 + 25, 0, 0))
    
    var publishButton = ProfileButton(frame: CGRectMake(0, screenHeight/2 + (screenHeight/15)*3 + 30, screenWidth, screenHeight/14.5))
    var publishSwitch = UISwitch(frame:CGRectMake(0, screenHeight/2 + (screenHeight/15)*3 + 35, 0, 0))

    
    var notesTextField = MainTextField(frame: CGRectMake(20, (screenHeight/2)+30, screenWidth-40, 30))
    var editButton = UIButton(frame: CGRectMake(20, (screenHeight/2)+62, 70, 30))
    
    var nameLabel = UILabel(frame: CGRectMake(20, screenHeight/2.5, screenWidth-40, 40))
    var aboutLabel = UILabel(frame: CGRectMake(20, (screenHeight/2), screenWidth-40, 40))
    var aboutme = UILabel(frame: CGRectMake(20, (screenHeight/2)+30, screenWidth-40, 30))
    var gidLabel = UILabel(frame: CGRectMake(20, (screenHeight/2.5) + 20, screenWidth-40, 40))
    var profImage : UIImageView?
    var profButton: UIButton?
    var imageView : UIImageView?
    
    let ref = Firebase(url: "https://metsterios.firebaseio.com")
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
         print("====== ENTER Profile View Controller =====")
        
        notifyButton.setTitle("Notifications", forState: .Normal)
        //notifyButton.textAlignment = NSTextAlignment.Left
        self.view.addSubview(notifyButton)
        
        notifySwitch.on = true
        notifySwitch.setOn(true, animated: false)
        //switchDemo.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged);
        self.view.addSubview(notifySwitch)
        
        publishButton.setTitle("Publish Activity", forState: .Normal)
        self.view.addSubview(publishButton)
        
        publishSwitch.on = true
        publishSwitch.setOn(true, animated: false)
        //switchDemo.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged);
        self.view.addSubview(publishSwitch)
        publishButton.hidden = true
        publishSwitch.hidden = true 
        
        imageView  = UIImageView(frame:CGRectMake((screenWidth/2)-30, (screenHeight)-(screenHeight/15)-110, 50, 50));
        imageView!.image = UIImage(named:"bannerimg.jpg")
        self.view.addSubview(imageView!)
        
        let notes=NSAttributedString(string: "About me:", attributes:    [NSForegroundColorAttributeName : UIColor.grayColor().colorWithAlphaComponent(0.6)])
        notesTextField.attributedPlaceholder=notes
        notesTextField.delegate = self
        self.view.addSubview(notesTextField)
        notesTextField.hidden = true
        
        editButton.backgroundColor = UIColor.whiteColor()
        editButton.layer.cornerRadius = 5
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        editButton.setTitle("edit", forState: UIControlState.Normal)
        editButton.setTitleColor(UIColor(red: 0, green: 0.6549, blue: 0.9373, alpha: 1.0), forState: UIControlState.Normal)
        editButton.addTarget(self, action: #selector(ProfileViewController.editpressed), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(editButton)
        editButton.hidden = false
        
        logoutButton.setTitle("Logout", forState: .Normal)
        logoutButton.addTarget(self, action: #selector(ProfileViewController.logoutClicked), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(logoutButton)
        
        //make "upload" folder to temp directory.
        let error = NSErrorPointer()
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(
                NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload"),
                withIntermediateDirectories: true,
                attributes: nil)
        } catch let error1 as NSError {
            error.memory = error1
            print("Creating 'upload' directory failed. Error: \(error)")
        }
        
        imagePicker.delegate = self
        
        
        //
        
        //
        profImage = UIImageView(frame: CGRectMake(screenWidth/4, screenHeight/9, self.view.bounds.width * 0.50 , self.view.bounds.height * 0.29))
        profImage?.layer.borderWidth = 0.3
        //profImage?.layer.cornerRadius = 5
        profImage?.layer.masksToBounds = false
        profImage?.layer.borderColor = UIColor.blackColor().CGColor
        profImage?.layer.cornerRadius = profImage!.frame.width/2
        profImage?.clipsToBounds = true
        self.view.addSubview(profImage!)
        
        //
        profButton = UIButton(frame: CGRectMake(screenWidth/4, screenHeight/9, self.view.bounds.width * 0.50 , self.view.bounds.height * 0.29))
        profButton?.addTarget(self, action: #selector(ProfileViewController.onTapSelectPhoto(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(profButton!)
        //
        //-----
        
        nameLabel.textAlignment = NSTextAlignment.Center
        
        nameLabel.font = UIFont(name: "HelveticaNeue", size: 20)
        nameLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(self.nameLabel)
        
        
        aboutLabel.textAlignment = NSTextAlignment.Left
        aboutLabel.text = "About me:"
        aboutLabel.font = UIFont(name: "HelveticaNeue", size: 15)
        aboutLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(self.aboutLabel)
        
        aboutme.textAlignment = NSTextAlignment.Left
        
        print(Users.sharedInstance().aboutme)
        aboutme.font = UIFont(name: "HelveticaNeue", size: 15)
        aboutme.adjustsFontSizeToFitWidth = true
        view.addSubview(self.aboutme)
        aboutme.hidden = false
        
        gidLabel.textAlignment = NSTextAlignment.Center
        
        gidLabel.font = UIFont(name: "HelveticaNeue", size: 20)
        gidLabel.textColor = UIColor.lightGrayColor()
        gidLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(self.gidLabel)
    }
    
    func editpressed(){
        if(mode as String == "edit") {
            self.aboutme.hidden = true
            self.notesTextField.hidden = false
            editButton.setTitle("save", forState: UIControlState.Normal)
            self.mode = "save"
            // call the update function to save
            
        } else {
            self.notesTextField.hidden = true
            self.aboutme.hidden = false
            let me = self.notesTextField.text
            self.aboutme.text = me
            Users.sharedInstance().lat = "37.40979875856781"
            Users.sharedInstance().long = "-122.0975197813783"
            Users.sharedInstance().aboutme = me! as String
            RequestInfo.sharedInstance().postReq("111003")
            { (success, errorString) -> Void in
                guard success else {
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Unable to save preference")
                        self.alertMessage("Error", message: "Unable to update.")
                    })
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    print("suucssssss")
                    self.alertMessage("Preference Saved!", message: "")
                })
            }
            
            editButton.setTitle("edit", forState: UIControlState.Normal)
            self.mode = "edit"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let cache = Shared.dataCache
        let access = Users.sharedInstance().fbid as! String
        let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(access)/picture?type=large")
        
        
        
        //---- cache image management
        cache.fetch(key: "profile_image.jpg").onFailure { data in
            
            print ("data was not found in cache")
            let task = NSURLSession.sharedSession().dataTaskWithURL(facebookProfileUrl!
            ) { (responseData, responseUrl, error) -> Void in
                if let data = responseData{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.profImage!.image = UIImage(data: data)
                        let image : UIImage = UIImage(data: data)!
                        cache.set(value: image.asData(), key: "profile_image.jpg")
                    })
                }
            }
            task.resume()
            
        }
        
        cache.fetch(key: "profile_image.jpg").onSuccess { data in
            print ("data was found in cache")
            let image : UIImage = UIImage(data: data)!
            self.profImage!.image = image
        }
        
        nameLabel.text = Users.sharedInstance().name as? String
        aboutme.text = Users.sharedInstance().aboutme as? String
        gidLabel.text = Users.sharedInstance().gid as? String
        
    }
    func uploadImage(image:UIImage) -> Bool {
        let uniqueString = NSProcessInfo.processInfo().globallyUniqueString //generate unique string
        
        var fileName = uniqueString.stringByAppendingString("_full").stringByAppendingString(".jpg")//make filename
        
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").URLByAppendingPathComponent(fileName)
        let filePath = fileURL.path!
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        imageData!.writeToFile(filePath, atomically: true)
        
        
        let getPreSignedURLRequest  = AWSS3GetPreSignedURLRequest() as AWSS3GetPreSignedURLRequest
        getPreSignedURLRequest.bucket = "metsterios"                          //set bucket "tartoob1"
        getPreSignedURLRequest.key = fileName                               //set file name
        getPreSignedURLRequest.HTTPMethod = .PUT                            //set mothod
        getPreSignedURLRequest.expires = NSDate(timeIntervalSinceNow: 3600)
        
        
        getPreSignedURLRequest.contentType = "image/jpg";                   //set content type to jpg
        
        AWSS3PreSignedURLBuilder .defaultS3PreSignedURLBuilder().getPreSignedURL(getPreSignedURLRequest) .continueWithBlock { (task:AWSTask!) -> AnyObject! in
            if (task.error != nil)
            {
                
                let userDefaults = NSUserDefaults.standardUserDefaults()
                let bucketfileData = userDefaults.objectForKey("bucketfilelist")?.mutableCopy() as! NSMutableDictionary
                print("add file: task error \(fileName)" )
                bucketfileData.setObject("s3", forKey: fileName)
                userDefaults.synchronize()
                
            }else
            {
                if (task.result != nil) {
                    let presignedURL = task.result as! NSURL
                    let request = NSMutableURLRequest(URL: presignedURL) as NSMutableURLRequest
                    request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
                    request.HTTPMethod = "PUT"
                    request.setValue("image/jpg", forHTTPHeaderField: "Content-Type")
                    
                    let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(fileName)
                    
                    let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
                    
                    
                    let uploadTask = session .uploadTaskWithRequest(request, fromFile:fileURL)
                    uploadTask .resume()
                }
            }
            return nil
        }
        
        return true
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error == nil
        {
            print("Success!")
 
            print("file url http://d3uqben18grrms.cloudfront.net/\(session.configuration.identifier!)")
 
            
            
        }else
        {
            
            
            print("add file:session error \(session.configuration.identifier!)" )
         
            
        }
        
    }
    
    @IBAction func onTapSelectPhoto(sender: AnyObject) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "", preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
        let takePictureAction: UIAlertAction = UIAlertAction(title: "Take Picture", style: .Default) { action -> Void in
            //Code for launching the camera goes here
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .Camera
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            
        }
        actionSheetController.addAction(takePictureAction)
        //Create and add a second option action
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "Choose From Camera Roll", style: .Default) { action -> Void in
            //Code for picking from camera roll goes here
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            
        }
        actionSheetController.addAction(choosePictureAction)
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }

    //MARK: imagepicker delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {

            var cropedImage = ImageUtil.cropToSquare(image: pickedImage)
            cropedImage = ImageUtil.scaleImage(pickedImage, toSize: CGSizeMake(100, 100))
            self.uploadImage(cropedImage)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func logoutClicked() {
        let cache = Shared.dataCache
        cache.removeAll()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}