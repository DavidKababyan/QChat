//
//  OutgoingMessage.swift
//  quickChat
//
//  Created by David Kababyan on 07/03/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import Foundation

class OutgoingMessage {
    
    //change
    //private let firebase = Firebase(url: "https://quickchataplication.firebaseio.com/Message")
    private let ref = firebase.child("Message")
    
    let messageDictionary: NSMutableDictionary
    
    init (message: String, senderId: String, senderName: String, date: NSDate, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().stringFromDate(date), status, type], forKeys: ["message", "senderId", "senderName", "date", "status", "type"])
    }
    
    init(message: String, latitude: NSNumber, longitude: NSNumber, senderId: String, senderName: String, date: NSDate, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, latitude, longitude, senderId, senderName, dateFormatter().stringFromDate(date), status, type], forKeys: ["message", "latitude", "longitude", "senderId", "senderName", "date", "status", "type"])
    }
    
    init (message: String, pictureData: NSData, senderId: String, senderName: String, date: NSDate, status: String, type: String) {
        
        let pic = pictureData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
        
        
        messageDictionary = NSMutableDictionary(objects: [message, pic, senderId, senderName, dateFormatter().stringFromDate(date), status, type], forKeys: ["message", "picture", "senderId", "senderName", "date", "status", "type"])
    }
    
    func sendMessage(chatRoomID: String, item: NSMutableDictionary) {
        
        let reference = ref.child(chatRoomID).childByAutoId()
        
        item["messageId"] = reference.key
        
        reference.setValue(item) { (error, ref) -> Void in
            if error != nil {
                print("Error, couldnt send message")
            }
        }
        
        SendPushNotification(chatRoomID, message: (item["message"] as? String)!)
        UpdateRecents(chatRoomID, lastMessage: (item["message"] as? String)!)
    }

    
    
}