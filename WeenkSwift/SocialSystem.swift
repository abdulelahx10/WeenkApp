//
//  FriendsViewController.swift
//  Weenk
//
//  Created by Abdulelah Alshalhoub on 14/02/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import Firebase
import FirebaseAuth

class SocialSystem {
    
    static let system = SocialSystem()
    
    // MARK: - Firebase references
    /** The base Firebase reference */
    let BASE_REF = Database.database().reference()
    /* The user Firebase reference */
    let USERS_REF = Database.database().reference().child("users")
    /* The group Firebase reference */
    let GROUPS_REF = Database.database().reference().child("groups")
    /* The chat Firebase reference */
    let CHATS_REF = Database.database().reference().child("chats")
    /* To ensure that execution order is correct */
    let group = DispatchGroup()
    /** The Firebase reference to the current user tree */
    var CURRENT_USER_REF: DatabaseReference {
        let id = Auth.auth().currentUser!.uid
        return USERS_REF.child("\(id)")
    }
    
    /** The Firebase reference to the current user's friend tree */
    var CURRENT_USER_FRIENDS_REF: DatabaseReference {
        return CURRENT_USER_REF.child("friends")
    }
    
    /** The Firebase reference to the current user's group tree */
    var CURRENT_USER_GROUPS_REF: DatabaseReference {
        return CURRENT_USER_REF.child("groups")
    }
    
    /** The Firebase reference to the current user's accepted tracking tree */
    var CURRENT_USER_ACCEPTED_REF: DatabaseReference {
        return CURRENT_USER_REF.child("acceptedTracking")
    }
    
    /** The Firebase reference to the current user's friend request tree */
    var CURRENT_USER_FRIEND_REQUESTS_REF: DatabaseReference {
        return CURRENT_USER_REF.child("friendRequests")
    }
    
    /** The Firebase reference to the current user's friend request tree */
    var CURRENT_USER_GROUP_REQUESTS_REF: DatabaseReference {
        return CURRENT_USER_REF.child("groupRequests")
    }
    
