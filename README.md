# memory_and_json_directories

A Flutter package, with a platform independent directory structure, which can be saved as JSON. This package is an implmentation of a [general tree](https://opendsa-server.cs.vt.edu/OpenDSA/Books/CS3/html/GenTreeIntro.html).

## Please Post Questions on StackOverflow, and tag @CatTrain (user:16200950)

<https://stackoverflow.com/>

## Building a directory

- [example](https://github.com/Honeyman-Applications/memory_and_json_directories/blob/master/example/lib/main.dart)

- ### Memory Building

  - The method used to display the directory for the end user
  - From JSON
    - pass a valid JSON string to ```MAJNode.fromJson```
      - the node created will be the root of the directory
      - all other nodes can be found from the root node, or ```MAJProvider.map```
    - example

      ```dart
      MAJNode root = MAJNode.fromJson('[{"name":"the rooter","path":"/the rooter","parent":"","typeName":"maj_directory","data":{}}]');
      ```

  - From Objects
    - create nodes and add them as children to other nodes
    - It is reccomended you don't make a single node the child of two different nodes
    - example

      ```dart
        MAJNode root = MAJNode(
          name: "the rooter",
          typeName: MAJDirectory.typeName,
          child: MAJDirectory(),
        );
        MAJNode two = root.addChild(
          MAJNode(
            name: "Two",
            typeName: MAJDirectory.typeName,
            child: MAJDirectory(),
          ),
        );
        two.addChild(
          MAJNode(
            name: "deep",
            typeName: MAJDirectory.typeName,
            child: MAJDirectory(),
          ),
        );
      ```

- ### JSON Building

  - The method used to save the directory to a file system or server
  - using the reference to the root node run ```breadthFirstToJson```, which will convert the entire directory to JSON
  - example

    ```dart
    // root must have been already created before this is run, see above
    String saveMe = root.breadthFirstToJson();
    // run code to save the json string ...
    ```

## Custom Items

- [example](https://github.com/Honeyman-Applications/memory_and_json_directories/blob/master/example/lib/main.dart)

- items that can be displayed in the directory, saved to JSON, and built from JSON
- create an object that ```implements MAJItemInterface```
  - ```getTypeName``` must return a string which is unique to all of your custom items of the same type
    - all of your custom items will have the same ```typeName``` unless they are a different type of custom item
    - it is reccomended to add a ```static const String typeName``` property to the object
  - ```build```
    - passes the current build context, and a reference to the node that contians the custom item
    - must return a ```Widget```
      - the ```Widget``` should get and store all of it's data in ```nodeReference.data``` this way the data can be saved as JSON. Any data not saved in ```nodeReference.data``` will not be saved as JSON
  - example

    ```dart
    class CustomItem implements MAJItemInterface {
      static const String typeName = "custom_item";

      @override
      String getTypeName() {
        return typeName;
      }

      @override
      Widget build({
        required BuildContext context,
        required MAJNode nodeReference,
      }) {
        return CustomItemWidget( // created by you
          nodeReference: nodeReference,
        );
      }
    }
    ```

- create a widget to display your custom item
  - example
    - see below how data is read and written to ```nodeReference.data```

    ```dart
    class CustomItemWidget extends StatelessWidget {
      final MAJNode nodeReference; // recommend always adding

      const CustomItemWidget({
        Key? key,
        required this.nodeReference, // recommend always adding
      }) : super(key: key);

      @override
      Widget build(BuildContext context) {
        return Column(
          children: [
            // a back button to navigate back to the parent widget
            ElevatedButton(
              child: const Text("back"),
              onPressed: () {
                context.read<MAJProvider>().navigateToByNode(
                      nodeReference.parent!,
                    );
              },
            ),
            TextFormField(
              initialValue: nodeReference.data!["name"], // get custom data
              onChanged: (value) {
                nodeReference.data!["name"] = value; // set custom data
              },
            ),
          ],
        );
      }
    }
    ```

- create a definition used to build the custom item from JSON
  - must be done before any attempt to build from JSON, or the build will fail
  - if the definition already exists an error will be thrown if ```MAJNode.addDefinition``` is used to add the definition
  - example

    ```dart
    MAJNode.addDefinition(
      typeName: CustomItem.typeName,
      function: () {
        return CustomItem();
      },
    );
    ```

- add the custom item to a directory
  - add the new node as a child of a existing node usually
  - example

    ```dart
    MAJNode root = MAJNode(
      name: "the rooter",
      typeName: MAJDirectory.typeName,
      child: MAJDirectory(),
    );
    root.addChild(
      MAJNode(
        name: "custom",
        typeName: CustomItem.typeName,
        data: <String, dynamic>{
          "name": "Snarf",
        },
        child: CustomItem(),
      ),
    );    
    ```

## ```MAJProvider.map```

- this map, maps node paths to node references in memory only
- this map allows accessing nodes O(1) when you have the node's path

- ### Adding Entries automatically

  - ```MAJNode```
    - when the node is first created it is added to the map as a root entry
      - ex: ```{"/myNodeName": nodeReference, ...}```
      - if a node with the same path already exists in ```MAJProvider.map``` it is overwritten by default
        - if ```MAJNode(safeAddToMap: true)``` then an error will be thrown if a node already exists in the map with the same path
  - ```MAJNode.addChild```
    - the existing path for the node is removed from ```MAJProvider.map```
      - ussually the root path described above
    - the new path is then added to ```MAJProvider.map```
    - if a path that is the same as the new path exists in ```MAJProvider.map``` it will be overwritten

- ### Adding Entries manually

  - ```MAJProvider.addToMap```
    - adds a entry to ```MAJProvider.map```, by default it overwrites existing entries
      - unless ```MAJProvider.addToMap(check: true)``` in which case an error will be thrown if an entry already exists
    - example

      ```dart
      MAJProvider.addToMap(
        path: "/root/myCustomPath",
        node: myNodeReference, // MAJNode
      );
      ```

- ### Removing Entries automatically

  - ```MAJNode.removeChild```
    - when a child node is removed it and all of it's children are removed from ```MAJProvider.map```

- ### Removing Entries manually

  - ```MAJProvider.removeFromMap```
    - removed an entry from the map, returns null if that entry doesn't exist to be removed from ```MAJProvider.map```
    - example

      ```dart
      MAJProvider.removeFromMap(
        path: "/root/myCustomPath",
      ); 
      ```

## Storage

- ### Memory Storage

  - The directory is stored as a [general tree](https://opendsa-server.cs.vt.edu/OpenDSA/Books/CS3/html/GenTreeIntro.html)
  - Each node has
    - ```children```
      - array of nodes which are the children of this node
      - if the array is empty the node has no children
    - ```parent```
      - a reference to the node which is this node's parent
      - if ```null``` this means the node is a root node
    - ```name```
      - a ```String``` that is the name of the node
      - must be unique amongst its peers
    - ```path```
      - a ```String``` that contains the node's name and the name of all it's ancestors
      - must be unique amongst all nodes in the tree
    - ```typeName```
      - a ```String```, which is used to determine which definition to use when building the node from json
    - ```data```
      - A ```Map<String, dynamic>```
      - stores data required to build the node's child
      - can be ```null``` if not required
      - must be able to convert to a JSON object
    - ```child```
      - an ```object```, which implments ```MAJItemInterface```
      - the object builds a widget when it's ```build``` method is called by the node

- ### JSON storage

  - The directory is stored as an array of json objects
    - in left to right, top to bottom order ([breadth first](https://en.wikipedia.org/wiki/Breadth-first_search))
  - each json object contains
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
  - Example
    - ```[{"name":"the rooter","path":"/the rooter","parent":"","typeName":"maj_directory","data":{}}, ...]```

## References

- [JSON](https://en.wikipedia.org/wiki/JSON)
- [memory](https://en.wikipedia.org/wiki/Computer_memory)
- [Semantic Versioning 2.0.0](https://semver.org/)
- [breadth first](https://en.wikipedia.org/wiki/Breadth-first_search)
- [general tree](https://opendsa-server.cs.vt.edu/OpenDSA/Books/CS3/html/GenTreeIntro.html)
- [big O notation](https://en.wikipedia.org/wiki/Big_O_notation)
- [flutter JSON and serialization](https://docs.flutter.dev/development/data-and-backend/json)
