//
//  PostListModel.swift
//  DeliveryTracker
//
//  Created by 김수완 on 2020/12/19.
//

import Foundation

struct Carrier {
    let name : String
    let id : String
}

struct Post {
    let Carrier : Carrier
    let PostNum : String
}

