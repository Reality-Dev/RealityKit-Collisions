//
//  Entity Extension.swift
//  CollisionFilters
//
//  Created by Grant Jarvis on 8/19/20.
//  Copyright © 2020 Grant Jarvis. All rights reserved.
//
 
import RealityKit
import RKUtilities

public protocol HasCollisionGroups: RawRepresentable & CaseIterable where RawValue == Int {}

@available(iOS 13.0, macOS 10.15, *)
public extension Entity {
    
    /**
     Automatically sets the new filter on the current CollisionComponent, or adds a CollisionComponent with the new filter if there is not one.
     
     For any of your groups that include the word "scene" or "Scene," they will automatically be treated as the .sceneUnderstanding CollisionGroup, which refers to the scene mesh for Lidar-enabled devices.
     - Parameters:
     - myGroup: The group this entity belongs to.
     - canCollideWith: The other groups that this entity can collide with.
     */
    func setNewCollisionFilter<CollisionGroupsEnum: HasCollisionGroups>(belongsToGroup myGroup: CollisionGroupsEnum,
                                                                                     andCanCollideWith otherGroups: Set<CollisionGroupsEnum>)
    {
        
        let filter = CollisionComponent.makeCollisionFilter(belongsToGroup: myGroup, andCanCollideWith: otherGroups)
        
        var myCollisionComponent = getCollisionComp()
        
        myCollisionComponent?.filter = filter
        components[CollisionComponent.self] = myCollisionComponent
    }
    
    private func getCollisionComp() -> CollisionComponent? {
        func generateCollisionComp() -> CollisionComponent? {
            print(name, "did Not have a collision Component...generating it.")
            
            components.set(CollisionComponent(shapes: []))
            //The method stores the shape in the entity’s CollisionComponent instance.
            //generates shapes for descendants as well.
            generateCollisionShapes(recursive: true)
            
            return component(forType: CollisionComponent.self)
        }
        let existingCollisionComp = component(forType: CollisionComponent.self)
        if existingCollisionComp == nil { print(name, "did Not have a collision Component...generating one.") }
        return existingCollisionComp ?? generateCollisionComp()
    }
    
    /**
         Allows the entity to collide with the scene mesh on Lidar-enabled devices
         
         Call this method AFTER calling setNewCollisionFilter() if you intend on calling both methods.
         */
        func addCollisionWithLiDARMesh(){
            var myCollisionComponent = getCollisionComp()
            
            guard #available(iOS 13.4, *) else {
                print("sceneUnderstanding only available on iOS 13.4 or newer")
                return
            }
            myCollisionComponent?.filter.mask.formUnion(.sceneUnderstanding)
            
            components[CollisionComponent.self] = myCollisionComponent
        }
    
    func removeCollisionsWith<CollisionGroupsEnum: HasCollisionGroups>(otherGroups: Set<CollisionGroupsEnum>)
    {
        guard var myCollisionComponent = component(forType: CollisionComponent.self) else {return}
        
        var mask = myCollisionComponent.filter.mask
        
        mask = mask.subtracting(CollisionComponent.makeNewMask(otherGroups: otherGroups))
        
        myCollisionComponent.filter.mask = mask
        
        components.set(myCollisionComponent)
    }
    
    /// NOTE: You must give the Entity a `CollisionComponent` and a `CollisionGroup` to belong to BEFORE calling this method. Using`Entity.setNewCollisionFilter` will accomplish this.
    func addCollisionsWith<CollisionGroupsEnum: HasCollisionGroups>(otherGroups: Set<CollisionGroupsEnum>)
    {
        guard var myCollisionComponent = component(forType: CollisionComponent.self) else {return}
        
        var mask = myCollisionComponent.filter.mask
        
        mask = mask.union(CollisionComponent.makeNewMask(otherGroups: otherGroups))
        
        myCollisionComponent.filter.mask = mask
        
        components.set(myCollisionComponent)
    }
}

public extension CollisionComponent {
    
/**
     Returns a new CollisionFilter, but does Not set it on an
     
     This is useful for inserting into CollisionComponent initializer as the "filter:" parameter when more customization is needed, such as using a custom shape and mode.
     - Parameters:
        - myGroup: The group this filter belongs to.
        - canCollideWith: The other groups that this filter can collide with.
 */
    static func makeCollisionFilter<CollisionGroupsEnum: HasCollisionGroups>(belongsToGroup myGroup: CollisionGroupsEnum, andCanCollideWith otherGroups: Set<CollisionGroupsEnum>) -> CollisionFilter
      {
        
        let group = makeNewGroup(category: myGroup)
        
        let mask = makeNewMask(otherGroups: otherGroups)
        
        let filter = CollisionFilter(group: group, mask: mask)
        
        return filter
    }
    
    
    static func makeNewGroup<CollisionGroupsEnum: HasCollisionGroups>(category: CollisionGroupsEnum) -> CollisionGroup {
        let groupNumber = findGroupNumber(category: category)
        let newGroup = CollisionGroup.init(rawValue: groupNumber)
        return newGroup
    }
    
    static fileprivate func findGroupNumber<CollisionGroupsEnum: HasCollisionGroups>(category: CollisionGroupsEnum) -> UInt32 {
            //This gives 2^integerIndex
            //Use only UInt32's that have only one "1" bit in them to make life easier.
        var groupNumber = UInt32(1 << category.rawValue)

        //support Scene Understanding.
        if String(describing: category) == "sceneMesh" {
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
    
    
    static func makeNewMask<CollisionGroupsEnum: HasCollisionGroups>(otherGroups: Set<CollisionGroupsEnum>) -> CollisionGroup {
        var mask = UInt32()
        for category in otherGroups {
            mask += findGroupNumber(category: category)
        }
        return CollisionGroup(rawValue: mask)
    }
    
    static func categoryFromGroupNumber<CollisionGroupsEnum: HasCollisionGroups>(groupNumber: UInt32) -> CollisionGroupsEnum? {
        // Ensure the groupNumber has only one "1" bit (is a power of 2)
        guard groupNumber != 0 && groupNumber & (groupNumber - 1) == 0 else {
            return nil // Not a valid group number (not a power of 2)
        }
        
        let rawValue = groupNumber.trailingZeroBitCount
        return CollisionGroupsEnum(rawValue: rawValue)
    }
    
    struct CollidingGroups<T: HasCollisionGroups> {
        public let groupA: T
        public let groupB: T
    }
    
    static func fetchCollisionGroups<T: HasCollisionGroups>(from event: CollisionEvents.Began, of type: T.Type) -> CollidingGroups<T>? {
        func collisionGroup(_ entity: Entity) -> T? {
            let collisionComponent = entity.component(forType: CollisionComponent.self)

            guard let groupRaw = collisionComponent?.filter.group.rawValue else {return nil}
            return CollisionComponent.categoryFromGroupNumber(groupNumber: groupRaw)
        }
        
        let entityA = event.entityA
        let entityB = event.entityB
        
        guard
            let groupA = collisionGroup(entityA),
            let groupB = collisionGroup(entityB)
        else {return nil}
        
        return CollidingGroups(groupA: groupA, groupB: groupB)
    }
}

