//
//  ItemsViewModel.swift
//  GlassWall-SwiftUI
//
//  Created by Jeremiasz Jaworski on 22/12/2020.
//

import Foundation
import SwiftUI
import Combine
import FirebaseDatabase

final class ItemsViewModel: ObservableObject {
    
    private let database = Database.database().reference()

    @Published var items = [Item]()
    
    init() {
        getAllPanels()
    }
    
    func getAllPanels() {
        database.child("panels").observe(.value, with: {(snapshot) in
            
            let allObjects = snapshot.children.allObjects as! [DataSnapshot]
            for item in allObjects  {
                let dict = item.value as? Dictionary<String, AnyObject>
                let image = dict!["image"] as! String
                let title = dict!["title"] as! String
                let id = dict!["id"] as! String
                let width = (dict!["width"] as? NSNumber)?.floatValue ?? 0
                let depth = (dict!["depth"] as? NSNumber)?.floatValue ?? 0

                let newItem = Item(id: id, title: title, image: image, width: width, depth: depth)
                self.items.append(newItem)
            }
        })
    }
}
