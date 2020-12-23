//
//  MenuView.swift
//  GlassWall-SwiftUI
//
//  Created by Jeremiasz Jaworski on 21/12/2020.
//

import SwiftUI

struct Menu: View {
    var body: some View {
        VStack(spacing: 25) {
            Button(action: {
                
            }) {
                VStack(spacing: 8){
                    Image(systemName: "Menu")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 55, height: 55)
                    Text("Camera")
                }
            }
            
            Button(action: {
                
            }) {
                VStack(spacing: 8){
                    Image(systemName: "camera")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 55, height: 55)
                    
                    Text("History")
                }
            }
            Spacer(minLength: 15)
        }.padding(35)
        .foregroundColor(.black)
        .background(Color("Color").edgesIgnoringSafeArea(.bottom))
    }
}
