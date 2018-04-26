
import Firebase
import FirebaseAuth
import GeoFire

class SocialSystem {
    
    static let system = SocialSystem()
    
    // MARK: - Firebase references
    /** The base Firebase reference */
    let BASE_REF = Database.database().reference()
    /** The locations Firebase reference */
    let LOCATIONS_REF = Database.database().reference().child("locations")
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
    
    /** The GeoFire object */
    var GEOFIRE_OBJ: GeoFire {
        return GeoFire(firebaseRef: Database.database().reference().child("GeoFireLocations"))
    }
    
    /** The Firebase reference to the current user's friend tree */
    var CURRENT_USER_FRIENDS_REF: DatabaseReference {
        return CURRENT_USER_REF.child("friends")
    }
    
    /** The Firebase reference to the current user's group tree */
    var CURRENT_USER_GROUPS_REF: DatabaseReference {
        return CURRENT_USER_REF.child("groups")
    }
    
    /** The Firebase reference to the current user's tracking requests tree */
    var CURRENT_USER_TRACK_REQUEST_REF: DatabaseReference {
        return CURRENT_USER_REF.child("trackRequests")
    }
    
    /** The Firebase reference to the current user's accepted tracking tree */
    var CURRENT_USER_ACCEPTED_TRACK_REF: DatabaseReference {
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
        if Auth.auth().currentUser == nil {
            return "NOTSIGNED"
        }
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
            let senderID = snapshot.childSnapshot(forPath: "senderID").value as! String
            let message = snapshot.childSnapshot(forPath: "message").value as! String
            let date = snapshot.childSnapshot(forPath: "date").value as! String
            let id = snapshot.key
            completion(MessageData(sender: sender, senderID: senderID, id: id, message: message, date: date))
            
        })
    }
    /** Gets the zone object for the specified zone id */
    func getZone(_ groupID: String,_ zoneID: String, completion: @escaping (ZoneData) -> Void) {
        GROUPS_REF.child(groupID).child("zones").child(zoneID).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let lat = snapshot.childSnapshot(forPath: "latitude").value as! Double
            let long = snapshot.childSnapshot(forPath: "longitude").value as! Double
            let rad = snapshot.childSnapshot(forPath: "radius").value as! Double
            completion(ZoneData(latitude: lat, longitude: long, radius: rad))
        })
    }
    
    // MARK: - System Functions
    
    /** Create a Group and make current user the admin */
    func createGroup(WithGroupName groupName: String) -> String {
        let ref = GROUPS_REF.childByAutoId()
        let group = ["groupName": groupName,
                     "admin": CURRENT_USER_ID,
                     "chatId": ref.key]
        ref.setValue(group)
        CURRENT_USER_GROUPS_REF.child(ref.key).setValue(true)
        CHATS_REF.child(ref.key)
        return ref.key
    }
    
    /** Create a zone for the group */
    func createZone(ForGroupID groupID: String, Latitude lat: Double, Longitude long: Double, Radius rad: Double) {
        let zone = ["latitude": lat,
                    "longitude": long,
                    "radius": rad]
        GROUPS_REF.child(groupID).child("zones").childByAutoId().setValue(zone)
    }
    
    /** Sends a friend request to the user with the specified id */
    func sendFriendRequest(ToUserID userID: String) {
        // get the current date and time
        let currentDateTime = Date()
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        
        // get the date time String from the date object
        let date = formatter.string(from: currentDateTime)
        
        USERS_REF.child(userID).child("friendRequests").child(CURRENT_USER_ID).child("sentTime").setValue(date)
    }
    
    /** Sends a group request with given groupID to the user with the specified id */
    func sendGroupRequest(ToUserID userID: String, ForGroupID groupID: String, isChild: Bool) {
        // get the current date and time
        let currentDateTime = Date()
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        
        // get the date time String from the date object
        let date = formatter.string(from: currentDateTime)
        
        let groupReq = ["sentTime": date,
                        "isChild": isChild] as [String : Any]
        USERS_REF.child(userID).child("groupRequests").child(groupID).setValue(groupReq)
    }
    
    /** Accepts a friend request from the user with the specified id */
    func acceptFriendRequest(FromUserID userID: String) {
        let chatId = CHATS_REF.childByAutoId().key
        CURRENT_USER_REF.child("friendRequests").child(userID).removeValue()
        CURRENT_USER_REF.child("friends").child(userID).setValue(chatId)
        USERS_REF.child(userID).child("friends").child(CURRENT_USER_ID).setValue(chatId)
        USERS_REF.child(userID).child("friendRequests").child(CURRENT_USER_ID).removeValue()
    }
    
    /** Reject a friend request from the user with the specified id */
    func rejectFriendRequest(FromUserID userID: String) {
        CURRENT_USER_REF.child("friendRequests").child(userID).removeValue()
    }
    
    /** Accepts a group request with given id*/
    func acceptGroupRequest(FromGroupID groupID: String) {
        //let isChild = CURRENT_USER_REF.child("groupRequests").child(groupID).value(forKey: "isChild") as! Bool
        CURRENT_USER_REF.child("groupRequests").child(groupID).child("isChild").observeSingleEvent(of: DataEventType.value) { (snapshot) in
            let isChild = snapshot.value as! Bool
            self.CURRENT_USER_REF.child("groupRequests").child(groupID).removeValue()
            self.CURRENT_USER_REF.child("groups").child(groupID).setValue(true)
            self.GROUPS_REF.child(groupID).child("members").child(self.CURRENT_USER_ID).child("isChild").setValue(isChild)
            self.GROUPS_REF.child(groupID).child("members").child(self.CURRENT_USER_ID).child("isGhostActive").setValue(false)
        }
    }
    
    /** Reject a group request from the user with the specified id */
    func rejectGroupRequest(FromGroupID groupID: String) {
        CURRENT_USER_REF.child("groupRequests").child(groupID).removeValue()
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
        // get the current date and time
        let currentDateTime = Date()
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        
        // get the date time String from the date object
        let date = formatter.string(from: currentDateTime)
        
        //let name = CURRENT_USER_REF.value(forKey: "userName") as! String
        CURRENT_USER_REF.child("userName").observeSingleEvent(of: DataEventType.value) { (snapshot) in
            let name = snapshot.value as! String
            let message = ["message": message,
                           "sender": name,
                           "senderID": self.CURRENT_USER_ID,
                           "date": date]
            self.CHATS_REF.child(chatID).childByAutoId().setValue(message)
        }

    }
    
    // TODO: change to other format
    /** send tracking request to the given chat ID */
    func sendTrackRequest(ToUserID userID: String) {
        // get the current date and time
        let currentDateTime = Date()
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        
        // get the date time String from the date object
        let date = formatter.string(from: currentDateTime)
        USERS_REF.child(userID).child("trackRequests").child(CURRENT_USER_ID).child("sentTime").setValue(date)
    }
    
    // TODO: change to include timer
    /** Accepts a track request from the user with the specified id */
    func acceptTrackRequest(FromUserID userID: String) {
        CURRENT_USER_REF.child("trackRequests").child(userID).removeValue()
        CURRENT_USER_REF.child("acceptedTracking").child(userID).setValue(true)
        USERS_REF.child(userID).child("acceptedTracking").child(CURRENT_USER_ID).setValue(true)
        USERS_REF.child(userID).child("trackRequests").child(CURRENT_USER_ID).removeValue()
    }
    
    /** Reject a track request from the user with the specified id */
    func rejectTrackRequest(FromUserID userID: String) {
        CURRENT_USER_REF.child("trackRequests").child(userID).removeValue()
    }
    
    /** update postition in the database */
    func updatePosition(lat latitude: Double, long longitude: Double, alti altitude: Double) -> Void {
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
                   "altitude": altitude,
                   "lastUpdatedDate": date] as [String : Any]
        
        GEOFIRE_OBJ.setLocation(CLLocation(latitude: latitude, longitude: longitude), forKey: CURRENT_USER_ID)
        LOCATIONS_REF.child(CURRENT_USER_ID).setValue(pos)
    }
    
    // MARK: - postition
    /** get postition from the database */
    func getUserPositionObserver(ForUserID userID: String, completion: @escaping (PositionData) -> Void) {
        LOCATIONS_REF.child(userID).observe(DataEventType.value, with: { (snapshot) in
            let lat = snapshot.childSnapshot(forPath: "latitude").value as! Double
            let long = snapshot.childSnapshot(forPath: "longitude").value as! Double
            let alti = snapshot.childSnapshot(forPath: "altitude").value as! Double
            let date = snapshot.childSnapshot(forPath: "lastUpdatedDate").value as! String
            completion(PositionData(latitude: lat, longitude: long, altitude: alti,  date: date))
        })
    }
    /** Removes the postition observer. */
    func removePositionObserver() {
        USERS_REF.removeAllObservers()
    }
    
    // MARK: - All tracking requests
    /** The list of all tracking requests users ID */
    var trackingRequestIDList = [String]()
    /** Adds a tracking requests user observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addTrackingRequestObserver(_ update: @escaping () -> Void) {
        CURRENT_USER_TRACK_REQUEST_REF.observe(DataEventType.value, with: { (snapshot) in
            self.trackingRequestIDList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                self.trackingRequestIDList.append(id)
            }
            update()
        })
    }
    /** Removes the Tracking requests observer. This should be done when leaving the view that uses the observer. */
    func removeTrackingRequestObserver() {
        CURRENT_USER_TRACK_REQUEST_REF.removeAllObservers()
    }

    // MARK: - All Accepted tracking users
    /** The list of all Accepted tracking users ID */
    var acceptedTrackingUserIDList = [String]()
    /** Adds a Accepted tracking user observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addAcceptedTrackingUserObserver(_ update: @escaping () -> Void) {
        CURRENT_USER_ACCEPTED_TRACK_REF.observe(DataEventType.value, with: { (snapshot) in
            self.acceptedTrackingUserIDList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                self.acceptedTrackingUserIDList.append(id)
            }
            update()
        })
    }
    /** Removes the Accepted user observer. This should be done when leaving the view that uses the observer. */
    func removeAcceptedUserObserver() {
        CURRENT_USER_ACCEPTED_TRACK_REF.removeAllObservers()
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
        if(name.isEmpty){
            self.searchedUsersList.removeAll()
            return
        }
        USERS_REF.queryOrdered(byChild: "userNameLower").queryStarting(atValue: name.lowercased()).queryEnding(atValue: name.lowercased()+"\u{f8ff}").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            self.searchedUsersList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let email = child.childSnapshot(forPath: "email").value as! String
                let id = child.key
                if email != Auth.auth().currentUser?.email! {
                    self.group.enter()
                    self.getUser(id, completion: { (user) in
                        self.USERS_REF.child(id).child("friends").observeSingleEvent(of: .value, with: { (snapshot) in
                            user.sIsFriend = snapshot.hasChild(self.CURRENT_USER_ID)
                        })
                        self.USERS_REF.child(id).child("friendRequests").observeSingleEvent(of: .value, with: { (snapshot) in
                            user.sIsFriendRequested = snapshot.hasChild(self.CURRENT_USER_ID)
                        })
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
                    self.USERS_REF.child(id).child("acceptedTracking").observeSingleEvent(of: .value, with: { (snapshot) in
                        user.fIsTracked = snapshot.hasChild(self.CURRENT_USER_ID)
                    })
                    self.USERS_REF.child(id).child("trackRequests").observeSingleEvent(of: .value, with: { (snapshot) in
                        user.fIsTrackRequested = snapshot.hasChild(self.CURRENT_USER_ID)
                    })
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
                    self.USERS_REF.child(id).child("groups").observeSingleEvent(of: .value, with: { (snapshot) in
                        user.gsIsInThisGroup = snapshot.hasChild(groupID)
                    })
                    self.USERS_REF.child(id).child("groupRequests").observeSingleEvent(of: .value, with: { (snapshot) in
                        user.gsIsInThisGroupRequested = snapshot.hasChild(groupID)
                    })
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
                let amIChild = child.childSnapshot(forPath: "isChild").value as! Bool
                self.group.enter()
                self.getGroup(id, completion: { (group) in
                    group.reqSentTime = sentTime
                    group.amIChild = amIChild
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
    /** Removes the message observer. This should be done when leaving the view that uses the observer. */
    func removeMessageObserver() {
        CHATS_REF.removeAllObservers()
    }

    // MARK: - All zones from group ID
    /** The list of all zones from group ID. */
    var zonesList = [ZoneData]()
    /** Adds a zone observer. The completion function will run every time this list changes, allowing you
     to update your UI. */
    func addZoneObserver(FromGroupID groupID: String, update: @escaping () -> Void) {
        GROUPS_REF.child(groupID).child("zones").observe(DataEventType.value, with: { (snapshot) in
            self.zonesList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                self.group.enter()
                self.getZone(groupID, id, completion: { (zone) in
                    self.zonesList.append(zone)
                    self.group.leave()
                })
            }
            self.group.notify(queue: .main) {
                update()
            }
        })
    }
    /** Removes the zone observer. This should be done when leaving the view that uses the observer. */
    func removeZoneObserver() {
        GROUPS_REF.removeAllObservers()
    }
    
    /** get postition from the database */
    func getUsersExitedZoneObserver(ForGroupID groupID: String, Latitude lat: Double, Longitude long: Double, Radius rad: Double, completion: @escaping (UserData) -> Void) {
        let circleQuery = GEOFIRE_OBJ.query(at: CLLocation(latitude: lat, longitude: long), withRadius: rad)
        circleQuery.observe(.keyExited) { (UserIdKey, location) in
            self.GROUPS_REF.child(groupID).child("members").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                if snapshot.hasChild(UserIdKey) {
                    self.getUser(UserIdKey, completion: { (user) in
                        completion(user)
                    })
                }
            })
        }
    }
    
}
