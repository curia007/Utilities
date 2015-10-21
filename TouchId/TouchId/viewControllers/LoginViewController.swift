//
//  LoginViewController.swift
//  TouchId
//
//  Created by Carmelo Uria on 10/2/15.
//  Copyright © 2015 Carmelo Uria. All rights reserved.
//

import UIKit

import LocalAuthentication
import Security

public class LoginViewController: UIViewController
{

    private var willCreateKeychain:Bool = false

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // check to see if keychain exists
        var results:String? = self.queryKeychain(nil)
        
        if (results == nil)
        {
            self.willCreateKeychain = true
        }

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


    //MARK: - Private methods
    
    private func verifySettings()
    {
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var isAuthentication:NSNumber? = userDefaults.objectForKey("reset_preference") as? NSNumber
        
        // Maybe a bug somewhere, but the preference switch returns to nil for initial cal
        if (isAuthentication == nil)
        {
            userDefaults.setObject(NSNumber(bool: true), forKey: "reset_preference")
            isAuthentication = userDefaults.objectForKey("reset_preference") as? NSNumber
        }
        
        self.isResetRequested = isAuthentication!.boolValue
    }
    
    private func handleLocalAuthentication()
    {
        var context:LAContext = LAContext()
        
        var message:NSString
        var error:NSError?
        
        var success:Bool
        
        // check keychain with unique identifier
        self.queryKeychain(nil)
        
        // test if we can evaluate the policy, this test will tell us if Touch ID is available and enrolled
        success = context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if (success == true)
        {
            message = NSLocalizedString("TOUCH_ID_IS_AVAILABLE", comment: "Touch Id is available")
            if (self.isResetRequested == true)
            {
                debugPrintln("\(__FUNCTION__):  \(message)")
            }
        }
        else
        {
            message = NSLocalizedString("TOUCH_ID_IS_NOT_AVAILABLE", comment: "Touch Id is not available")
            debugPrintln("\(__FUNCTION__):  \(message)")
        }
        
        // set text for the localized fallback button
        context.localizedFallbackTitle = NSLocalizedString("TOUCH_ID_FALLBACK", comment: "fallback message")
        
        // show the authentication UI with our reason string
        context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: NSLocalizedString("UNLOCK_ACCESS_TO_LOCKED_FAILURE", comment: "Localized reason")) { (isSuccessful, policyError) -> Void in
            
            if (isSuccessful == true)
            {
                message = NSLocalizedString("EVALUATE_POLICY_SUCCESS", comment: "Evaluate policy success")
                success = isSuccessful
                self.isAuthenticated = true
            }
            else
            {
                message = NSLocalizedString("EVALUATE_POLICY_WITH_ERROR", comment: "Evaluate policy with error")
                policyError.localizedDescription
                success = isSuccessful
                
                self.isAuthenticated = true
                
                self.handleLocalAuthenticationWithoutBiometrics()
            }
        }
        
    }
    
    private func handleLocalAuthenticationWithoutBiometrics()
    {
        // reset keychain
        self.resetKeychain()
        
        // do work here
        let userDefaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        let test:NSNumber? = userDefaults.objectForKey("reset_preference") as? NSNumber
        
        let resetNumber:NSNumber = NSNumber(bool: false)
        userDefaults.setObject(resetNumber.boolValue, forKey: "reset_preference")
    }
    
    //MARK: - Keychain private methods
    
    private func createKeychain(user:String!, password:String!)
    {
        
        var identifier: NSData = kKeychainItemIdentifier.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        var passwordData = password.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
        var objects:NSArray = NSArray(objects:kSecClassGenericPassword, kKeychainService, user, identifier, passwordData)
        var keys:NSArray = NSArray(objects:kSecClass, kSecAttrService, kSecAttrAccount, kSecAttrGeneric, kSecValueData)
        let query:NSDictionary = NSDictionary(objects: objects as [AnyObject], forKeys: keys as [AnyObject])
        
        debugPrintln(query)
        
        let status  = SecItemAdd(query as CFDictionaryRef, nil)
        debugPrintln("status:  \(status)")
    }
    
    private func queryKeychain(user:String!) -> String?
    {
        
        var results :Unmanaged<AnyObject>?
        
        var identifier: NSData = kKeychainItemIdentifier.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        var objects:NSMutableArray = NSMutableArray(objects:kSecClassGenericPassword, kKeychainService, identifier, true)
        var keys:NSMutableArray = NSMutableArray(objects:kSecClass,kSecAttrService, kSecAttrGeneric, kSecReturnData)
        
        if (user != nil)
        {
            objects.addObject(user)
            keys.addObject(kSecAttrAccount)
        }
        
        let query = NSDictionary(objects: objects as [AnyObject], forKeys: keys as [AnyObject])
        
        debugPrintln(query)
        
        let status = SecItemCopyMatching(query, &results)
        
        if (status == noErr)
        {
            let data:NSData = results!.takeRetainedValue() as! NSData
            let value:String = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
            debugPrintln("status:  \(status) : data: \(data) : value: \(value)")
            
            return value
        }
        
        return nil
    }
    
    private func deleteKeychain(user:String)
    {
        var identifier: NSData = kKeychainItemIdentifier.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        var objects:NSArray = NSArray(objects:kSecClassGenericPassword, kKeychainService, user, identifier)
        var keys:NSArray = NSArray(objects:kSecClass,kSecAttrService, kSecAttrAccount,kSecValueData)
        let query:NSDictionary = NSDictionary(objects: objects as [AnyObject], forKeys: keys as [AnyObject])
        
        debugPrintln(query)
        
        let status = SecItemDelete(query)
        debugPrintln("status:  \(status)")
        
    }
    
    private func resetKeychain()
    {
        var identifier: NSData = kKeychainItemIdentifier.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        var objects:NSArray = NSArray(objects:kSecClassGenericPassword, kKeychainService, identifier)
        var keys:NSArray = NSArray(objects:kSecClass,kSecAttrService,kSecValueData)
        let query:NSDictionary = NSDictionary(objects: objects as [AnyObject], forKeys: keys as [AnyObject])
        
        debugPrintln(query)
        
        let status = SecItemDelete(query)
        debugPrintln("status:  \(status)")
        
    }

}
