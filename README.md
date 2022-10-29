# memory_and_json_directories

A Flutter package, with a platform independent directory structure, which can be saved as JSON. This package is an implmentation of a [general tree](https://opendsa-server.cs.vt.edu/OpenDSA/Books/CS3/html/GenTreeIntro.html).

## Please Post Questions on StackOverflow, and tag @CatTrain (user:16200950)

<https://stackoverflow.com/>

## ```MAJNode``` naming rules

- ```MAJNode.name``` must match the following [regex](https://en.wikipedia.org/wiki/Regular_expression) expression: ```^[a-zA-Z0-9_]+( [a-zA-Z0-9_]+)*$```
- each name must be unique amoungst its peers
  - when new nodes are added their name can not match a root node's name in their tree, because before they are added to another node as a child, they are a peer of all root nodes
  - These rules are scoped to within the ```MAJProvider.maps``` map the nodes are referenced in

## ```MAJBuilder```

- This is the widget used to display your tree in memory
- makes user of [Provider](https://pub.dev/packages/provider) to recive change notifications from ```MAJProvider```
  - this is how the widget knows which ```MAJNode``` to display
- This widget takes two parameters
- ```required MAJNode root```
  - The node you wish to have displayed first when the widget builds
  - This is typlically the root of the tree
- ```String mapKey = MAJProvider.defaultMapKey```
  - the key you use to reference the map of nodes
  - don't set if you only intend to have one tree
  - set if you wish to have more than one tree in memory at once

## ```MAJProvider```

- The [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) that nofifies ```MAJBuilder``` to display a ```MAJNode```
- Only exists in memory
- ```static const defaultMapKey = "default";```
  - the default map key used in ```MAJProvider.maps```
- ```static Map<String, Map<String, MAJNode>> maps```
  - The outer map references a unique key for each tree
    - if there is only one tree the default map key is used
  - If there is to be more than one tree in memory at a time, ensure each tree has a key in the outer map
  - The inner maps contain the path of each node in the tree, and a memory reference to that node, so any node can be accessed O(1)
- ```MAJNode``` references can be added and removed manually to ```MAJProvider.maps```, but it is not recommended
  - ```static void addToMap```
  - ```static MAJNode? removeFromMap```
- allows navigatio to ```MAJNode``` by path or reference
  - by path
    - ```navigateTo```
      - uses map key provided by ```MAJBuilder``` to determine, which tree the node is in
      - ex: ```context.read<MAJProvider>().navigateTo("/root/node");```
  - by ```MAJNode``` reference
    - ```navigateToByNode```
      - navigates to the node regardless of which tree it is in
      - ex: ```context.read<MAJProvider>().navigateToByNode(myNode);```

## Storage

- ### Memory Storage

  - The directory is stored as a [general tree](https://opendsa-server.cs.vt.edu/OpenDSA/Books/CS3/html/GenTreeIntro.html)
  - All nodes have access to ```MAJNode.sharedData```
    - ```static Map<String, Map<String, dynamic>> sharedData```
    - Outer map
      - keys refer to mapKey used by MAJProvider.maps to differentiate between trees in memory
      - the keys in the outer map must match the ones used in ```MAJProvider.maps```
    - Inner maps implements ```MAJItemInterface```
      - keys must be a type name of a item that
      - the data is any json serializable data
      - can be applied to all nodes of that type in the same tree
        - tree differentiated using outer map
  - Each node has
    - ```name```
      - a ```String``` that is the name of the node
      - must follow ```MAJNode``` naming rules above
    - ```path```
      - a ```String``` that contains the node's name and the name of all it's ancestors
      - must be unique amongst all nodes in the tree
    - ```parent```
      - a reference to the node which is this node's parent
      - if ```null``` this means the node is a root node
    - ```children```
      - array of nodes which are the children of the node
      - if the array is empty the node has no children
    - ```typeName```
      - a ```String```, which is used to determine which definition to use when building the node from json
    - ```child```
      - an ```object```, which implments ```MAJItemInterface```
      - the object builds a widget when it's ```build``` method is called by the node
    - ```data```
      - A ```Map<String, dynamic>```
      - stores data required to build the node's child
      - can be ```null``` if not required
      - must be able to convert to a JSON object
        - number, boolean, string, null, list or a map with string keys
    - ```mapKey```
      - a ```String``` that identifies, which tree the node belongs to
      - must match a key used in ```MAJProvider.maps``` outer map

- ### JSON storage

  - The directory is stored as an object with nodes and shared data.
    - ```sharedData```
      - a map containing data shared within each tree
      - see ```MAJNode.sharedData``` in memory storage
    - ```nodes```
      - an array of json objects stored in in left to right, top to bottom order ([breadth first](https://en.wikipedia.org/wiki/Breadth-first_search))
      - Each node in the array has:
        - ```name```
          - see ```name``` in memory storage
        - ```path```
          - see ```path``` in memory storage
        - ```typeName```
          - see ```typeName``` in memory storage
        - ```parent```
          - the path of the current node's parent
          - if is empty the node is a root node
        - ```data```
          - a JSON object contaning the data required to build the node
          - see ```data``` in memory storage
        - ```mapKey```
          - see ```mapKey``` in memory storage
  - ex: ```{"nodes":[{"name":"root","path":"/root","parent":"","typeName":"maj_directory","mapKey":"default","data":{}}],"sharedData":{}}```

## References

- [JSON](https://en.wikipedia.org/wiki/JSON)
- [memory](https://en.wikipedia.org/wiki/Computer_memory)
- [Semantic Versioning 2.0.0](https://semver.org/)
- [breadth first](https://en.wikipedia.org/wiki/Breadth-first_search)
- [general tree](https://opendsa-server.cs.vt.edu/OpenDSA/Books/CS3/html/GenTreeIntro.html)
- [big O notation](https://en.wikipedia.org/wiki/Big_O_notation)
- [flutter JSON and serialization](https://docs.flutter.dev/development/data-and-backend/json)
- [regex](https://en.wikipedia.org/wiki/Regular_expression)
- [Provider](https://pub.dev/packages/provider)
- [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)
