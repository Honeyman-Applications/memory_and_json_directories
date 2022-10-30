# memory_and_json_directories

A Flutter package, with a platform independent directory structure, which can be saved as JSON. This package is an implementation of a [general tree](https://opendsa-server.cs.vt.edu/OpenDSA/Books/CS3/html/GenTreeIntro.html).

## Please Post Questions on StackOverflow, and tag @CatTrain (user:16200950)

<https://stackoverflow.com/>

## Basic Example

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:memory_and_json_directories/memory_and_json_directories.dart';

void main() {
  // build a tree in memory
  MAJNode root = MAJNode(
    name: "root",
    child: MAJDirectory(),
    typeName: MAJDirectory.typeName,
  );
  root
      .addChild(
        MAJNode(
          name: "one",
          child: MAJDirectory(),
          typeName: MAJDirectory.typeName,
        ),
      )
      .addChild(
        MAJNode(
          name: "one one level down",
          child: MAJDirectory(),
          typeName: MAJDirectory.typeName,
        ),
      );
  root.addChild(
    MAJNode(
      name: "two",
      child: MAJDirectory(),
      typeName: MAJDirectory.typeName,
    ),
  );

  // convert to json
  String treeAsJson = jsonEncode(
    root.breadthFirstToJson(),
  );

  // load from json string
  MAJNode fromJson = MAJNode.breadthFirstFromJson(
    jsonDecode(
      treeAsJson,
    ),
  );

  // display the tree loaded from json
  runApp(
    MaterialApp(
      home: Scaffold(
        body: MAJBuilder(
          root: fromJson,
        ),
      ),
    ),
  );
}
```

## Custom Item Example

- see [example](https://github.com/Honeyman-Applications/memory_and_json_directories/blob/master/example/lib/main.dart) for full code
- requires Basic Example code
- create a custom item
  - ensure it implements ```MAJItemInterface```
  - this example has a back button that navigates to the parent node, and text that displays "Hello I am a custom item"

  ```dart
  /// A basic custom item that can display whatever you wish
  class CustomItem implements MAJItemInterface {
    /// not required, but recommended
    static const String typeName = "custom_item";

    @override
    String getTypeName() {
      return typeName;
    }

    @override
    Widget majBuild({
      required BuildContext context,
      required MAJNode nodeReference,
    }) {
      return Center(
        child: Column(
          children: [
            // back button, navigates to parent, unless there is not parent node
            ElevatedButton(
              onPressed: () {
                if (nodeReference.parent != null) {
                  context.read<MAJProvider>().navigateToByNode(
                        nodeTo: nodeReference.parent!,
                      );
                }
              },
              child: const Text("Back"),
            ),

            // custom widget to display
            const Text("Hello I am a custom item"),
          ],
        ),
      );
    }
  }
  ```

- add the custom item's definition, so it can be built from json

  ```dart
  // define the custom item, so it can be loaded from json
  MAJNode.addDefinition(
    typeName: CustomItem.typeName,
    function: () => CustomItem(),
  );
  ```

- add a custom item to the tree

  ```dart
  // add a custom item to the tree
  root.addChild(
    MAJNode(
      name: "Custom Item",
      child: CustomItem(),
      typeName: CustomItem.typeName,
    ),
  );
  ```

## Data and Shared Data Example

- see [example](https://github.com/Honeyman-Applications/memory_and_json_directories/blob/master/example/lib/main.dart) for full code
- requires Custom Item Example Code
- modify ```CustomItem```
  - set code in build to set a default data value

    ```dart
    // set default data value if no data
    if (nodeReference.data == null || nodeReference.data!.keys.isEmpty) {
      nodeReference.data = nodeReference.data = <String, bool>{
        "pressed": false,
      };
    }
    ```

  - wrap returned ```Widget``` in a [StatefulBuilder](https://api.flutter.dev/flutter/widgets/StatefulBuilder-class.html) to allow dynamic button changes
  - add text that shows the shared data for ```CustomItem```

    ```dart
    Text(
      nodeReference.getSharedData().toString(),
    ),
    ```
  
  - add button that shows the data for the instance of ```CustomItem```
  
    ```dart
    // add button that shows the data for the instance of CustomItem
    OutlinedButton(
      // update data value for instance on pressed to opposite of what it was
      onPressed: () {
        setState(() {
          nodeReference.data!["pressed"] =
              !nodeReference.data!["pressed"];
        });
      },
      // display data for this instance
      child: Text(
        nodeReference.data!["pressed"].toString(),
      ),
    ),
    ```
  
## ```MAJNode```

- ### Naming rules

  - ```MAJNode.name``` must match the following [regex](https://en.wikipedia.org/wiki/Regular_expression) expression: ```^[a-zA-Z0-9_]+( [a-zA-Z0-9_]+)*$```
  - each name must be unique amongst its peers
    - when new nodes are added their name can not match a root node's name in their tree, because before they are added to another node as a child, they are a peer of all root nodes
    - These rules are scoped to within the ```MAJProvider.maps``` map the nodes are referenced in
- Stored in memory and json, see storage below for data
- ```MAJNode``` is the node used in the general tree
- See [code](https://github.com/Honeyman-Applications/memory_and_json_directories/blob/master/lib/src/maj_node.dart) for functions
  
## ```MAJItemInterface```

- The interface used to ensure children of MAJNode have the correct functions
- it is recommended to add a static type name variable, but it is not required
  - ex: ```static String typeName = "my_custom_item";```
- ```String getTypeName```
  - must return a string which will be a unique key in MAJNode.definitions map
- ```Widget majBuild```
  - return a widget which you wish to have displayed
  - nodeReference contains any data you would need from a constructor

## ```MAJBuilder```

- This is the widget used to display your tree in memory
- makes user of [Provider](https://pub.dev/packages/provider) to receive change notifications from ```MAJProvider```
  - this is how the widget knows which ```MAJNode``` to display
- This widget takes two parameters
- ```required MAJNode root```
  - The node you wish to have displayed first when the widget builds
  - This is typically the root of the tree
- ```String mapKey = MAJProvider.defaultMapKey```
  - the key you use to reference the map of nodes
  - don't set if you only intend to have one tree
  - set if you wish to have more than one tree in memory at once

## ```MAJProvider```

- The [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html) that notifies ```MAJBuilder``` to display a ```MAJNode```
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
- allows navigation to ```MAJNode``` by path or reference
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
      - an ```object```, which implements ```MAJItemInterface```
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
          - a JSON object containing the data required to build the node
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
