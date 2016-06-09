//
//  PushNotifications.swift
//  quickChat
//
//  Created by David Kababyan on 20/03/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import Foundation

func SendPushNotification(chatRoomID: String, message: String) {
    
    firebase.child("Recent").queryOrderedByChild("chatRoomID").queryEqualToValue(chatRoomID).observeSingleEventOfType(.Value, withBlock: {
        snapshot in
        
        if snapshot.exists() {
            let recents = snapshot.value!.allValues
            
            if let recent = recents.first {
                SendPush((recent["members"] as? [String])!, message: message)
            }
        }
    })
}


func SendPush(members:[String], message: String) {
    
    let withUserId = withUserIdFromArray(members)!
    
    let whereClause = "objectId = '\(withUserId)'"
    let queryData = BackendlessDataQuery()
    queryData.whereClause = whereClause
    
    let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
    
    dataStore.find(queryData, response: { (users) -> Void in
        
        let withUser = users.data.first as! BackendlessUser
        
        SendPushMessage(withUser, message: message)
        
        }) { (fault : Fault!) -> Void in
            print("error, couldnt get user from users table")
    }
    
}

func SendPushMessage(toUser: BackendlessUser, message: String) {
    
    let deviceId = toUser.getProperty("deviceId") as! String
    
    let deliveryOptions = DeliveryOptions()
    deliveryOptions.pushSinglecast = [deviceId]
    deliveryOptions.pushPolicy(PUSH_ONLY)
    
    let publishOptions = PublishOptions()
    publishOptions.assignHeaders(["ios-alert" : "\(backendless.userService.currentUser.name) \n \(message)", "ios-badge" : "1", "ios-sound" : "defauld"])
    
    backendless.messagingService.publish("default", message: message, publishOptions: publishOptions, deliveryOptions: deliveryOptions)
}

func PushUserResign() {
    
    backendless.messagingService.unregisterDeviceAsync({ (result) -> Void in
        
        print("unregistered device")
        }) { (fault: Fault!) -> Void in
            print("error couldnt unregister device :\(fault)")
    }
}


func withUserIdFromArray(users: [String]) -> String? {
    
    var id: String?
    
    for userId in users {
        if userId != backendless.userService.currentUser.objectId {
            id = userId
        }
    }
    return id
}


