//
//  FocusARView.swift
//  GlassWall-SwiftUI
//
//  Created by Jeremiasz Jaworski on 19/12/2020.
//

import RealityKit
import FocusEntity
import Combine
import ARKit
import UIKit

class FocusARView: ARView {
  var focusEntity: FocusEntity?
  required init(frame frameRect: CGRect) {
    super.init(frame: frameRect)
    self.setupConfig()
    self.focusEntity = FocusEntity(on: self, focus: .classic)
    self.focusEntity?.delegate = self
  }

  func setupConfig() {
    let config = ARWorldTrackingConfiguration()
    config.planeDetection = [.horizontal, .vertical]
    config.environmentTexturing = .automatic
    
    
    if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
        config.sceneReconstruction = .mesh
    }
    
    session.run(config, options: [])
  }

  @objc required dynamic init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension FocusARView: FocusEntityDelegate {
  func toTrackingState() {
    
    print("tracking")
  }
  func toInitializingState() {
    print("initializing")
  }
}
