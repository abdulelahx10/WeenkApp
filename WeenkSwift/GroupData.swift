//
//  GroupData.swift
//  Weenk
//
//  Created by Abdulelah Alshalhoub on 14/02/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

class GroupData {
    
    var groupName: String!
    var id: String!
    var adminId: String!
    var groupdMembersList = [UserData]()

    
    init(groupName: String, id: String, adminId: String) {
        self.groupName = groupName
        self.id = id
        self.adminId = adminId
    }
    
}

