//
//  WelcomeViewController.swift
//  quickChat
//
//  Created by David Kababyan on 28/02/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        backendless.userService.setStayLoggedIn(true)
        
        
        if backendless.userService.currentUser != nil {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatVC") as! UITabBarController
                vc.selectedIndex = 0
                
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fbLoginButton.readPermissions = ["public_profile", "email"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
