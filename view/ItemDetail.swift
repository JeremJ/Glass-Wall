//
//  ItemDetail.swift
//  GlassWall-SwiftUI
//
//  Created by Jeremiasz Jaworski on 21/12/2020.
//

import SwiftUI
import SDWebImageSwiftUI

struct Detail: View {
    @Binding var selectedItem: Item
    @Binding var show: Bool
    
    var animation: Namespace.ID
    
    @State var loadContent = false
    
    @State var selectedColor : Color = Color("p1")
    
    var body: some View {
        
        ScrollView(UIScreen.main.bounds.height < 750 ? .vertical : .init(), content: {
            
            VStack{
                
                HStack {
                    
                    Button(action: {
                        // closing view...
                        withAnimation(.spring()){show.toggle()}
                    }) {
                        
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                }
                .padding()
                
                VStack {
                    
                    AnimatedImage(url: URL(string: selectedItem.image))
                        .resizable()
                        .frame(width: 320, height: 420)
                        .matchedGeometryEffect(id: "image\(selectedItem.id)", in: animation)
                        .padding()

                }

                                
                VStack{
                    
                    VStack(alignment: .leading,spacing: 8){
                        
                        Text(String(format: "Width: %.2f m, Height: %.2f m", selectedItem.width, selectedItem.depth))
                            .fontWeight(.heavy)
                            .foregroundColor(.black)
                        
                    }
                    .padding()
                    .frame(width: UIScreen.main.bounds.width - 30, alignment: .leading)
                    .background(Color("p3"))
                    .cornerRadius(15)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        
                        HStack(spacing: 5){
                            
                            ForEach(1...4,id: \.self){i in
                                
                                ZStack{
                                    
                                    Color("p\(i)")
                                        .clipShape(Circle())
                                        .frame(width: 45, height: 45)
                                        .onTapGesture {
                                            
                                            withAnimation{
                                                selectedColor = Color("p\(i)")
                                            }
                                        }
                                                    
                                }
                            }
                            
                            Spacer(minLength: 0)
                        }
                    }
                    .padding()
                    
                }
                .padding([.horizontal,.bottom])
                .frame(height: loadContent ? nil : 0)
                .opacity(loadContent ? 1 : 0)
                
                Spacer(minLength: 0)
            }
        })
        .onAppear {
            
            withAnimation(Animation.spring().delay(0.45)){
                loadContent.toggle()
            }
        }
    }
}


struct CustomShape: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        return Path{path in
            
            let pt1 = CGPoint(x: rect.width, y: 0)
            let pt2 = CGPoint(x: 0, y: rect.height - 100)
            let pt3 = CGPoint(x: 0, y: rect.height)
            let pt4 = CGPoint(x: rect.width, y: rect.height)
            
            path.move(to: pt4)
            
            path.addArc(tangent1End: pt1, tangent2End: pt2, radius: 20)
            path.addArc(tangent1End: pt2, tangent2End: pt3, radius: 20)
            path.addArc(tangent1End: pt3, tangent2End: pt4, radius: 20)
            path.addArc(tangent1End: pt4, tangent2End: pt1, radius: 20)
        }
    }
}
