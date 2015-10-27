//
//  ModelProcessorException.swift
//  Utilities
//
//  Created by Carmelo I. Uria on 10/20/15.
//  Copyright © 2015 Carmelo I. Uria. All rights reserved.
//

public class ModelProcessorException: NSException
{
    override init(name aName: String, reason aReason: String?, userInfo aUserInfo: [NSObject : AnyObject]?)
    {
        super.init(name: aName, reason: aReason, userInfo: aUserInfo)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
