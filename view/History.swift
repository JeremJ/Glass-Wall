//
//  History.swift
//  GlassWall-SwiftUI
//
//  Created by Jeremiasz Jaworski on 21/12/2020.
//
import SwiftUI

struct History: View {
    
    
    @ObservedObject var model = ItemsViewModel()
    @Namespace var animation
    @State var show = false
    @State var selectedItem: Item = items[0]

    var body: some View {
        
        ZStack{
            
            VStack{
                
                ScrollView{
                    
                    VStack{
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 3), spacing: 5){
                            
                            ForEach(model.items){item in
                                CardView(item: item, animation: animation)
                                    .onTapGesture {
                                        
                                        withAnimation(.spring()){
                                            
                                            selectedItem = item
                                            show.toggle()
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer(minLength: 0)
            }
            .opacity(show ? 0 : 1)
            
            if show{
                
                Detail(selectedItem: $selectedItem, show: $show, animation: animation)
            }
            
        }.padding(.top, 2)
        .background(Color.white.ignoresSafeArea())
    }
}
