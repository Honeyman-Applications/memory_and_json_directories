/*
  Bradley Honeyman
  July 14th, 2022

  This is a node in the general tree used to represent the
  memory and json directories tree

  ref:
  https://en.wikipedia.org/wiki/Breadth-first_search
  https://dart-lang.github.io/linter/lints/hash_and_equals.html
  https://en.wikipedia.org/wiki/Tree_traversal

 */

import 'package:memory_and_json_directories/memory_and_json_directories.dart';
import 'package:flutter/material.dart';

class MAJNode {
  String name;
  late String path;
  MAJNode? parent;
  List<MAJNode> children = <MAJNode>[];
  Map<String, dynamic>? data;
  MAJItemInterface child;
  String typeName;

  /// json key used to identify the array that contains the nodes in a json array
  static const nodesKey = "nodes";

  /// a map of definitions used to build items based on their typeName (String),
  /// which is unique, and their data
  /// definitions must be added before a MAJNode.fromJson is run, otherwise the
  /// build will fail
  /// ex:
  ///   MAJNode.definitions["newTypeNameValue"] = () {
  ///     return MAJDirectory(); // or a custom class that implements MAJItemInterface
  ///   }
  static Map<String, MAJItemInterface Function()> definitions = {
    MAJDirectory.typeName: () {
      return MAJDirectory();
    }
  };

  /// A safe way to add definitions to MAJNode.definitions
  /// checks if the key you wish to add already exist
  /// throws an error if the definition has already been defined
  static void addDefinition({
    required String typeName,
    required MAJItemInterface Function() function,
  }) {
    // confirm the added definition will not overwrite an existing definition
    for (int i = 0; i < definitions.keys.length; i++) {
      if (typeName == definitions.keys.elementAt(i)) {
        throw Exception(
          "MAJNode.addDefinition: The definition for: '$typeName' already exists",
        );
      }
    }

    // add the definitions
    definitions[typeName] = function;
  }

  /// returns true if the passed name is valid
  /// returns false if the passed name is not valid
  /// only checks the name's format, does not check peer names
  static bool validName({required String name}) {
    return name.isNotEmpty &&
        RegExp(
          r"^[a-zA-Z0-9_]+( [a-zA-Z0-9_]+)*$",
        ).hasMatch(name);
  }

  /// the default constructor used to build a node
  /// name must be unique within peers
  /// data must be a map with only data that can be converted to json
  /// child must be a object that implements MAJItemInterface, which
  ///   will be used to build the widget to represent the node
  /// typeName is a string used to map the object to what definition to use
  ///   when building it from json
  MAJNode({
    required this.name,
    this.data,
    required this.child,
    required this.typeName,
    bool safeAddToMap = false,
  }) {
    // confirm name is valid format
    if (!validName(name: name)) {
      throw FormatException(
        "MAJNode: The name of the node must only be alphanumerical, with no leading or trailing white space. Whitespace can only be singular between two characters. Underscore is also permitted (_). name: $name",
      );
    }

    // set the path
    path = "/$name";

    // add to map
    MAJProvider.addToMap(
      path: path,
      node: this,
      check: safeAddToMap,
    );
  }

  /// build a single node from json. Use MAJNode.breadthFirstFromJson for
  /// converting an entire tree from json to memory data
  /// follows flutter json standard
  ///   https://docs.flutter.dev/development/data-and-backend/json
  ///   Serializing JSON inside model classes
  factory MAJNode.fromJson(Map<String, dynamic> json) {
    return MAJNode(
      name: json["name"],
      typeName: json["typeName"],
      data: json["data"],
      child: definitions[json["typeName"]]!(),
    );
  }

