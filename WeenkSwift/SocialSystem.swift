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
    
    /** The Firebase reference to the current user's friend request tree */
    var CURRENT_USER_REQUESTS_REF: DatabaseReference {
        return CURRENT_USER_REF.child("requests")
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
            let name = snapshot.childSnapshot(forPath: "name").value as! String
            let photoURL = snapshot.childSnapshot(forPath: "photoURL").value as! String
            let id = snapshot.key
            completion(UserData(userEmail: email, userName: name, userPhotoURL: photoURL, userID: id))
        })
    }
    /** Gets the User object for the specified user id */
    func getUser(_ userID: String, completion: @escaping (UserData) -> Void) {
        USERS_REF.child(userID).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let email = snapshot.childSnapshot(forPath: "email").value as! String
            let name = snapshot.childSnapshot(forPath: "name").value as! String
            let photoURL = snapshot.childSnapshot(forPath: "photoURL").value as! String
            let id = snapshot.key
            completion(UserData(userEmail: email, userName: name, userPhotoURL: photoURL, userID: id))
            
        })
    }
    /** Gets the group object for the specified user id */
    func getCurrentUserGroups(_ completion: @escaping (GroupData) -> Void) {
        CURRENT_USER_GROUPS_REF.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let adminId = snapshot.childSnapshot(forPath: "admin").value as! String
            let name = snapshot.childSnapshot(forPath: "groupName").value as! String
            let id = snapshot.key
            completion(GroupData(groupName: name, id: id, adminId: adminId))
            
        })
    }
    
    
    // MARK: - Request System Functions
    
    /** Create a Group and make admin the user with the specified id */
    func createGroup(_ groupName: String) {
        let ref = GROUPS_REF.childByAutoId()
        ref.child("groupName").setValue(groupName)
        ref.child("admin").setValue(CURRENT_USER_ID)
        CURRENT_USER_GROUPS_REF.child(ref.key).setValue(true)
    }
    
    /** Sends a friend request to the user with the specified id */
    func sendRequestToUser(_ userID: String) {
        USERS_REF.child(userID).child("requests").child(CURRENT_USER_ID).setValue(true)
    }
    
    /** Unfriends the user with the specified id */
    func removeFriend(_ userID: String) {
        CURRENT_USER_REF.child("friends").child(userID).removeValue()
        USERS_REF.child(userID).child("friends").child(CURRENT_USER_ID).removeValue()
    }
    
    /** Accepts a friend request from the user with the specified id */
    func acceptFriendRequest(_ userID: String) {
        CURRENT_USER_REF.child("requests").child(userID).removeValue()
        CURRENT_USER_REF.child("friends").child(userID).setValue(true)
        USERS_REF.child(userID).child("friends").child(CURRENT_USER_ID).setValue(true)
        USERS_REF.child(userID).child("requests").child(CURRENT_USER_ID).removeValue()
    }
    
    
    
    // MARK: - All users
    /** The list of all users */
    var userList = [UserData]()
    /** Adds a user observer. The completion function will run every time this list changes, allowing you  
     to update your UI. */
    func addUserObserver(_ update: @escaping () -> Void) {
        SocialSystem.system.USERS_REF.observe(DataEventType.value, with: { (snapshot) in
            self.userList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let email = child.childSnapshot(forPath: "email").value as! String
                let name = child.childSnapshot(forPath: "name").value as! String
                let photoURL = child.childSnapshot(forPath: "photoURL").value as! String
                if email != Auth.auth().currentUser?.email! {
                    self.userList.append(UserData(userEmail: email, userName: name, userPhotoURL: photoURL, userID: child.key))
                }
            }
            update()
        })
    }
    /** Removes the user observer. This should be done when leaving the view that uses the observer. */
    func removeUserObserver() {
        USERS_REF.removeAllObservers()
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
                self.getUser(id, completion: { (user) in
                    self.friendList.append(user)
                    update()
                })
            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
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
                self.getCurrentUserGroups( { (group) in
                    self.userGroupdList.append(group)
                    update()
                })
            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
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
    func addMembersObserver(_ groupID: String, update: @escaping () -> Void) {
        GROUPS_REF.child(groupID).child("members").observe(DataEventType.value, with: { (snapshot) in
            self.userGroupMembers.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                self.getUser(id, completion: { (user) in
                    self.userGroupMembers.append(user)
                    update()

                })
            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }
    /** Removes the userGroups observer. This should be done when leaving the view that uses the observer. */
    func removeMembersObserver() {
        CURRENT_USER_GROUPS_REF.removeAllObservers()
    }
    
    
    
    // MARK: - All requests
    /** The list of all friend requests the current user has. */
    var requestList = [UserData]()
    /** Adds a friend request observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addRequestObserver(_ update: @escaping () -> Void) {
        CURRENT_USER_REQUESTS_REF.observe(DataEventType.value, with: { (snapshot) in
            self.requestList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                self.getUser(id, completion: { (user) in
                    self.requestList.append(user)
                    update()
                })
            }
            // If there are no children, run completion here instead
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }
    /** Removes the friend request observer. This should be done when leaving the view that uses the observer. */
    func removeRequestObserver() {
        CURRENT_USER_REQUESTS_REF.removeAllObservers()
    }
    
}



