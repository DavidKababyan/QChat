//
//  RegisterUser.swift
//  quickChat
//
//  Created by David Kababyan on 14/03/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import Foundation

func registerUserDeviceId() {
    
    if (backendless.messagingService.getRegistration().deviceId != nil) {
        
        let deviceId = backendless.messagingService.getRegistration().deviceId
        
        let properties = ["deviceId" : deviceId]
        
        backendless.userService.currentUser!.updateProperties(properties)
        backendless.userService.update(backendless.userService.currentUser)
    }
    
}

func updateBackendlessUser(facebookId: String, avatarUrl: String) {
   
    var properties: [String: String]!
    
    if backendless.messagingService.getRegistration().deviceId != nil {
        let deviceId = backendless.messagingService.getRegistration().deviceId
        
        properties = ["Avatar" : avatarUrl, "deviceId" : deviceId]
    } else {
        properties = ["Avatar" : avatarUrl]
    }

    
    backendless.userService.currentUser.updateProperties(properties)
    
    backendless.userService.update(backendless.userService.currentUser, response: { (updatedUser : BackendlessUser!) -> Void in
        
        print("updated user is : \(updatedUser)")
        
        }) { (fault : Fault!) -> Void in
            print("Error couldnt update the devices id: \(fault)")
    }
   
}


func removeDeviceIdFromUser() {
    
    let properties = ["deviceId" : ""]
    
    backendless.userService.currentUser!.updateProperties(properties)
    backendless.userService.update(backendless.userService.currentUser)
    
    
}