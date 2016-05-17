//
//  DetailViewController.swift
//  Metsterios
//
//  Created by iT on 5/17/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var txtAboutme: UITextView!
    var photoArray : [String] = ["http://d34rt3nrucum7c.cloudfront.net/styles/two_thirds_tall_header/s3/gallery/DMG_Taylor%20Swift_REX_11_1164x1668.jpg?itok=DDAj8rM6","https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcRjNFp4dXFEY9W0mOPHmS0CimPdSPgpVKwqzj7pobT7vZPWdnxe", "https://img.buzzfeed.com/buzzfeed-static/static/2014-12/18/8/enhanced/webdr02/enhanced-17823-1418909825-10.jpg", "http://cdn1.images.popstaronline.com/wp-content/uploads/2014/07/ee05a504f9e.jpg", "http://i.dailymail.co.uk/i/pix/2014/07/24/article-2704467-1FF3DC9A00000578-908_634x933.jpg"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var i = 0
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        for photoUrl in photoArray
        {
            var imageView = UIImageView()
            imageView.frame = CGRectMake(screenWidth * CGFloat(i), 0, screenWidth, self.scrollview.bounds.size.height)
            imageView.hnk_setImageFromURL(NSURL(string: photoUrl)!)
            self.scrollview.addSubview(imageView)
            i = i + 1
            
        }
        self.scrollview.contentSize = CGSizeMake(screenWidth * CGFloat(photoArray.count), self.scrollview.frame.size.height)
    
        self.scrollview.pagingEnabled = true
        self.scrollview.delegate = self
        self.pageControl.currentPage = 0
        self.pageControl.numberOfPages = photoArray.count
        self.txtAboutme.text = Users.sharedInstance().aboutme as! String
    }

    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = CGRectGetWidth(scrollView.frame)
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.pageControl.currentPage = Int(currentPage);
        
        
    }
    
    @IBAction func onTapBack(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