  /// builds a tree from a json array of objects
  /// the returned node is the root
  /// uses an approach similar to a breadth first traversal
  ///   https://en.wikipedia.org/wiki/Breadth-first_search
  ///   O(2n)
  factory MAJNode.breadthFirstFromJson(Map<String, dynamic> json) {
    // make easy ref to nodes array
    List nodes = json[nodesKey];

    // confirm that there is at least one node in the tree
    if (nodes.isEmpty) {
      throw const FormatException(
        "MAJNode.breadthFirstFromJson: must include one or more nodes",
      );
    }

    // create the root
    MAJNode root = MAJNode.fromJson(
      nodes[0],
    );

    // init the queue and add root to the queue
    List<MAJNode> queue = [];
    MAJNode currentParent = root;

    // iterate through all the nodes in the array
    for (int i = 1; i < nodes.length; i++) {
      // build the current node as a object
      MAJNode current = MAJNode.fromJson(
        nodes[i],
      );

      // add current to the queue
      queue.add(current);

      // shift off the queue until the correct parent is found
      // then add the current node to the current parent
      while (nodes[i]["parent"] != currentParent.path) {
        currentParent = queue.removeAt(0);
      }
      currentParent.addChild(current);
    }

    return root;
  }

  /// add a node to the directory tree
  /// the node must be unique amongst the peers (children)
  /// returns the added child to allow chaining
  /// updates the paths of the child's children
  /// removes child node's parent's reference to the child if the child
  /// has a parent node
  /// throws error if a parent node is added as a child to one of the
  /// parents children/sub-children
  MAJNode addChild(MAJNode child) {
    // throw error if the child has the same name as any of it new peers
    int contains = children.indexWhere(
      (element) {
        return element.name == child.name;
      },
    );
    if (contains != -1) {
      throw FormatException(
          "MAJNode.addChild: The node with name ${child.name} already exists as the child of $name");
    }

    // throw error if the passed node is an ancestor of the current node
    if (path.indexOf(child.path) == 0) {
      throw const FormatException(
        "MAJNode.addChild: Can't add an ancestor of the current node as a child",
      );
    }

    // remove the child's previous entry in the MAJProvider.map
    MAJProvider.removeFromMap(path: child.path);

    // remove the existing parent's reference if there is a parent
    if (child.parent != null) {
      child.parent!.children.removeAt(
        child.parent!.children.indexWhere(
          (element) => element.path == child.path,
        ),
      );
    }

    // set child's parent, path, and add to children
    child.parent = this;
    child.path = "$path/${child.name}";
    children.add(child);

    // add the child to the map
    MAJProvider.addToMap(
      path: child.path,
      node: child,
    );

    // update path of child's children
    // don't run on child
    bool skip = true;
    child.breadthFirst(
      nodeAction: (currentNode) {
        if (!skip) {
          // remove current node's reference in MAJProvider.map
          MAJProvider.removeFromMap(path: currentNode.path);

          // set current node's new path
          currentNode.path = child.path +
              currentNode.path.substring(
                currentNode.path.lastIndexOf("/"),
                currentNode.path.length,
              );

          // add the new path and current node's reference to MAJProvider.map
          MAJProvider.addToMap(path: currentNode.path, node: currentNode);
        }
        skip = false;
        return false;
      },
    );

    // return the child
    return child;
  }

  /// removes references to all children
  /// removes all child references in MAJProvider.map
  /// all children should be collected by the garbage collector after
  void removeAllChildren() {
    // remove MAJProvider.map references
    for (int i = 0; i < children.length; i++) {
      children[i].remove();
    }
    // remove all from children array
    children.clear();
  }

  /// removes the current node and all it's children from MAJProvider.map
  /// returns a reference to the current node
  MAJNode remove() {
    breadthFirst(
      nodeAction: (currentNode) {
        MAJProvider.removeFromMap(path: currentNode.path);
        return false; // don't break
      },
    );
    return this;
  }

