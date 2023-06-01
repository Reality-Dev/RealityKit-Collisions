//
//  Model.swift
//  Drawing Test
//
//  Created by Grant Jarvis on 1/30/21.
//

import Combine
import RealityKit
import SwiftUI

final class DataModel: ObservableObject {
    static var shared = DataModel()

    
    @Published var showingAlert = false {
        didSet{
            print("showingAlert:", showingAlert)
        }
    }
    @Published var arView : ARSUIView!

    
    
    
    init(){
       arView = ARSUIView(frame: .zero, dataModel: self)
    }
}

