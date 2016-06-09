//
//  Recent.swift
//  quickChat
//
//  Created by David Kababyan on 06/03/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import Foundation
import FirebaseDatabase

//------Constants--------\\
public let kAVATARSTATE = "avatarState"
public let kFIRSTRUN = "firstRun"
//--------\\



//let firebase = Firebase(url: "https://quickchataplication.firebaseio.com/")
var firebase = FIRDatabase.database().reference()
let backendless = Backendless.sharedInstance()


//MARK: Create Chatroom

func startChat(user1: BackendlessUser, user2: BackendlessUser) -> String {

    //user 1 is current user
    let userId1: String = user1.objectId
    let userId2: String = user2.objectId
    
    var chatRoomId: String = ""
    
    let value = userId1.compare(userId2).rawValue
    
    if value < 0 {
        chatRoomId = userId1.stringByAppendingString(userId2)
    } else {
        chatRoomId = userId2.stringByAppendingString(userId1)
    }
    
    let members = [userId1, userId2]
    
    //create recent
    CreateRecent(userId1, chatRoomID: chatRoomId, members: members, withUserUsername: user2.name!, withUseruserId: userId2)
    CreateRecent(userId2, chatRoomID: chatRoomId, members: members, withUserUsername: user1.name!, withUseruserId: userId1)
    
    return chatRoomId
}

//MARK: Create RecentItem

func CreateRecent(userId: String, chatRoomID: String, members: [String], withUserUsername: String, withUseruserId: String) {
    
    //change
    firebase.child("Recent").queryOrderedByChild("chatRoomID").queryEqualToValue(chatRoomID).observeSingleEventOfType(.Value, withBlock:{
        snapshot in
        
        var createRecent = true
        
        //check if we have a result
        if snapshot.exists() {
            for recent in snapshot.value!.allValues {
                
                //if we already have recent with passed userId, we dont create a new one
                if recent["userId"] as! String == userId {
                    createRecent = false
                }
            }
        }
        
        if createRecent {
            
            CreateRecentItem(userId, chatRoomID: chatRoomID, members: members, withUserUsername: withUserUsername, withUserUserId: withUseruserId)
        }
    })
}


func CreateRecentItem(userId: String, chatRoomID: String, members: [String], withUserUsername: String, withUserUserId: String) {
    
    let ref = firebase.child("Recent").childByAutoId()
    
    let recentId = ref.key
    let date = dateFormatter().stringFromDate(NSDate())
    
    let recent = ["recentId" : recentId, "userId" : userId, "chatRoomID" : chatRoomID, "members" : members, "withUserUsername" : withUserUsername, "lastMessage" : "", "counter" : 0, "date" : date, "withUserUserId" : withUserUserId]
    
    //save to firebase
    ref.setValue(recent) { (error, ref) -> Void in
        if error != nil {
            print("error creating recent \(error)")
        }
    }
}

//MARK: Update Recent

func UpdateRecents(chatRoomID: String, lastMessage: String) {
    
    firebase.child("Recent").queryOrderedByChild("chatRoomID").queryEqualToValue(chatRoomID).observeSingleEventOfType(.Value, withBlock: {
        snapshot in
        
        if snapshot.exists() {
            
            for recent in snapshot.value!.allValues {
                UpdateRecentItem(recent as! NSDictionary, lastMessage: lastMessage)
            }
        }
    })
}

func UpdateRecentItem(recent: NSDictionary, lastMessage: String) {
    let date = dateFormatter().stringFromDate(NSDate())
    
    var counter = recent["counter"] as! Int
    
    if recent["userId"] as? String != backendless.userService.currentUser.objectId {        counter += 1
    }
    
    let values = ["lastMessage" : lastMessage, "counter" : counter, "date" : date]
    
    //change
    firebase.child("Recent").child((recent["recentId"] as? String)!).updateChildValues(values as [NSObject : AnyObject], withCompletionBlock: {
        (error, ref) -> Void in
        
        if error != nil {
            print("Error couldnt update recent item")
        }
    })
}

//MARK: Restart Recent Chat

func RestartRecentChat(recent: NSDictionary) {
    
    for userId in recent["members"] as! [String] {
        
        if userId != backendless.userService.currentUser.objectId {
            
            CreateRecent(userId, chatRoomID: (recent["chatRoomID"] as? String)!, members: recent["members"] as! [String], withUserUsername: backendless.userService.currentUser.name, withUseruserId: backendless.userService.currentUser.objectId)
        }
    }
}


//MARK: Delete Recent functions

func DeleteRecentItem(recent: NSDictionary) {
    firebase.child("Recent").child((recent["recentId"] as? String)!).removeValueWithCompletionBlock { (error, ref) -> Void in
        if error != nil {
            print("Error deleting recent item: \(error)")
        }
    }
}

//MARK: Clear recent counter function

func ClearRecentCounter(chatRoomID: String) {
    firebase.child("Recent").queryOrderedByChild("chatRoomID").queryEqualToValue(chatRoomID).observeSingleEventOfType(.Value, withBlock: {
        snapshot in
      
        if snapshot.exists() {
            for recent in snapshot.value!.allValues {
                if recent.objectForKey("userId") as? String == backendless.userService.currentUser.objectId {
                    ClearRecentCounterItem(recent as! NSDictionary)
                }
            }
        }
    })
}

func ClearRecentCounterItem(recent: NSDictionary) {
    
    firebase.child("Recent").child((recent["recentId"] as? String)!).updateChildValues(["counter" : 0]) { (error, ref) -> Void in
        if error != nil {
            print("Error couldnt update recents counter: \(error!.localizedDescription)")
        }
    }
}


//MARK: Helper functions

private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> NSDateFormatter {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = dateFormat
    
    return dateFormatter
}