//
//  MainView.swift
//  GlassWall-SwiftUI
//
//  Created by Jeremiasz Jaworski on 21/12/2020.
//

import SwiftUI

struct MainView: View {
    @Binding var showMenu : Bool
    @Binding var index : String
    
    var body: some View {
        NavigationView {
            ZStack{
                
                History().opacity(self.index == "History" ? 1 : 0)
                
                GeometryReader{_ in
                    
                    HStack{
                        VStack {
                            Button(action: {
                                self.showMenu = false
                                self.index = "Camera"
                            }) {
                                VStack {
                                    Image(systemName: "camera.fill")
                                        .frame(width: 60, height: 60)
                                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                        .background(Color.white
                                                        .opacity(0.75))
                                        .cornerRadius(30)
                                        .padding(.bottom, 0)
                                    Text("Camera")
                                }
                            }
                            
                            Button(action: {
                                self.index = "History"
                            }) {
                                VStack {
                                    Image(systemName: "archivebox.fill")
                                        .frame(width: 60, height: 60)
                                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                        .background(Color.white
                                                        .opacity(0.75))
                                        .cornerRadius(30)
                                    Text("History")
                                }
                            }
                            Spacer(minLength: 5)
                        }.padding(20)
                        .foregroundColor(.black)
                        .background(Color("Color").edgesIgnoringSafeArea(.bottom))
                        .offset(x: self.showMenu ? 0 : UIScreen.main.bounds.width)
                        .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.6,
                                                      blendDuration: 0.6))
                        Spacer()
                    }
                }.background(Color.black.opacity(self.showMenu ? 0.5 : 0)
                                .edgesIgnoringSafeArea(.bottom))
                
            }.navigationBarTitle(index, displayMode: .inline)
            .navigationBarItems(leading:
                                    
                                    Button(action: {
                                        self.showMenu.toggle()
                                    }, label: {
                                        if self.showMenu{
                                            Image(systemName: "arrow.left").font(.body).foregroundColor(.black)
                                        } else {
                                            Image(systemName: "text.justify")
                                                .renderingMode(.original)
                                        }
                                        
                                    }))
        }
    }
}

