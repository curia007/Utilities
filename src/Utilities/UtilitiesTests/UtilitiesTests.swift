//
//  UtilitiesTests.swift
//  UtilitiesTests
//
//  Created by Carmelo I. Uria on 10/20/15.
//  Copyright © 2015 Carmelo I. Uria. All rights reserved.
//

import XCTest
@testable import Utilities

class UtilitiesTests: XCTestCase
{
    
    override func setUp()
    {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let modelProcessor: ModelProcessor = ModelProcessor()
        
        do
        {
           try modelProcessor.test()
        }
        catch
        {
            
        }
        
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample()
    {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample()
    {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
