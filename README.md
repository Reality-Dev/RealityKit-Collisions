#  Collision-Filters

This is a convenience API for setting Collision Filters in RealityKit. 

## Discussion

Collision Filters determine what group an entity belongs to, and what groups of entities it can collide with. 
This package creates a convenient way to generate and assign these groups, instead of just using a CollisionFilter of ".default" or ".sensor" which collide with everything.

## Minimum Requirements
  - Swift 5.2
  - iOS 13.0 (RealityKit)
  - Xcode 11
  
  ## Installation

  ### Swift Package Manager

  Add the URL of this repository to your Xcode 11+ Project.

  Go to File > Swift Packages > Add Package Dependency, and paste in this link:

`https://github.com/Reality-Dev/RealityKit-Collisions`


## Example
See the [Example](./RealityKit-Collisions-Example) for a full working example.

In AR: Tap or swipe on the big rubber ball to watch it collide with only the green aliens and not the teammates.
If you run this app on a LiDAR-enabled device, the entities will also collide with the scene mesh.




## Usage

- After installing, import `CollisionFilters` to your .swift file

If you want to run code when collision events occur, [see this article](https://realitydev.medium.com/realitykit-easier-collision-groups-818b07508c4c)


- To allow you to add your own custom collision groups you must first define them:
Copy and paste this enum in the global scope (not contained within a class, struct, etc.) and replace the case names with the collision groups you want to have in your own app. You could make one like this if you wanted to have "teammate" and "alien" groups:
``` swift
    public enum MyCustomCollisionGroups: String, CaseIterable {
        case teammates, aliens
    }
```
This works for up to 32 different groups.


Next, as shown in the example, your project must contain a class that you have conformed to the `HasCollisionGroups` protocol, such as this one:
   `class ViewController: UIViewController, HasCollisionGroups {}`
This class must now refer to the enum that you just made, like this:
`typealias CollisionGroupsEnum = MyCustomCollisionGroups`

This YouTube video shows the steps in practice: 


 Next, call either the "setNewCollisionFilter()" function or the "returnNewCollisionFilter()" function on any entity that you want to use it on.
 Here is an example:
 
 ``` swift
 class ViewController: UIViewController {
 
    let myBalloon = ModelEntity()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNewCollisionFilter(thisEntity: aliensScene.alien1!,
                              belongsToGroup: .aliens,
                              andCanCollideWith: [.aliens, .bigRubbberBall, .ground])
    }
}
```
^Now the "alien1" entity belongs to the group "aliens" and can collide with entities that have been explicitly placed inside of the "aliens," "bigRubbberBall," and "ground" groups.

- Note: groups do not automatically collide with their own group. For example, one balloon does not automatically collide with another balloon unless the "balloons" group was specified as part of the "canCollideWith" array.

- Note: an entity does not automatically belong to any group. For example, if you make a wall entity and name it "wall," you must still call --  wall.setNewCollisionFilter(myGroup: .walls, canCollideWith: [ ])   -- in order to add the wall entity to the "walls" group.

- Note: If an entity does not have a CollisionComponent, then setNewCollisionFilter() will automatically add one to the entity for you, recursively generating collision shapes for all descendants of the entity as well.


To allow the entity to collide with the scene mesh on Lidar-enabled devices:
Option A:
     Call this method AFTER calling setNewCollisionFilter() if you intend on calling both methods.
     `addCollisionWithLiDARMesh(on entity: Entity)`
 Option B:
     Include a group in your enum spelled exactly as "sceneMesh" like this:
``` swift
         public enum MyCustomCollisionGroups: String, CaseIterable {
             case sceneMesh, teammates, aliens
         }
```
And then use that sceneMesh group in the `setNewCollisionFilter` method just like any other group, like this:
``` swift
    setNewCollisionFilter(thisEntity: boxAnchor.steelBox!, belongsToGroup: .teammates, andCanCollideWith: [.sceneMesh, .aliens])
```
Then, copy and paste the `runLiDARConfiguration()` function from the example project into your project and call it.



`returnNewCollisionFilter` Does Not set a filter on an entity, but it returns a filter. This is useful when you want to use a custom shape and mode on your `CollisionComponent`. It is inserted into the CollisionComponent initializer as the "filter:" parameter.
Here is an example:
``` swift
let newCollisonFilter = returnNewCollisionFilter(belongsToGroup: .teammates,
                                                 andCanCollideWith: [.aliens, .ground,.bigRubbberBall])
let newCollisionComponent = CollisionComponent(shapes: [ShapeResource.generateBox(size: .one)],
                   mode: .trigger,
                   filter: newCollisonFilter)
myEntity.components[CollisionComponent.self] = newCollisionComponent
```


If anything is unclear, please [send me a tweet](https://twitter.com/gmj4k)

If you see a way things can be done better please feel free to contribute by making a fork & pull request.
