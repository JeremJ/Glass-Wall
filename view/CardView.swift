//
//  CardView.swift
//  GlassWall-SwiftUI
//
//  Created by Jeremiasz Jaworski on 21/12/2020.
//

import SwiftUI
import SDWebImageSwiftUI

struct CardView: View {
    var item: Item
    var animation: Namespace.ID
    
    var body: some View {
        
        VStack{
            
            AnimatedImage(url: URL(string: item.image))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .matchedGeometryEffect(id: "image\(item.id)", in: animation)
                .padding(.top, 15)
                .padding(.bottom)
                .padding(.horizontal, 2)

        }
        .cornerRadius(15)
    }
}
