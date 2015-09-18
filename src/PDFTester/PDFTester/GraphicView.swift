//
//  GraphicView.swift
//  PDFTester
//
//  Created by Carmelo I. Uria on 9/16/15.
//  Copyright © 2015 Carmelo I. Uria. All rights reserved.
//

import UIKit

class GraphicView: UIView
{

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()
        let myShadowOffset = CGSizeMake (-10,  15)
        
        CGContextSaveGState(context)
        
        CGContextSetShadow (context, myShadowOffset, 5)
        
        CGContextSetLineWidth(context, 4.0)
        CGContextSetStrokeColorWithColor(context,
            UIColor.blueColor().CGColor)
        
        let rectangle = CGRectMake(60,170,200,80)
        CGContextAddEllipseInRect(context, rectangle)
        CGContextStrokePath(context)
        
        CGContextRestoreGState(context)
    }
    

}
