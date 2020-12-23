//
//  ContentView.swift
//  GlassWall-SwiftUI
//
//  Created by Jeremiasz Jaworski on 18/12/2020.
//

import SwiftUI
import RealityKit
import FocusEntity
import ARKit
import FirebaseDatabase
import FirebaseStorage

struct ContentView : View {
    
    @State private var isPlacementEnabled = false
    @State private var selectedModel: Model?
    @State private var modelConfirmedForPlacement: Model?
    @State private var isDesignModeEnable = true
    @State private var showMenu = false
    @State private var index = "History"
    @State private var captureScene = false
    @State private var clearScreen = false
    
    private var models: [Model] = {
        let filemanager = FileManager.default
        
        guard let path = Bundle.main.resourcePath, let
                files = try?
                filemanager.contentsOfDirectory(atPath: path) else {
            return []
        }
        var avaliableModels: [Model] = []
        for filename in files where filename.hasSuffix("png") {
            let modelName = filename.replacingOccurrences(of: ".png", with: "")
            let model = Model(modelName: modelName)
            avaliableModels.append(model)
        }
        return avaliableModels
    }()
    
    var body: some View {
        if index == "Camera" {
            ZStack(content: {
                ARViewContainer(modelConfirmedForPlacement: self.$modelConfirmedForPlacement,
                                isDesigningEnable: self.$isDesignModeEnable,
                                captureScene: $captureScene,
                                clearScreen: $clearScreen)
                    .edgesIgnoringSafeArea(.all)
                NavigationMenu(captureScene: $captureScene, clearScreen: $clearScreen, index: $index,
                               isDesignModeEnable: $isDesignModeEnable,
                               isPlacementEnabled: $isPlacementEnabled)
                if self.isDesignModeEnable {
                    if self.isPlacementEnabled {
                        PlacementButtonsView(isPlacementEnabled: self.$isPlacementEnabled,
                                             selectedModel: self.$selectedModel,
                                             modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
                    } else {
                        ElementPickerView(isPlacementEnabled: self.$isPlacementEnabled,
                                          selectedModel: self.$selectedModel,
                                          models: self.models.filter({$0.modelName == "clear"}))
                    }
                } else if !self.isDesignModeEnable {
                    if self.isPlacementEnabled {
                        PlacementButtonsView(isPlacementEnabled: self.$isPlacementEnabled,
                                             selectedModel: self.$selectedModel,
                                             modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
                    } else {
                        ElementPickerView(isPlacementEnabled: self.$isPlacementEnabled,
                                          selectedModel: self.$selectedModel,
                                          models: self.models.filter({$0.modelName != "clear"}))
                    }
                }
            })
        } else {
            MainView(showMenu: $showMenu, index: $index, isDesignModeEnable: $isDesignModeEnable)
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    static let panelWidth: Float = 0.6
    static let panelDepth: Float = 0.4
    
    @Binding var modelConfirmedForPlacement: Model?
    @Binding var isDesigningEnable: Bool
    @Binding var captureScene: Bool
    @Binding var clearScreen: Bool
    private let firebaseService: FirebaseService = FirebaseService()
    
    func makeUIView(context: Context) -> ARView {
        let focusView = FocusARView(frame: .zero)
        return focusView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        let createdAnchor = uiView.scene.anchors
            .filter({$0.name != "FocusEntity"})
        if self.isDesigningEnable {
            let elementsCount = createdAnchor.count
            if  elementsCount < 1 {
                createDesignElement(uiView: uiView)
            } else {
                DispatchQueue.main.async {
                    self.isDesigningEnable = false
                }
            }
        } else if self.captureScene {
            uiView.snapshot(saveToHDR: false, completion: {(image) in
                self.firebaseService.saveNewPanel(image: image,
                                                  width: createdAnchor[0].children[0].scale[0] * ARViewContainer.panelWidth,
                                                  depth: createdAnchor[0].children[0].scale[1] * ARViewContainer.panelDepth)
                DispatchQueue.main.async {
                    self.captureScene = false
                }
            })
        } else if self.clearScreen {
            self.undoChanges(uiView: uiView, createdAnchor: createdAnchor[0])
        } else {
            let focusEntity = extractFocusEntityAnchor(uiView: uiView)
            if focusEntity.count == 1 {
                uiView.scene.removeAnchor(focusEntity[0])
            }
            changeElementStyle(uiView: createdAnchor)
        }
    }
    
    func undoChanges(uiView: ARView, createdAnchor: HasAnchoring) {
        uiView.scene.removeAnchor(createdAnchor)
        DispatchQueue.main.async {
            self.isDesigningEnable = true
            self.clearScreen = false
        }
    }
    
    func extractFocusEntityAnchor(uiView: ARView) ->  Array<HasAnchoring> {
        return uiView.scene.anchors
            .filter({$0.name == "FocusEntity"})
    }
    
    func createDesignElement(uiView: ARView) {
        print("anchors: \(uiView.scene.anchors)")
        if self.modelConfirmedForPlacement != nil {
            let anchor = AnchorEntity(plane: .any)
            let box = MeshResource.generatePlane(width: ARViewContainer.panelWidth,
                                                 depth: ARViewContainer.panelDepth)
            let material = SimpleMaterial(color: .cyan, isMetallic: false)
            let entity = ModelEntity(mesh: box, materials: [material])
            entity.generateCollisionShapes(recursive: true)
            uiView.installGestures(.all, for: entity)
            
            anchor.addChild(entity)
            uiView.scene.anchors.append(anchor)
            
            DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
        }
    }
    
    func changeElementStyle(uiView: Array<HasAnchoring>) {
        if self.modelConfirmedForPlacement != nil {
            var material = SimpleMaterial()
            material.baseColor = try! .texture(.load(named: self.modelConfirmedForPlacement!.modelName))
            material.roughness = MaterialScalarParameter(floatLiteral: 0.9)
            material.tintColor = UIColor.white
            
            let entity = uiView[0].children[0]
            
            var component: ModelComponent = entity.components[ModelComponent]!.self
            component.materials = [material]
            entity.components.set(component)
            
            DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
        }
    }
    
    
}

struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedForPlacement: Model?
    var body: some View {
        HStack {
            Button(action: {
                print("Cancel")
                self.resetPlacementParams()
            }) {
                Image(systemName: "xmark")
                    .frame(width: 60, height: 60)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .background(Color.white
                                    .opacity(0.75))
                    .cornerRadius(30)
                    .padding(10)
            }
            Button(action: {
                print("Confirm")
                self.modelConfirmedForPlacement = self.selectedModel
                self.resetPlacementParams()
            }) {
                Image(systemName: "checkmark")
                    .frame(width: 60, height: 60)
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .background(Color.white
                                    .opacity(0.75))
                    .cornerRadius(30)
                    .padding(10)
            }
        }.padding(10).padding(.top, 620)
    }
    func resetPlacementParams() {
        self.isPlacementEnabled = false
        self.selectedModel = nil
    }
}

struct ElementPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    
    var models: [Model]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false, content: {
            HStack(spacing: 5) {
                ForEach(0 ..< self.models.count) {
                    index in
                    Button(action: {
                        self.selectedModel = self.models[index]
                        self.isPlacementEnabled = true
                    }) {
                        Image(uiImage: self.models[index].image)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1, contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(12)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }).padding(10).padding(.top, 620)
    }
}

struct NavigationMenu: View {
    @Binding var captureScene: Bool
    @Binding var clearScreen: Bool
    @Binding var index: String
    @Binding var isDesignModeEnable: Bool
    @Binding var isPlacementEnabled: Bool
    var body: some View {
        HStack(alignment: .top) {
            Button(action: {
                self.captureScene = true
            }) {
                Spacer()
                Image(systemName: "camera.circle")
                    .resizable()
                    .frame(width: 40, height: 38)
                    .background(Color.clear)
            }.buttonStyle(PlainButtonStyle())
        }.padding(.bottom, 690)
        .padding(.horizontal, 120)
        
        HStack(alignment: .top) {
            Button(action: {
                self.clearScreen = true
            }) {
                Spacer()
                Image(systemName: "arrow.uturn.backward.circle")
                    .resizable()
                    .frame(width: 40, height: 38)
                    .background(Color.clear)
            }.buttonStyle(PlainButtonStyle())
        }.padding(.bottom, 690)
        .padding(.horizontal, 70)
        
        HStack(alignment: .top) {
            Button(action: {
                self.isDesignModeEnable = true
                self.isPlacementEnabled = false
                self.index = "History"
            }) {
                Spacer()
                Image(systemName: "text.justify")
                    .resizable()
                    .frame(width: 32, height: 29)
                    .background(Color.clear)
            }.buttonStyle(PlainButtonStyle())
        }.padding(.bottom, 690)
        .padding(.horizontal, 25)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
