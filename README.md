# memory_and_json_directories

## ***This package is not currently production, expect may changes. Check back later for a more stable version***

A platform independent directory structure, which can be saved as JSON. This package is an implmentation of a [general tree](https://opendsa-server.cs.vt.edu/OpenDSA/Books/CS3/html/GenTreeIntro.html).

## Please Post Questions on StackOverflow, and tag @CatTrain (user:16200950)

<https://stackoverflow.com/>

## Building a directory

- ### Memory Building

- ### JSON Building

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

## Versioning

[Semantic Versioning 2.0.0](https://semver.org/)
