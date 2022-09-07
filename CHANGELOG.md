## 1.6.0

- ```MAJNode.breadthFirstToArray```
    - returns an array of references to the nodes in the directory
    - stored in breadth first order
    - can be converted to json, and saved
        - format used by ```MAJNode.fromJson```

## 1.5.0

- added ```MAJNode.getRoot```
    - returns the root of the entire tree, which the current node is part of

## 1.4.0

- made ```MAJNode._nameNotValidCheck``` public and static
    - renamed the function to ```MAJNode.validName```
- added ```MAJNode.move```
    - allows you to move the current node
    - current node becomes a child of the node with the passed path
- ```MAJNode.addChild``` checks for existing parent of added child and removes parent's reference if
  it exists

## 1.3.0

- added ```MAJNode.inorderSearchBy```
    - allows a breadth first search from a node using a custom function defined by the developer
- increased documentation
- added ```MAJNode.inorderSearchByName```
    - ```MAJNode.inorderSearchBy``` with a function that searches by node name
- optimization of code, and bug fixes
- added ```MAJNode.remove```
    - removes the current, and children from node from ```MAJProvider.map```

## 1.2.0

- added more documentation
- deprecated ```MAJNode.breadthFirstSearch```
    - can get nodes by path O(1) using ```MAJProvider.map```
    - ```MAJNode.breadthFirstSearch``` is O(n)
- add ```MAJNode``` to ```MAJProvider.map``` in ```MAJNode``` constructors
    - this way the root will be in ```MAJProvider.map```
    - by default if there is a root node with the same name it will be overwritten in the map
        - if safeAddToMap == true in constructor an error will be thrown if a entry in the map is to
          be overwritten when adding the node
- fixed removing existing ```MAJProvider.map``` entries in ```MAJNode.addChild```

## 1.1.0

- added ```MAJProvider.map```
    - allows referencing nodes by path O(1) instead of O(n)
    - ```MAJProvider.addToMap```
    - ```MAJProvider.removeFromMap```
- ```MAJProvider.navigateTo```
    - when called now runs in ```MAJBuilder```
        - O(1) instead of O(n)
        - because uses ```MAJProvider.map``` now
- added name format check to ```MAJNode.removeChild```
    - throws error if invalid name format passed
- ```MAJNode.addChild``` and ```MAJNode.rename``` add to ```MAJProvider.map```
- ```MAJNode.removeChild``` removes from ```MAJProvider.map```

## 1.0.0

- ```MAJProvider.navigateToByNode```
    - allows navigation by a passed node reference
    - navigation can now be O(1)
- ```MAJDirectory``` now navigates by node
    - was O(n)
    - now O(1)
- added custom item example to example
- removed ```Map<String, dynamic>? data``` from ```MAJItemInterface```,
  and ```MAJNode.definitions``` functions
    - data should be referenced from ```nodeReference.data```
    - this change could break existing code
- fixed example ```pubspec.yaml```
- added ```MAJNode.addDefinition```
    - allow safe adding of definitions
- made ```MAJDirectory``` look slightly nicer

## 0.0.2

- fixed ```MAJNode.breadthFirstTraversal```
    - wasn't outputting node paths
- Updated ```MAJNode.fromJson```
    - made more efficient
        - no longer O(n^2)
        - now O(2n)
        - uses a queue similar to a breadth first traversal
            - https://en.wikipedia.org/wiki/Breadth-first_search
- determined json storage method is ok
    - all nodes in a single array
        - ordered left to right top to bottom (breadth first)
- needs optimization:
    - determining which node to build
        - always starts from the root

## 0.0.1

- basic version
- can:
    - build a tree
    - save tree to json
    - rebuild tree from json
    - navigate in GUI using the directories obj
- needs optimization:
    - storage as json
    - building from json
    - needs something like a hash map to allow on the order of 1 operations to access nodes by path