    /** The current user's id */
    var CURRENT_USER_ID: String {
        let id = Auth.auth().currentUser!.uid
        return id
    }
    
    
    /** Gets the current User object for the specified user id */
    func getCurrentUserData(_ completion: @escaping (UserData) -> Void) {
        CURRENT_USER_REF.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let email = snapshot.childSnapshot(forPath: "email").value as! String
            let name = snapshot.childSnapshot(forPath: "userName").value as! String
            let photoURL = snapshot.childSnapshot(forPath: "photoURL").value as! String
            let id = snapshot.key
            completion(UserData(userEmail: email, userName: name, userPhotoURL: photoURL, userID: id))
        })
    }
    /** Gets the User object for the specified user id */
    func getUser(_ userID: String, completion: @escaping (UserData) -> Void) {
        USERS_REF.child(userID).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let email = snapshot.childSnapshot(forPath: "email").value as! String
            let name = snapshot.childSnapshot(forPath: "userName").value as! String
            let photoURL = snapshot.childSnapshot(forPath: "photoURL").value as! String
            let id = snapshot.key
            completion(UserData(userEmail: email, userName: name, userPhotoURL: photoURL, userID: id))
            
        })
    }
    /** Gets the group object for the specified group id */
    func getGroup(_ groupID: String, completion: @escaping (GroupData) -> Void) {
        GROUPS_REF.child(groupID).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let adminId = snapshot.childSnapshot(forPath: "admin").value as! String
            let name = snapshot.childSnapshot(forPath: "groupName").value as! String
            let chatId = snapshot.childSnapshot(forPath: "chatId").value as! String
            let id = snapshot.key
            completion(GroupData(groupName: name, id: id, adminId: adminId, chatId: chatId))
            
        })
    }
    /** Gets the chat object for the specified chat id */
    func getChat(_ chatID: String, completion: @escaping (ChatData) -> Void) {
        CHATS_REF.child(chatID).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let name = snapshot.childSnapshot(forPath: "name").value as! String
            let id = snapshot.key
            completion(ChatData(name: name, id: id))
            
        })
    }
    /** Gets the message object for the specified message id */
    func getMessage(_ chatID: String, _ messageID: String, completion: @escaping (MessageData) -> Void) {
        CHATS_REF.child(chatID).child(messageID).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let sender = snapshot.childSnapshot(forPath: "sender").value as! String
            let message = snapshot.childSnapshot(forPath: "message").value as! String
            let date = snapshot.childSnapshot(forPath: "date").value as! String
            let id = snapshot.key
            completion(MessageData(sender: sender, id: id, message: message, date: date))
            
        })
    }
    
    // MARK: - System Functions
    
    /** Create a Group and make current user the admin */
    func createGroup(WithGroupName groupName: String) {
        let ref = GROUPS_REF.childByAutoId()
        ref.child("groupName").setValue(groupName)
        ref.child("admin").setValue(CURRENT_USER_ID)
        ref.child("chatId").setValue(ref.key)
        CURRENT_USER_GROUPS_REF.child(ref.key).setValue(true)
        CHATS_REF.child(ref.key)
    }
    
    /** Sends a friend request to the user with the specified id */
    func sendFriendRequest(ToUserID userID: String) {
        let ref = USERS_REF.child(userID).child("friendRequests").child(CURRENT_USER_ID)
        // get the current date and time
        let currentDateTime = Date()
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        
        // get the date time String from the date object
        let date = formatter.string(from: currentDateTime)
        ref.child("sentTime").setValue(date)
    }
    
    /** Sends a group request with given groupID to the user with the specified id */
    func sendGroupRequest(ToUserID groupID: String, userID: String, isChild: Bool) {
        let ref = USERS_REF.child(userID).child("groupRequests").child(groupID)
        // get the current date and time
        let currentDateTime = Date()
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        
        // get the date time String from the date object
        let date = formatter.string(from: currentDateTime)
        ref.child("sentTime").setValue(date)
        
        ref.child("isChild").setValue(isChild)
    }
    
    /** Accepts a friend request from the user with the specified id */
    func acceptFriendRequest(FromUserID userID: String) {
        let chatId = CHATS_REF.childByAutoId().key
        CURRENT_USER_REF.child("friendRequests").child(userID).removeValue()
        CURRENT_USER_REF.child("friends").child(userID).setValue(chatId)
        USERS_REF.child(userID).child("friends").child(CURRENT_USER_ID).setValue(chatId)
        USERS_REF.child(userID).child("friendRequests").child(CURRENT_USER_ID).removeValue()
    }
    
    /** Accepts a group request with given id*/
    func acceptGroupRequest(FromGroupID groupID: String) {
        let isChild = CURRENT_USER_REF.child("groupRequests").child(groupID).value(forKey: "isChild") as! Bool
        CURRENT_USER_REF.child("groupRequests").child(groupID).removeValue()
        CURRENT_USER_REF.child("groups").child(groupID).setValue(true)
        GROUPS_REF.child(groupID).child("members").child(CURRENT_USER_ID).child("isChild").setValue(isChild)
        GROUPS_REF.child(groupID).child("members").child(CURRENT_USER_ID).child("isGhostActive").setValue(false)
    }
    
    /** Unfriends the user with the specified id */
    func removeFriend(WithUserID userID: String) {
        CURRENT_USER_REF.child("friends").child(userID).removeValue()
        USERS_REF.child(userID).child("friends").child(CURRENT_USER_ID).removeValue()
    }
    
    /** remove the user with the specified id from the group with specified id */
    func removeUserFromGroup(WithUserID userID: String, FromGroupID groupID: String) {
        GROUPS_REF.child(groupID).child("members").child(groupID).removeValue()
        USERS_REF.child(userID).child("groups").child(groupID).removeValue()
    }
    
    /** Change Ghost mode state in the group  with given id to true or false */
    func changeGhostModeState(InGroupID groupID: String,GhostMode ghostMode: Bool) {
        GROUPS_REF.child(groupID).child("members").child(CURRENT_USER_ID).child("isGhostActive").setValue(ghostMode)
    }
    
    /** send message to the given chat ID */
    func sendMessage(ToChatID chatID: String, WithTheMessage message: String) {
        let ref = CHATS_REF.child(chatID).childByAutoId()
        ref.child("message").setValue(message)
        let name = CURRENT_USER_REF.value(forKey: "userName") as! String
        ref.child("sender").setValue(name)// TODO maybe change to sender ID insted of name
        // get the current date and time
        let currentDateTime = Date()
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        
        // get the date time String from the date object
        let date = formatter.string(from: currentDateTime)
        ref.child("date").setValue(date)
    }
    
    // TODO: change to other format
    /** send tracking request to the given chat ID */
    func sendTrackRequest(ToUserID userID: String) {
        let ref = USERS_REF.child(userID).child("trackRequests").child(CURRENT_USER_ID)
        // get the current date and time
        let currentDateTime = Date()
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        
        // get the date time String from the date object
        let date = formatter.string(from: currentDateTime)
        ref.child("sentTime").setValue(date)
    }
    
    // TODO: change to include timer
    /** Accepts a track request from the user with the specified id */
    func acceptTrackRequest(FromUserID userID: String) {
        CURRENT_USER_REF.child("trackRequests").child(userID).removeValue()
        CURRENT_USER_REF.child("acceptedTracking").child(userID).setValue(true)
        USERS_REF.child(userID).child("acceptedTracking").child(CURRENT_USER_ID).setValue(true)
        USERS_REF.child(userID).child("trackRequests").child(CURRENT_USER_ID).removeValue()
    }
    
    /** update postition in the database */
    func updatePosition(lat latitude: String, long longitude: String) -> Void {
        // get the current date and time
        let currentDateTime = Date()
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        
        // get the date time String from the date object
        let date = formatter.string(from: currentDateTime)
        
        let pos = ["latitude": latitude,
                    "longitude": longitude,
                    "lastUpdatedDate": date]
        CURRENT_USER_REF.child("position").setValue(pos)
    }
    
    // MARK: - postition
    /** get postition from the database */
    func getUserPositionObserver(ForUserID userID: String, completion: @escaping (PositionData) -> Void) {
        USERS_REF.child(userID).child("position").observe(DataEventType.value, with: { (snapshot) in
            let lat = snapshot.childSnapshot(forPath: "latitude").value as! String
            let long = snapshot.childSnapshot(forPath: "longitude").value as! String
            let date = snapshot.childSnapshot(forPath: "lastUpdatedDate").value as! String
            completion(PositionData(latitude: lat, longitude: long, date: date))
        })
    }
    /** Removes the postition observer. */
    func removePositionObserver() {
        USERS_REF.removeAllObservers()
    }
    
    
    // MARK: - All Accepted tracking users
    /** The list of all Accepted tracking users ID */
    var AcceptedTrackingUserIDList = [String]()
    /** Adds a Accepted tracking user observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addAcceptedTrackingUserObserver(_ update: @escaping () -> Void) {
        CURRENT_USER_ACCEPTED_REF.observe(DataEventType.value, with: { (snapshot) in
            self.AcceptedTrackingUserIDList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                self.AcceptedTrackingUserIDList.append(id)
            }
            update()
        })
    }
    /** Removes the Accepted user observer. This should be done when leaving the view that uses the observer. */
    func removeAcceptedUserObserver() {
        CURRENT_USER_ACCEPTED_REF.removeAllObservers()
    }
    
    
    // MARK: - All users
    /** The list of all users */
    var userList = [UserData]()
    /** Adds a user observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addUserObserver(_ update: @escaping () -> Void) {
        USERS_REF.observe(DataEventType.value, with: { (snapshot) in
            self.userList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let email = child.childSnapshot(forPath: "email").value as! String
                let id = child.key
                if email != Auth.auth().currentUser?.email! {
                    self.group.enter()
                    self.getUser(id, completion: { (user) in
                        self.userList.append(user)
                        self.group.leave()
                    })
                }
            }
            self.group.notify(queue: .main) {
                update()
            }
            
        })
    }
    /** Removes the user observer. This should be done when leaving the view that uses the observer. */
    func removeUserObserver() {
        USERS_REF.removeAllObservers()
    }
    
    
    // MARK: - searched users
    /** The list of searched users */
    var searchedUsersList = [UserData]()
    /** search users. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func SearchUsers(WithName name: String, update: @escaping () -> Void) {
        USERS_REF.queryOrdered(byChild: "userNameLower").queryStarting(atValue: name.lowercased()).queryEnding(atValue: name.lowercased()+"\u{f8ff}").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            self.searchedUsersList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let email = child.childSnapshot(forPath: "email").value as! String
                let id = child.key
                if email != Auth.auth().currentUser?.email! {
                    self.group.enter()
                    self.getUser(id, completion: { (user) in
                        if child.childSnapshot(forPath: "friends").exists() && child.childSnapshot(forPath: "friends").hasChild(self.CURRENT_USER_ID){
                            user.sIsFriend = true
                        } else if child.childSnapshot(forPath: "friendRequests").exists() && child.childSnapshot(forPath: "friendRequests").hasChild(self.CURRENT_USER_ID){
                            user.sIsFriendRequested = true
                        }
                        self.searchedUsersList.append(user)
                        self.group.leave()
                    })
                }
            }
            self.group.notify(queue: .main) {
                update()
            }
        })
    }
    
    
    
    // MARK: - All friends
    /** The list of all friends of the current user. */
    var friendList = [UserData]()
    /** Adds a friend observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addFriendObserver(_ update: @escaping () -> Void) {
        CURRENT_USER_FRIENDS_REF.observe(DataEventType.value, with: { (snapshot) in
            self.friendList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                self.group.enter()
                self.getUser(id, completion: { (user) in
                    user.fChatId = child.value as! String
                    self.friendList.append(user)
                    self.group.leave()
                })
            }
            self.group.notify(queue: .main) {
                update()
            }
        })
    }
    /** Adds a friend observer for the specified group id. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addFriendObserver(ForGroupID groupID: String, update: @escaping () -> Void) {
        CURRENT_USER_FRIENDS_REF.observe(DataEventType.value, with: { (snapshot) in
            self.friendList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                self.group.enter()
                self.getUser(id, completion: { (user) in
                    user.fChatId = child.value as! String
                    if child.childSnapshot(forPath: "groups").exists() && child.childSnapshot(forPath: "groups").hasChild(groupID){
                        user.gsIsInThisGroup = true
                    } else if child.childSnapshot(forPath: "groupRequests").exists() && child.childSnapshot(forPath: "groupRequests").hasChild(groupID){
                        user.gsIsInThisGroupRequested = true
                    }
                    self.friendList.append(user)
                    self.group.leave()
                })
            }
            self.group.notify(queue: .main) {
                update()
            }
        })
    }
    /** Removes the friend observer. This should be done when leaving the view that uses the observer. */
    func removeFriendObserver() {
        CURRENT_USER_FRIENDS_REF.removeAllObservers()
    }
    
    
    // MARK: - All userGroups
    /** The list of all groups of the current user. */
    var userGroupdList = [GroupData]()
    /** Adds a userGroups observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addUserGroupsObserver(_ update: @escaping () -> Void) {
        CURRENT_USER_GROUPS_REF.observe(DataEventType.value, with: { (snapshot) in
            self.userGroupdList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                self.group.enter()
                self.getGroup(id, completion:  { (group) in
                    self.userGroupdList.append(group)
                    self.group.leave()
                })
            }
            self.group.notify(queue: .main) {
                update()
            }
        })
    }
    /** Removes the userGroups observer. This should be done when leaving the view that uses the observer. */
    func removeUserGroupObserver() {
        CURRENT_USER_GROUPS_REF.removeAllObservers()
    }
    
    
    // MARK: - All GroupMembers
    /** The list of all members of the group id. */
    var userGroupMembers = [UserData]()
    /** Adds a members observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addMembersObserver(ForGroupID groupID: String, update: @escaping () -> Void) {
        GROUPS_REF.child(groupID).child("members").observe(DataEventType.value, with: { (snapshot) in
            self.userGroupMembers.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                let isChild = child.childSnapshot(forPath: "isChild").value as! Bool
                let isGhostActive = child.childSnapshot(forPath: "isGhostActive").value as! Bool
                self.group.enter()
                self.getUser(id, completion: { (user) in
                    user.gIsChild = isChild
                    user.gIsGhostActive = isGhostActive
                    self.userGroupMembers.append(user)
                    self.group.leave()
                })
            }
            self.group.notify(queue: .main) {
                update()
            }
        })
    }
    /** Removes the userGroups observer. This should be done when leaving the view that uses the observer. */
    func removeMembersObserver() {
        CURRENT_USER_GROUPS_REF.removeAllObservers()
    }
    
    
    // MARK: - All friend requests
    /** The list of all friend requests the current user has. */
    var friendRequestList = [UserData]()
    /** Adds a friend request observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addFriendRequestObserver(_ update: @escaping () -> Void) {
        CURRENT_USER_FRIEND_REQUESTS_REF.observe(DataEventType.value, with: { (snapshot) in
            self.friendRequestList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                let sentTime = child.childSnapshot(forPath: "sentTime").value as! String
                self.group.enter()
                self.getUser(id, completion: { (user) in
                    user.reqSentTime = sentTime
                    self.friendRequestList.append(user)
                    self.group.leave()
                })
            }
            self.group.notify(queue: .main) {
                update()
            }
        })
    }
    /** Removes the friend request observer. This should be done when leaving the view that uses the observer. */
    func removeRequestObserver() {
        CURRENT_USER_FRIEND_REQUESTS_REF.removeAllObservers()
    }
    
    
    // MARK: - All group requests
    /** The list of all group requests the current user has. */
    var groupRequestList = [GroupData]()
    /** Adds a group request observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addGroupRequestObserver(_ update: @escaping () -> Void) {
        CURRENT_USER_GROUP_REQUESTS_REF.observe(DataEventType.value, with: { (snapshot) in
            self.groupRequestList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                let sentTime = child.childSnapshot(forPath: "sentTime").value as! String
                self.group.enter()
                self.getGroup(id, completion: { (group) in
                    group.reqSentTime = sentTime
                    self.groupRequestList.append(group)
                    self.group.leave()
                })
            }
            self.group.notify(queue: .main) {
                update()
            }
        })
    }
    /** Removes the group request observer. This should be done when leaving the view that uses the observer. */
    func removeGroupRequestObserver() {
        CURRENT_USER_GROUP_REQUESTS_REF.removeAllObservers()
    }
    
    
    // MARK: - All messages from chat ID
    /** The list of all messages from chat ID. */
    var messagesList = [MessageData]()
    /** Adds a message observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addMessageObserver(FromChatID chatID: String, update: @escaping () -> Void) {
        CHATS_REF.child(chatID).observe(DataEventType.value, with: { (snapshot) in
            self.messagesList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                self.group.enter()
                self.getMessage(chatID, id, completion: { (message) in
                    self.messagesList.append(message)
                    self.group.leave()
                })
            }
            self.group.notify(queue: .main) {
                update()
            }
        })
    }
    /** Removes the message request observer. This should be done when leaving the view that uses the observer. */
    func removeMessageObserver() {
        CHATS_REF.removeAllObservers()
    }
}

