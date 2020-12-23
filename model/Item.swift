//
//  Item.swift
//  GlassWall-SwiftUI
//
//  Created by Jeremiasz Jaworski on 21/12/2020.
//

import SwiftUI

struct Item: Identifiable {
    
    var id: String
    var title: String
    var image: String
    var width: Float
    var depth: Float
}


var items = [

    Item(id: "ss", title: "Owocki", image: "owocki", width: 1.0, depth: 2.0),
    Item(id: "qq", title: "Santorini", image: "santorni", width: 1.0, depth: 2.0),
    Item(id: "22", title: "Tatry", image: "tatry", width: 1.0, depth: 2.0),
]
