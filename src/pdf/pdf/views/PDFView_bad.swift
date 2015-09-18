//
//  PDFView.swift
//  pdf
//
//  PDFView.swift
//  PDFTester
//
//  Created by Carmelo I. Uria on 9/17/15.
//  Copyright © 2015 Carmelo I. Uria. All rights reserved.
//

import UIKit

@IBDesignable class PDFView_bad: UIView
{
    
    @IBInspectable var filename: String = ""
    
    private var pdf: CGPDFDocument?
    private var page: CGPDFPage?
    
    private var numberOfPages: size_t = 0
    private var currentPage: size_t = 1
    
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
        
        self.pdf = CGPDFDocumentCreateWithURL(pdfURL)
        self.numberOfPages = CGPDFDocumentGetNumberOfPages(self.pdf!)
        
        //	Drawing goes in here...
        debugPrint("\(__FUNCTION__):  number of pages: \(self.numberOfPages)")
        
        self.page = CGPDFDocumentGetPage(self.pdf, self.currentPage)
        
        let currentContext: CGContext? = UIGraphicsGetCurrentContext()
        
        if (currentContext != nil)
        {
            
            //Set background to white
            CGContextSetRGBFillColor(currentContext!, 255.0, 255.0, 255.0, 1.0)    //1
            CGContextFillRect(currentContext!, rect)
            
            // Flip coordinates
            CGContextGetCTM(currentContext!);
            CGContextScaleCTM(currentContext!, 1, -1)                             //2
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
        
        debugPrint("\(__FUNCTION__):  projectSourceDirectories: \(projectSourceDirectories)")
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if (gestureRecognizer .isKindOfClass(UISwipeGestureRecognizer) == true)
        {
            let swipeGestureRecognizer: UISwipeGestureRecognizer = gestureRecognizer as! UISwipeGestureRecognizer
            
            if (swipeGestureRecognizer.direction == .Left)
            {
                self.currentPage++
                
                if (self.currentPage > self.numberOfPages)
                {
                    self.currentPage = self.numberOfPages
                }
                
                self.page = CGPDFDocumentGetPage(self.pdf, self.currentPage)
                self.setNeedsDisplay()
            }
            else if (swipeGestureRecognizer.direction == .Right)
            {
                self.currentPage--
                
                if (self.currentPage < 1)
                {
                    self.currentPage = 1
                }
                
                self.page = CGPDFDocumentGetPage(self.pdf, self.currentPage)
                self.setNeedsDisplay()
                
            }
        }
        
        return true
    }
}
