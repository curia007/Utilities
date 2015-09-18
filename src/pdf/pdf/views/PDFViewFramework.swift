//
//  PDFView.swift
//  pdf
//
//  Created by Carmelo I. Uria on 9/18/15.
//  Copyright © 2015 Carmelo I. Uria. All rights reserved.
//

import UIKit

@IBDesignable class PDFViewFramework: UIView
{

    @IBInspectable var filename: String = ""
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect)
    {
        if (self.filename == "")
        {
            return
        }
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let pdfURL: NSURL? = bundle.URLForResource(self.filename, withExtension: "pdf")
        
        if (pdfURL == nil)
        {
            return
        }
        
        let pdf: CGPDFDocument = CGPDFDocumentCreateWithURL(pdfURL)!
        let numberOfPage: size_t = CGPDFDocumentGetNumberOfPages(pdf)
        
        //	Drawing goes in here...
        debugPrint("\(__FUNCTION__):  number of pages: \(numberOfPage)")
        
        let page: CGPDFPage? = CGPDFDocumentGetPage(pdf, 1)
        
        //UIGraphicsBeginImageContext(rect.size)
        let currentContext: CGContext? = UIGraphicsGetCurrentContext()
        
        if (currentContext != nil)
        {
            
            //Set background to white
            CGContextSetRGBFillColor(currentContext!, 255.0, 255.0, 255.0, 1.0)
            CGContextFillRect(currentContext!, rect)
            
            // Flip coordinates
            CGContextGetCTM(currentContext!);
            CGContextScaleCTM(currentContext!, 1, -1)
            CGContextTranslateCTM(currentContext!, 0, -rect.size.height)
            
            // get cropbox
            let cropRect: CGRect = CGPDFPageGetBoxRect(page, CGPDFBox.CropBox)
            
            //scale to fit the entire page,
            CGContextScaleCTM(currentContext!, rect.size.width / cropRect.size.width,rect.size.height / cropRect.size.height)
            CGContextTranslateCTM(currentContext!, -cropRect.origin.x, -cropRect.origin.y)
            
            // draw PDF
            CGContextDrawPDFPage(currentContext!, page)
            
        }
    }

    override func prepareForInterfaceBuilder()
    {
        let processInfo: NSProcessInfo = NSProcessInfo.processInfo()
        let environment: [String : String] = processInfo.environment
        let projectSourceDirectories: String = environment["IB_PROJECT_SOURCE_DIRECTORIES"]!
        
    }

}
