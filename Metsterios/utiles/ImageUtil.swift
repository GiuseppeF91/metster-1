//
//  ImageUtil.swift
//  Metsterios
//
//  Created by iT on 5/18/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit

class ImageUtil: NSObject {
    
    static func cropToSquare(image originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage!)
        
        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size
        
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        if contextSize.width > contextSize.height {
            posX = (contextSize.width - contextSize.height)/2
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = (contextSize.height - contextSize.width)/2
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        
        
        var angle = 0.0;
        
        if (image.imageOrientation == UIImageOrientation.Right)
        {
            angle = 0
        }
        else if (image.imageOrientation == UIImageOrientation.Left)
        {
            angle = 180
        }
        else if (image.imageOrientation == UIImageOrientation.Down)
        {
            angle = -90
        }
        else if (image.imageOrientation == UIImageOrientation.Up)
        {
            angle = 90
            
        }
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: width))
        let cgContext = UIGraphicsGetCurrentContext()
        
        let offset = width / 2.0
        
        CGContextTranslateCTM(cgContext, offset, offset)
        CGContextRotateCTM(cgContext, CGFloat(angle * M_PI / 180))
        
        
        image.drawAtPoint(CGPoint(x: -offset, y: -offset))
        
        let final = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return final
    }
    
    static func scaleImage(image: UIImage, toSize newSize: CGSize) -> (UIImage) {
        let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, .High)
        let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
        CGContextConcatCTM(context, flipVertical)
        CGContextDrawImage(context, newRect, image.CGImage)
        let newImage = UIImage(CGImage: CGBitmapContextCreateImage(context)!)
        UIGraphicsEndImageContext()
        return newImage
    }
    
    static func textToImage(textUserName: NSString,textUserTag: NSString, inImage: UIImage)->UIImage{
        
        // Setup the font specific variables
        let textColor: UIColor = UIColor.whiteColor()
        let textFont: UIFont = UIFont(name: "Helvetica Bold", size: 34)!
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(inImage.size)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = .Right
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: textStyle
        ]
        
        //Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        let mouse = UIImage(named: "whitemask")
        mouse?.drawAtPoint(CGPoint(x: 260, y: 430))
        
        
        // Creating a point within the space that is as bit as the image.
        let rect: CGRect = CGRectMake(264, 436, inImage.size.width-264-8, inImage.size.height)
        
        //Now Draw the text into an image.
        textUserName.drawInRect(rect, withAttributes: textFontAttributes)
        
        
        let rect1: CGRect = CGRectMake(264, 490, inImage.size.width-264-8, inImage.size.height)
        
        //Now Draw the text into an image.
        textUserTag.drawInRect(rect1, withAttributes: textFontAttributes)
        
        
        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
        
    }
    
}