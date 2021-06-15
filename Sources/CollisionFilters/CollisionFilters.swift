//
//  Entity Extension.swift
//  CollisionFilters
//
//  Created by Grant Jarvis on 8/19/20.
//  Copyright © 2020 Grant Jarvis. All rights reserved.
//


 
import RealityKit


public protocol HasCollisionGroups : AnyObject {

    associatedtype CollisionGroupsEnum: RawRepresentable, CaseIterable where CollisionGroupsEnum.RawValue: StringProtocol
}


@available(iOS 13.0, *)
public extension HasCollisionGroups{
 
/**
     Automatically sets the new filter on the current CollisionComponent, or adds a CollisionComponent with the new filter if there is not one.
     
     For any of your groups that include the word "scene" or "Scene," they will automatically be treated as the .sceneUnderstanding CollisionGroup, which refers to the scene mesh for Lidar-enabled devices.
     - Parameters:
        - myGroup: The group this entity belongs to.
        - canCollideWith: The other groups that this entity can collide with.
 */
    func setNewCollisionFilter(thisEntity entity: Entity, belongsToGroup myGroup: CollisionGroupsEnum, andCanCollideWith otherGroups: [CollisionGroupsEnum]){

        let filter = returnNewCollisionFilter(belongsToGroup: myGroup, andCanCollideWith: otherGroups)
        
        var myCollisionComponent = entity.components[CollisionComponent.self] as? CollisionComponent
        if myCollisionComponent == nil {
            print(entity.name, "did Not have a collision Component...generating one.")
            
            entity.components.set(CollisionComponent(shapes: []))
            //The method stores the shape in the entity’s CollisionComponent instance.
            //generates shapes for descendants as well.
            entity.generateCollisionShapes(recursive: true)
            
            myCollisionComponent = entity.components[CollisionComponent.self] as? CollisionComponent
        }
        myCollisionComponent?.filter = filter
        entity.components[CollisionComponent.self] = myCollisionComponent
    }
    
    

/**
     Returns a new CollisionFilter, but does Not set it on an entity.
     
     This is useful for inserting into CollisionComponent initializer as the "filter:" parameter when more customization is needed, such as using a custom shape and mode.
     - Parameters:
        - myGroup: The group this filter belongs to.
        - canCollideWith: The other groups that this filter can collide with.
 */
     func returnNewCollisionFilter(belongsToGroup myGroup: CollisionGroupsEnum, andCanCollideWith otherGroups: [CollisionGroupsEnum]) -> CollisionFilter{
        
        let group = makeNewGroup(category: myGroup)
        
        let mask = makeNewMask(otherGroups: otherGroups)
        
        let filter = CollisionFilter(group: group, mask: mask)
        
        return filter
    }
    
/**
     Allows the entity to collide with the scene mesh on Lidar-enabled devices
     
     Call this method AFTER calling setNewCollisionFilter() if you intend on calling both methods.
     */
    func addCollisionWithLiDARMesh(on entity: Entity){
        var myCollisionComponent = entity.components[CollisionComponent.self] as? CollisionComponent
        if myCollisionComponent == nil {
            print(entity.name, "did Not have a collision Component...generating it.")
            
            entity.components.set(CollisionComponent(shapes: []))
            //The method stores the shape in the entity’s CollisionComponent instance.
            //generates shapes for descendants as well.
            entity.generateCollisionShapes(recursive: true)
            
            myCollisionComponent = entity.components[CollisionComponent.self] as? CollisionComponent
        }
        guard #available(iOS 13.4, *) else {
            print("sceneUnderstanding only available on iOS 13.4 or newer")
            return
        }
        myCollisionComponent?.filter.mask.formUnion(.sceneUnderstanding)
        entity.components[CollisionComponent.self] = myCollisionComponent
    }
    
    
    
    private func makeNewGroup(category: CollisionGroupsEnum) -> CollisionGroup{
        let groupNumber = findGroupNumber(category: category)
        let newGroup = CollisionGroup.init(rawValue: groupNumber!)
        return newGroup
    }
    
    private func findGroupNumber(category: CollisionGroupsEnum) -> UInt32?{
        guard let integerIndex = CollisionGroupsEnum.allCases.firstIndex(where: {$0 == category}) as? Int else {return nil}
            //This gives 2^integerIndex
            //Use only UInt32's that have only one "1" bit in them to make life easier.
            var groupNumber = UInt32(1 << integerIndex)

        //support Scene Understanding.
        if category.rawValue.contains("sceneMesh") {
            if #available(iOS 13.4, *) {
                groupNumber = CollisionGroup.sceneUnderstanding.rawValue
                //2147483648
                //The raw value for the .sceneUnderstanding CollisionGroup
            } else {
                print("sceneUnderstanding only available on iOS 13.4 or newer")
            }
        }
        return groupNumber
    }
    
    
    private func makeNewMask(otherGroups: [CollisionGroupsEnum]) -> CollisionGroup{
        var mask = UInt32()
        for category in otherGroups {
            mask += findGroupNumber(category: category)!
        }
        return CollisionGroup(rawValue: mask)
    }
    
    
}




