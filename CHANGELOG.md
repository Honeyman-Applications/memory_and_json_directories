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