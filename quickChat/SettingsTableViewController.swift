//
//  SettingsTableViewController.swift
//  quickChat
//
//  Created by David Kababyan on 12/03/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class SettingsTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet weak var HeaderView: UIView!
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    
    @IBOutlet weak var avatarSwitch: UISwitch!
    @IBOutlet weak var avatarCell: UITableViewCell!
    @IBOutlet weak var termsCell: UITableViewCell!
    @IBOutlet weak var privacyCell: UITableViewCell!
    @IBOutlet weak var logOutCell: UITableViewCell!
    
    var avatarSwitchStatus = true
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var firstLoad: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableHeaderView = HeaderView
        
        imageUser.layer.cornerRadius = imageUser.frame.size.width / 2
        imageUser.layer.masksToBounds = true
        
        loadUserDefaults()
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBActions
    
    @IBAction func didClickAvatarImage(sender: AnyObject) {
        changePhoto()
    }
    
    @IBAction func avatarSwitchValueChaged(switchState: UISwitch) {
        if switchState.on {
            avatarSwitchStatus = true
        } else {
            avatarSwitchStatus = false
            print("it off")
        }
        saveUserDefaults()
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 3 }
        if section == 1 { return 1 }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if ((indexPath.section == 0) && (indexPath.row == 0)) { return privacyCell }
        if ((indexPath.section == 0) && (indexPath.row == 1)) { return termsCell   }
        if ((indexPath.section == 0) && (indexPath.row == 2)) { return avatarCell  }
        if ((indexPath.section == 1) && (indexPath.row == 0)) { return logOutCell  }

        return UITableViewCell()
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        } else {
            return 25.0
        }
        
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        
        return headerView
    }
    
    //MARK: Tableview delegate functions
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 1 && indexPath.row == 0 {
            showLogutView()
        }
        
    }
    
    //MARK:  Change photo
    
    func changePhoto() {
        
        let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (alert: UIAlertAction!) -> Void in
            camera.PresentPhotoCamera(self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .Default) { (alert: UIAlertAction!) -> Void in
            camera.PresentPhotoLibrary(self, canEdit: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) -> Void in
            print("Cancel")
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    //MARK: UIImagePickerControllerDelegate functions
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        
        imageUser.image = image
        
        uploadAvatar(image) { (imageLink) -> Void in
            
            let properties = ["Avatar" : imageLink!]
            
            backendless.userService.currentUser!.updateProperties(properties)
            
            backendless.userService.update(backendless.userService.currentUser, response: { (updatedUser: BackendlessUser!) -> Void in

                }, error: { (fault : Fault!) -> Void in
                    print("error: \(fault)")
            })
            
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK:  UpdateUI
    func updateUI() {
        
        userNameLabel.text = backendless.userService.currentUser.name
        
        avatarSwitch.setOn(avatarSwitchStatus, animated: false)
        

        if let imageLink = backendless.userService.currentUser.getProperty("Avatar") {
            getImageFromURL(imageLink as! String, result: { (image) -> Void in

                self.imageUser.image = image
            })
        }
    }
    
    //MARK: Helper functions
    
    func showLogutView() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let logoutAction = UIAlertAction(title: "Log Out", style: .Destructive) { (alert: UIAlertAction!) -> Void in
            //logout user
            self.logOut()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert: UIAlertAction!) -> Void in
            print("cancelled")
        }
        
        
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func logOut() {
        
        removeDeviceIdFromUser()
        
        backendless.userService.logout()
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
        }
        
        PushUserResign()

        let loginView = storyboard!.instantiateViewControllerWithIdentifier("LoginView")
        self.presentViewController(loginView, animated: true, completion: nil)
    }
    
    //MARK: UserDefaults
    
    func saveUserDefaults() {
        userDefaults.setBool(avatarSwitchStatus, forKey: kAVATARSTATE)
        userDefaults.synchronize()
    }
    
    func loadUserDefaults() {
        firstLoad = userDefaults.boolForKey(kFIRSTRUN)

        if !firstLoad! {
            
            userDefaults.setBool(true, forKey: kFIRSTRUN)
            userDefaults.setBool(avatarSwitchStatus, forKey: kAVATARSTATE)
            userDefaults.synchronize()
        }
        
        avatarSwitchStatus = userDefaults.boolForKey(kAVATARSTATE)
    }
    

}
