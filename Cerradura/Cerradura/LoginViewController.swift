//
//  LoginViewController.swift
//  Cerradura
//
//  Created by Alsey Coleman Miller on 6/3/15.
//  Copyright (c) 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var serverURLTextField: UITextField!
    
    // MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK: - Actions
    
    @IBAction func login(sender: AnyObject) {
        
        let serverURL = NSURL(string: self.serverURLTextField.text)
        
        AuthenticationController.sharedController.login(self.usernameTextField.text.lowercaseString, password: self.passwordTextField.text, server: serverURL!, completion: { (error: NSError?) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                
                if error != nil {
                    
                    let errorText = NSLocalizedString("Invalid username or password.", value: "Invalid username or password.", comment: "Invalid username or password.")
                    
                    self.showErrorAlert(errorText, retryHandler: { () -> Void in
                        
                        self.login(self)
                    })
                    
                    return
                }
                
                // present split VC
                
                self.performSegueWithIdentifier(R.segue.loginSegue, sender: self)
            })
        })
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
    }
    
    @IBAction func logoutSegue(segue: UIStoryboardSegue) {
        
        
    }
}

