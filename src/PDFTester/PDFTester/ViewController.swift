//
//  ViewController.swift
//  PDFTester
//
//  Created by Carmelo I. Uria on 9/16/15.
//  Copyright © 2015 Carmelo I. Uria. All rights reserved.
//

import UIKit
import CoreGraphics

class ViewController: UIViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
                
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

        
    }
    
    // MARK: - Action methods
    
    @IBAction func handleLeftSwipeAction(sender: AnyObject)
    {
        
    }
    
    @IBAction func handleRightSwipeAction(sender: AnyObject)
    {
        
    }
    
    // MARK: - private methods
    
    private func createPDF()
    {
        let text: CFAttributedStringRef? = CFAttributedStringCreate(nil, "James Bond 007", nil)
        
        if (text != nil)
        {
            let framesetter: CTFramesetter = CTFramesetterCreateWithAttributedString(text!)
            let filename: String = "TestFile"
            
            UIGraphicsBeginPDFContextToFile(filename, CGRectZero, nil)
            
            var currentRange: CFRange = CFRangeMake(0, 0)
            var currentPage: Int = 0
            
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil)
            
            // Draw a page number at the bottom of each page.
            currentPage++

            // Render the current page and update the current range to
            // point to the beginning of the next page.
            
            currentRange = self.renderPage(currentRange, framesetter: framesetter)
            
            UIGraphicsEndPDFContext()
        }
    }
    
    private func openPDF()
    {
        let pdfURL: NSURL? = NSBundle.mainBundle().URLForResource("document", withExtension: "pdf")
        
        let pdf: CGPDFDocument = CGPDFDocumentCreateWithURL(pdfURL)!
        let numberOfPage: size_t = CGPDFDocumentGetNumberOfPages(pdf)

        //	Drawing goes in here...
        debugPrint("\(__FUNCTION__):  number of pages: \(numberOfPage)")
        
        let page: CGPDFPage? = CGPDFDocumentGetPage(pdf, 1)
        
        let rect: CGRect = CGRectMake(0.0, 0.0, 300.0, 300.0)

        UIGraphicsBeginImageContext(self.view.frame.size)
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
            UIGraphicsPushContext(currentContext!)

        }
       
        UIGraphicsEndImageContext()
        
        self.view.setNeedsDisplay()
    }
    
    private func renderPage(var textRange: CFRange, framesetter: CTFramesetterRef) -> CFRange
    {
        // Get the graphics context.
        let currentContext: CGContext = UIGraphicsGetCurrentContext()!
        
        // Put the text matrix into a known state. This ensures
        // that no old scaling factors are left in place.
        CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity)
        
        // Create a path object to enclose the text. Use 72 point
        // margins all around the text.
        let frameRect: CGRect = CGRectMake(72.0, 72.0, 468.0, 648.0)
        let framePath: CGMutablePath = CGPathCreateMutable()
        
        CGPathAddRect(framePath, nil, frameRect)
        
        // Get the frame that will do the rendering.
        // The currentRange variable specifies only the starting point. The framesetter
        // lays out as much text as will fit into the frame.
        let frame: CTFrame = CTFramesetterCreateFrame(framesetter, textRange, framePath, nil)
        
        // Core Text draws from the bottom-left corner up, so flip
        // the current transform prior to drawing.
        CGContextTranslateCTM(currentContext, 0, 792);
        CGContextScaleCTM(currentContext, 1.0, -1.0);
        
        // Draw the frame.
        CTFrameDraw(frame, currentContext)
        
        // Update the current range based on what was drawn.
        textRange = CTFrameGetVisibleStringRange(frame)
        textRange.location += textRange.length
        textRange.length = 0;
        
        
        return textRange;

    }
}

