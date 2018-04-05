//
//  UserData.swift
//  Weenk
//
//  Created by Abdulelah Alshalhoub on 14/02/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

// user class
class UserData {
    
    var email: String!
    var name: String!
    var photoURL: String!
    var id: String!
    var fChatId: String! = ""
    var fIsTracked: Bool! = false
    var fIsTrackRequested: Bool! = false
    var gIsChild: Bool! = false
    var gIsGhostActive: Bool! = false
    var sIsFriend: Bool! = false
    var sIsFriendRequested: Bool! = false
    var gsIsInThisGroup: Bool! = false
    var gsIsInThisGroupRequested: Bool! = false
    var reqSentTime: String!
    
    init(userEmail: String, userName: String, userPhotoURL: String, userID: String) {
        self.email = userEmail
        self.name = userName
        self.photoURL = userPhotoURL
        self.id = userID

    }
    
}
// position class
class PositionData {
    
    var latitude: String!
    var longitude: String!
    var altitude: String!
    var lastUpdatedDate: String!
    
    init(latitude: String, longitude: String, altitude: String, date: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.lastUpdatedDate = date
    }
    
}

// group class
class GroupData {
    
    var groupName: String!
    var id: String!
    var adminId: String!
    var chatId: String!
    var amIChild: Bool!
    var reqSentTime: String!
    //var groupdMembersList = [UserData]()
    
    
    init(groupName: String, id: String, adminId: String, chatId: String) {
        self.groupName = groupName
        self.id = id
        self.adminId = adminId
        self.chatId = chatId
    }
    
}

// chat class
// TODO most likely wont need the class maybe remove later
class ChatData {
    
    var name: String!
    var id: String!
    
    init(name: String, id: String) {
        self.name = name
        self.id = id
    }
    
}

// message class
class MessageData {
    
    var sender: String!
    var senderID: String!
    var id: String!
    var message: String!
    var date: String!
    
    
    init(sender: String, senderID: String, id: String, message: String, date: String) {
        self.sender = sender
        self.senderID = senderID
        self.id = id
        self.message = message
        self.date = date
    }
    
}
