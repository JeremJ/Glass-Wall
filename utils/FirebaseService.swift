//
//  FirebaseService.swift
//  GlassWall-SwiftUI
//
//  Created by Jeremiasz Jaworski on 22/12/2020.
//

import SwiftUI
import FirebaseDatabase
import FirebaseStorage

class FirebaseService {
    private let database = Database.database().reference()
    private let storage = Storage.storage().reference(forURL: "gs://glasswall-b5078.appspot.com")
    
    public func saveNewPanel(image: UIImage?, width: Float, depth: Float) {
        guard let selectedImage = image?.jpegData(compressionQuality: 0.8) else
        {return}
        let id = UUID.init().uuidString
        var panel: Dictionary<String, Any> = [
            "id": id,
            "title": "panel",
            "image": "",
            "width": width,
            "depth": depth
        ]
        let storagePanelRef = storage.child("panel").child(id)
        
        storagePanelRef.putData(selectedImage).observe(.success) { (snapshot) in
            storagePanelRef.downloadURL(completion: { (url, error) in
                
                if let downloadUrl = url {
                    
                    let directoryURL : NSURL = downloadUrl as NSURL
                    let urlString:String = directoryURL.absoluteString!
                    
                    panel["image"] = urlString
                    Database.database().reference().child("panels")
                        .child(id).updateChildValues(panel, withCompletionBlock: {(error, ref) in
                            if error == nil {
                                print("done")
                            }
                        })
                }
                else {
                    print("couldn't get image url")
                    return
                }
            })}
    }
}