  /// remove a child from the tree
  /// returns the removed child to allow chaining
  /// children of the removed child should be garbage collected automatically
  /// if the removed child reference is discarded
  /// if preserveMapReferences == true the children and the current node's
  /// references aren't removed from MAJProvider.map
  MAJNode removeChild(
    String name, {
    bool preserveMapReferences = false,
  }) {
    // get index of child to be removed
    int indexOfToBeRemoved = children.indexWhere(
      (element) => element.name == name,
    );

    // remove child and all it's children from MAJProvider.map
    // unless preserveMapReferences == true
    if (!preserveMapReferences) {
      children[indexOfToBeRemoved].breadthFirst(
        nodeAction: (currentNode) {
          MAJProvider.removeFromMap(
            path: currentNode.path,
          );
          return false; // don't break
        },
      );
    }

    // remove child
    return children.removeAt(
      indexOfToBeRemoved,
    );
  }

  /// updates the name of the current node, and
  /// performs a breadth first traversal, and updates the path of all children
  MAJNode rename(String newName) {
    // confirm the peers do not have the same name
    if (parent != null) {
      for (int i = 0; i < parent!.children.length; i++) {
        if (parent!.children[i].name == newName) {
          throw FormatException(
              "MAJNode.rename: The node with name $newName already exists as the child of ${parent!.name}");
        }
      }
    }

    // confirm new name is a valid format, throw error if is not
    if (!validName(name: newName)) {
      throw FormatException(
          "MAJNode.rename: The passed name is not a valid format: $newName");
    }

    // find the beginning and ending of the name to be replaced in the string
    // and set the name
    int start = path.lastIndexOf("/") + 1;
    int end = path.length; // noninclusive
    name = newName;

    // set the new path of current node and any children
    breadthFirst(
      nodeAction: (currentNode) {
        // remove the old path from the map
        MAJProvider.removeFromMap(path: currentNode.path);

        // update the path
        String newPath = currentNode.path.substring(0, start);
        newPath += newName;
        newPath += currentNode.path.substring(end, currentNode.path.length);
        currentNode.path = newPath;

        // add the new path to the map
        MAJProvider.addToMap(
          path: currentNode.path,
          node: currentNode,
        );

        return false; // don't trigger break
      },
    );

    // return the current node with the new name
    return this;
  }

  /// move the current node from it's current location to be a child of the
  /// node with the passed path
  /// will fail if MAJProvider.map doesn't have a reference to the passed path
  /// if the path is a sub path of the current node an error is thrown
  /// because the current node can't be the child of one of it's children
  MAJNode move({required String path}) {
    // confirm the path is not a child of the current node
    // only a child if match to path is exact from the start
    if (path.indexOf(this.path) == 0) {
      throw Exception(
        "MAJNode.move: the move path cannot be a sub-path of the current node (the node cannot be the child of one of its children)",
      );
    }

    // perform move
    return MAJProvider.map[path]!.addChild(this);
  }

  /// recursive function that returns the root of the entire tree
  /// which the passed node is part of
  MAJNode _getRootHelper(MAJNode current) {
    if (current.parent != null) {
      return _getRootHelper(current.parent!);
    }
    return current;
  }

  /// returns a reference to the root of the entire tree,
  /// which the current node is part of
  MAJNode getRoot() {
    return _getRootHelper(this);
  }

  /// returns a formatted string of the tree using a
  /// breadth first traversal
  /// outputs each node's path
  String breadthFirstTraversalString({
    String betweenPeers = ", ",
    String betweenParentAndChildren = "\n",
  }) {
    String output = "";
    breadthFirst(nodeAction: (currentNode) {
      output += currentNode.path + betweenPeers;
      return false;
    }, betweenRows: () {
      output += betweenParentAndChildren;
      return false;
    });

    return output;
  }

