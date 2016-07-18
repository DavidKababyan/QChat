//
//  IncomingMessage.swift
//  quickChat
//
//  Created by David Kababyan on 09/03/2016.
//  Copyright © 2016 David Kababyan. All rights reserved.
//

import Foundation


class IncomingMessage {
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    func createMessage(dictionary: NSDictionary) -> JSQMessage? {
        
        var message: JSQMessage?
        
        let type = dictionary["type"] as? String
        
        
        if type == "text" {
            //create text message
            message = createTextMessage(dictionary)
        }
        if type == "location" {
            //create loacation message
            message = createLocationMessage(dictionary)
        }
        if type == "picture" {
            //create picture message
            message = createPictureMessage(dictionary)
        }
        
        if let mes = message {
            return mes
        }
        
        return nil
    }
    
    func createTextMessage(item: NSDictionary) -> JSQMessage {
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        
        let date = dateFormatter().dateFromString((item["date"] as? String)!)
        let text = item["message"] as? String
        
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
    }
    

    func createLocationMessage(item : NSDictionary) -> JSQMessage {
        
        print("item : \(item)")
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        
        let date = dateFormatter().dateFromString((item["date"] as? String)!)

        let latitude = item["latitude"] as? Double
        let longitude = item["longitude"] as? Double
        
        let mediaItem = JSQLocationMediaItem(location: nil)
        mediaItem.appliesMediaViewMaskAsOutgoing = returneOutgoingStatusFromUser(userId!)
        
        let location = CLLocation(latitude: latitude!, longitude: longitude!)
        
        mediaItem.setLocation(location) { () -> Void in
            // update our collectionView
            self.collectionView.reloadData()
        }
        
        
        return JSQMessage(senderId: userId!, senderDisplayName: name!, date: date, media: mediaItem)
    }
    
    func returneOutgoingStatusFromUser(senderId: String) -> Bool {
        
        if senderId == backendless.userService.currentUser.objectId {
            //outgoing
            return true
        } else {
            return false
        }
    }
    
    func createPictureMessage(item: NSDictionary) -> JSQMessage {
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        
        let date = dateFormatter().dateFromString((item["date"] as? String)!)

        let mediaItem = JSQPhotoMediaItem(image: nil)
        mediaItem.appliesMediaViewMaskAsOutgoing = returneOutgoingStatusFromUser(userId!)
        
        imageFromData(item) { (image: UIImage?) -> Void in
            mediaItem.image = image
            self.collectionView.reloadData()
        }
        
        return JSQMessage(senderId: userId!, senderDisplayName: name!, date: date, media: mediaItem)
    }
    
    func imageFromData(item: NSDictionary, result : (image: UIImage?) ->Void) {
        
        var image: UIImage?
        
        let decodedData = NSData(base64EncodedString: (item["picture"] as? String)!, options: NSDataBase64DecodingOptions(rawValue: 0))
        
        image = UIImage(data: decodedData!)
        
        result(image: image)
    }
    
    
    
    
    
}