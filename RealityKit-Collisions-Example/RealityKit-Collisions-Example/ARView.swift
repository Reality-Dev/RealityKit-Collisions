//
//  ARView.swift
//  Sound Localization
//
//  Created by Grant Jarvis on 2/8/21.
//

import ARKit
import RealityKit
import Combine
//import CollisionFilters


public enum CollisionGroups: String, CaseIterable {
    case teammates, aliens, bigRubbberBall, ground
}


class ARSUIView: ARView, HasCollisionGroups {
    
    typealias CollisionGroupsEnum = CollisionGroups
    
    var dataModel : DataModel
    
    var aliensScene : Aliens.Scene!
    
    var cameraAnchor = AnchorEntity(.camera)
    
    
    required init(frame frameRect: CGRect, dataModel: DataModel) {
        self.dataModel = dataModel
        super.init(frame: frameRect)
        self.session.delegate = self
        loadSceneAsyncronously()
        installSwipeGestures()
        self.scene.addAnchor(cameraAnchor)
        
        //If this device has LiDAR, then allow entities to collide with the LiDAR mesh.
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            runLiDARConfiguration()
        }
    }
    
    
    func sceneDidLoad(){
        
        guard let groundPlane = aliensScene.findEntity(named: "Ground Plane") else {return}


        
        setNewCollisionFilter(thisEntity: groundPlane,
                              belongsToGroup: .ground,
                              andCanCollideWith: [.aliens, .bigRubbberBall, .teammates])
        
        setNewCollisionFilter(thisEntity: aliensScene.alien1!,
                              belongsToGroup: .aliens,
                              andCanCollideWith: [.aliens, .bigRubbberBall, .ground])
        
        setNewCollisionFilter(thisEntity: aliensScene.alien2!,
                              belongsToGroup: .aliens,
                              andCanCollideWith: [.aliens, .bigRubbberBall, .ground])
        
        //--//
        //Teammates do Not get run over by the ball, but aliens do.
        setNewCollisionFilter(thisEntity: aliensScene.teammate1!,
                              belongsToGroup: .teammates,
                              andCanCollideWith: [.ground])
        
        setNewCollisionFilter(thisEntity: aliensScene.teammate2!,
                              belongsToGroup: .aliens,
                              andCanCollideWith: [.ground])
        
        //--//
        setNewCollisionFilter(thisEntity: aliensScene.bigRubberBall!,
                              belongsToGroup: .bigRubbberBall,
                              andCanCollideWith: [.ground, .aliens])
        addCollisionListening(onEntity: aliensScene.bigRubberBall as! Entity & HasCollision)
        
        //If this device has LiDAR, then allow entities to collide with the LiDAR mesh.
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            //Add delay to give the device time to generate the mesh.
            DispatchQueue.main.asyncAfter(deadline: .now() + 5){
                let sceneEntities = [self.aliensScene.alien1!,
                                     self.aliensScene.alien2!,
                                     self.aliensScene.teammate1!,
                                     self.aliensScene.teammate2!,
                                     self.aliensScene.bigRubberBall!]
                sceneEntities.forEach { sceneEntity in
                    self.addCollisionWithLiDARMesh(on: sceneEntity)
                }
            }

        }
    }
    
    
    
    func installSwipeGestures(){
        let directions : [UISwipeGestureRecognizer.Direction] = [
            .up, .down, .left, .right]
        directions.forEach { direction in
            let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
            swipeGestureRecognizer.direction = direction
            self.addGestureRecognizer(swipeGestureRecognizer)
        }
    }
    
    
   @objc func swiped(_ recognizer: UISwipeGestureRecognizer){
        guard let bigRubberBall = aliensScene.bigRubberBall as? (Entity & HasPhysics) else {return}
        var impulse = SIMD3<Float>()
        switch recognizer.direction {
        case .up:
            impulse = [0,0,-1000]
        case .down:
            impulse = [0,0,1000]
        case .left:
            impulse = [-1000,0,0]
        case .right:
            impulse = [1000,0,0]
        default:
            break
        }
        bigRubberBall.applyLinearImpulse(impulse, relativeTo: cameraAnchor)
    }
    
    
    
    
    
    
    
    
    
    
    
    var collisionSubscriptions = [Cancellable]()
    func addCollisionListening(onEntity entity: Entity & HasCollision) {
        collisionSubscriptions.append(self.scene.subscribe(to: CollisionEvents.Began.self, on: entity) { event in
            
            //Place code here for when the collision begins.
           print(event.entityA.name, "collided with", event.entityB.name)
        })
        collisionSubscriptions.append(self.scene.subscribe(to: CollisionEvents.Ended.self, on: entity) { event in
            
            //Place code here for when the collision ends.
        })
    }
    
    
    func runLiDARConfiguration(){
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.sceneReconstruction = .mesh
        self.session.run(configuration)
        self.environment.sceneUnderstanding.options.insert(.physics)
        //self.debugOptions.insert(.showSceneUnderstanding) //show colored mesh.
    }
    
    
    func loadSceneAsyncronously(){
        // Load the scene from the Reality File, checking for any errors
        Aliens.loadSceneAsync {[weak self] result in
            switch result{
            case .failure (let error):
                print("Unable to load the scene with error: ",
                      error.localizedDescription)
            case .success(let sceneAnchor):
                //add the anchor to the scene
                print("Scene Loaded Asyncronously")
                self?.aliensScene = sceneAnchor
                self?.scene.addAnchor(sceneAnchor)
                self?.sceneDidLoad()
            }
        }
    }
    
    //required function.
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
}


// MARK: - ARSessionDelegate

extension ARSUIView: ARSessionDelegate {
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        //Code here
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        //Code here
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        //Code here
    }
    
    
    
}
