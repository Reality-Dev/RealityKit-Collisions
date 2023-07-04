#  RealityKit-Collisions

This is a convenience API for setting Collision Filters in RealityKit. 


![RealityKitCollisions Example 1](media/CollisionFilters.gif)

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

[This YouTube video](https://youtu.be/Pit-Dn8WvN8) is out of date and applies only to the versions of this package before 3.0.0

- After installing, import `RealityKitCollisions` to your .swift file

If you want to run code when collision events occur, [see this article](https://realitydev.medium.com/realitykit-easier-collision-groups-818b07508c4c)


- To allow you to add your own custom collision groups you must first define them:
Copy and paste this enum in the global scope (not contained within a class, struct, etc.) and replace the case names with the collision groups you want to have in your own app. You could make one like this if you wanted to have "teammates" and "aliens" groups:
``` swift
    public enum MyCustomCollisionGroups: String, CaseIterable {
        case teammates, aliens
    }
```
This works for up to 32 different groups.

 Next, call the "setNewCollisionFilter()" function for any entity that you want to use it on.
 Here is an example:
 
 ``` swift
 class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aliensScene.alien1!.setNewCollisionFilter(
                              belongsToGroup: CollisionGroups.aliens,
                              andCanCollideWith: [.aliens, .bigRubbberBall, .ground])
    }
}
```

^Now the "alien1" entity belongs to the group "aliens" and can collide with entities that have been explicitly placed inside of the "aliens," "bigRubbberBall," and "ground" groups.

In order for Swift to infer the type of your collision groups enum, you must specify the type name of your custom collision groups enum at least once in the parameters of the function.
i.e. This is why the above parameter was passed in this way:
        `belongsToGroup: CollisionGroups.aliens`
    and not this way:
        `belongsToGroup: .aliens`.
Because this was written as `CollisionGroups.aliens`, swift now knows that `CollisionGroups` is the enum that defines your custom collision groups.
Notice, for convenience, how the other input paramters do *not* have to specify the enum type:
     `andCanCollideWith: [.aliens, .bigRubbberBall, .ground]`
     
## Important:

- Be sure to only define *ONE* collision groups enum. i.e. Creating multiple different enums and passing them to different calls of `.setNewCollisionFilter(belongsToGroup:,
                              andCanCollideWith:)` will cause unexpected results.

- Note: groups do not automatically collide with their own group. For example, one balloon does not automatically collide with another balloon unless the "balloons" group was specified as part of the "andCanCollideWith" array.

- Note: an entity does not automatically belong to any group. For example, if you make a wall entity and name it "wall," you must still call  `wall.setNewCollisionFilter(belongsToGroup: .walls, andCanCollideWith: [])` in order to add the wall entity to the "walls" group.

- Note: If an entity does not already have a CollisionComponent, then `setNewCollisionFilter()` will automatically add one to the entity for you, recursively generating collision shapes for all descendants of the entity as well.


## To allow the entity to collide with the scene mesh on Lidar-enabled devices:
### Option A:
     // Call this method AFTER calling setNewCollisionFilter() if you intend on calling both methods.
     `myEnt.addCollisionWithLiDARMesh()`
 
 ### Option B:
     Include a group in your enum spelled exactly as "sceneMesh" like this:
``` swift
         public enum MyCustomCollisionGroups: String, CaseIterable {
             case sceneMesh, teammates, aliens
         }
```
And then use that sceneMesh group in the `setNewCollisionFilter` method just like any other group, like this:
``` swift
        boxAnchor.steelBox!.setNewCollisionFilter(belongsToGroup: CollisionGroups.teammates, andCanCollideWith: [.sceneMesh, .aliens])
```
Using either option, copy and paste the `runLiDARConfiguration()` function from the example project into your project and call it.
This is how you check if the user is on a LiDAR-enabled device:
``` swift
if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
   runLiDARConfiguration()
}
```



`CollisionComponent.makeCollisionFilter` Does Not set a filter on an entity, but it returns a filter. This is useful when you want to use a custom shape and mode on your `CollisionComponent`. The returned filter is then inserted into the `CollisionComponent` initializer as the "filter:" parameter.
Here is an example:
``` swift
let newCollisonFilter = CollisionComponent.makeCollisionFilter(belongsToGroup: CollisionGroups.teammates,
                                                 andCanCollideWith: [.aliens, .ground,.bigRubbberBall])
let newCollisionComponent = CollisionComponent(shapes: [ShapeResource.generateBox(size: .one)],
                   mode: .trigger,
                   filter: newCollisonFilter)
myEntity.components[CollisionComponent.self] = newCollisionComponent
```


## More

If anything is unclear, please [send me a tweet](https://twitter.com/gmj4k)

Please feel free to contribute by making a fork & pull request.
