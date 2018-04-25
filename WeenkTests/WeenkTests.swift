//
//  WeenkTests.swift
//  WeenkTests
//
//  Created by Abdulrahman Alzeer on 25/04/2018.
//  Copyright © 2018 ETAR. All rights reserved.
//

import XCTest
import Firebase
import ARCL
@testable import Weenk
class WeenkTests: XCTestCase {
    
    let view :ViewController!  = ViewController()
    func testMakeArmarker() {
        let marker = view.makeARmarker(latitude: 1.0, longitude: 1.0, altitude: 1.0)
        var bool : Bool  = false
        if let markerType = marker as? LocationAnnotationNode {
            bool = true
        }
        XCTAssert(bool, "ar Marker ")
    }
    func testSelectFriendOnTable(){
        
        
        let actions = buttonActions(button: view.dropDownBtn)
        if let actions = actions {
            XCTAssert(actions.count > 0)
        }
    }
    
    func testfriendObserveWork(){
        SocialSystem.system.addUserObserver {
            ////
        }
        XCTAssert(SocialSystem.system.friendList.count > 0 , "observer Work")
    }
    
    func testfriendRequestObserveWork(){
        SocialSystem.system.addFriendRequestObserver {
            /////
        }
        XCTAssert(SocialSystem.system.friendRequestList.count > 0, "observer Work")
    }
    
    func testgroupRequestObserverWork(){
        SocialSystem.system.addGroupRequestObserver {
            //
        }
        XCTAssert(SocialSystem.system.groupRequestList.count > 0, "observer Work")
    }
    
    func testgroupObserverWork(){
        SocialSystem.system.addUserGroupsObserver {
            //
        }
        XCTAssert(SocialSystem.system.userGroupdList.count > 0, "observer Work")
    }
    
    func arButtonWork(){
        
        
    }
    
    func buttonActions(button: UIButton?) -> [String]? {
        
        return button?.actions(forTarget: ViewController(), forControlEvent: .touchUpInside) as? [String]
    }
    
    
    
    
}