  /// runs isMatchFunction on every node including the current node
  /// isMatchFunction is passed a reference to the current node and all it's
  /// children iteratively
  /// if isMatchFunction returns true the current node is added to the list
  /// if isMatchFunction returns false the node isn't added to the list
  /// if includeCurrent == true the current node is included in the search
  /// ex: (root is a object previously created by you for this to work)
  /// root.breadthFirstSearch(
  ///   isMatchFunction: (MAJNode node) {
  ///     return RegExp(r"root").hasMatch(node.name);
  ///   },
  /// );
  List<MAJNode> breadthFirstSearch({
    required bool Function(MAJNode node) isMatchFunction,
    bool includeCurrent = false,
  }) {
    // create the list and add any nodes that match the
    List<MAJNode> temp = [];
    bool isFirst = true;
    breadthFirst(
      nodeAction: (currentNode) {
        // skip first if is first iteration and includeCurrent is false
        if (isFirst && !includeCurrent) {
          isFirst = false;
          return false;
        }
        isFirst = false;

        // run custom function and add current node to temp if true
        if (isMatchFunction(currentNode)) {
          temp.add(currentNode);
        }

        return false; // don't break
      },
    );

    return temp;
  }

  /// runs breadthFirstSearch, but searches by node name
  /// true if the name node name contains the name passed
  /// is case insensitive
  List<MAJNode> breadthFirstSearchByName({
    required String name,
    bool includeCurrent = false,
  }) {
    return breadthFirstSearch(
      isMatchFunction: (node) {
        if (node.name.toLowerCase().contains(name.toLowerCase())) {
          return true;
        }
        return false;
      },
      includeCurrent: includeCurrent,
    );
  }

  /// uses a breadth first traversal to convert the tree to an array of
  /// object references. Best to use breadthFirstToJson if intend to convert
  /// to json
  List<MAJNode> breadthFirstToArray() {
    List<MAJNode> tree = <MAJNode>[];
    breadthFirst(
      nodeAction: (MAJNode currentNode) {
        tree.add(currentNode);
        return false;
      },
    );
    return tree;
  }

  /// uses a breadth first traversal to convert the tree to a json array
  /// of objects. This is the format understood by MAJNode.fromJson
  /// use this function to convert the tree to json. The current node will be
  /// the root of the tree, even if it isn't the actual root of the tree,
  /// and only the current node's children will be saved
  Map<String, dynamic> breadthFirstToJson() {
    return {
      nodesKey: breadthFirstToArray(),
    };
  }

  /// a function that performs a breadth first traversal of the tree
  /// and considers the current node to be the root
  /// itemAction
  ///   allows running operations based on the current node being
  ///   traversed, return true to break and end the traversal
  ///   return false to continue
  /// betweenRows
  ///   allows running operations when the current row has been processed
  ///   return true to break and end the traversal, return false to continue
  void breadthFirst({
    required bool Function(MAJNode currentNode) nodeAction,
    bool Function()? betweenRows,
  }) {
    // init the queue used to process
    List<MAJNode> queue = <MAJNode>[];
    queue.add(this);

    // exit condition, complete once entire queue is processed
    while (queue.isNotEmpty) {
      // iterate through the current breadth
      int currentBreastLength = queue.length;
      while (currentBreastLength > 0) {
        // get the first node in the queue, and remove it from the queue
        MAJNode currentNode = queue[0];
        queue.removeAt(0);

        // perform passed action
        // exit if function returns true, because indicates break
        if (nodeAction(currentNode)) {
          return;
        }

        // add current node's children to the queue for processing
        for (int i = 0; i < currentNode.children.length; i++) {
          queue.add(currentNode.children[i]);
        }
        currentBreastLength--;
      }

      // between rows
      // exit if function returns true, because indicates break
      if (betweenRows != null) {
        if (betweenRows()) {
          return;
        }
      }
    }
  }

  /// returns a map that can be used to convert the node to json
  /// https://docs.flutter.dev/development/data-and-backend/json
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "path": path,
      "parent": parent != null ? parent!.path : "",
      "typeName": typeName,
      "data": data ?? {},
    };
  }

  /// return a map toString including the node's properties
  @override
  String toString() {
    return toJson().toString();
  }

  /// called by JsonBuilder to represent the node using the widget
  /// specified as the child
  Widget build(BuildContext context) {
    return child.build(
      context: context,
      nodeReference: this,
    );
  }
}
