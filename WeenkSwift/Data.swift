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
    var chatId : String!
    
    init(userEmail: String, userName: String, userPhotoURL: String, userID: String, chatID: String) {
        self.email = userEmail
        self.name = userName
        self.photoURL = userPhotoURL
        self.id = userID
        self.chatId = chatID
    }
    
}

// group class
class GroupData {
    
    var groupName: String!
    var id: String!
    var adminId: String!
    var chatId: String!
    var groupdMembersList = [UserData]()
    
    
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
    var id: String!
    var message: String!
    var date: String!
    
    
    init(sender: String, id: String, message: String, date: String) {
        self.sender = sender
        self.id = id
        self.message = message
        self.date = date
    }
    
}
