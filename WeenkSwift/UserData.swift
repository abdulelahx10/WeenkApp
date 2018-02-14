//
//  UserData.swift
//  Weenk
//
//  Created by Abdulelah Alshalhoub on 14/02/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

class UserData {
    
    var email: String!
    var name: String!
    var photoURL: String!
    var id: String!
    
    init(userEmail: String, userName: String, userPhotoURL: String, userID: String) {
        self.email = userEmail
        self.name = userName
        self.photoURL = userPhotoURL
        self.id = userID
    }
    
}
