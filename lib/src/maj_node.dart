/*
  Bradley Honeyman
  July 14th, 2022

  This is a node in the general tree used to represent the
  memory and json directories tree

  ref:
  https://en.wikipedia.org/wiki/Breadth-first_search
  https://dart-lang.github.io/linter/lints/hash_and_equals.html

 */

import 'dart:convert';
import 'package:memory_and_json_directories/memory_and_json_directories.dart';
import 'package:memory_and_json_directories/src/maj_item_interface.dart';
import 'package:flutter/material.dart';
import 'package:memory_and_json_directories/src/maj_directory.dart';
import 'package:memory_and_json_directories/src/maj_provider.dart';

class MAJNode {
  String name;
  late String path;
  MAJNode? parent;
  List<MAJNode> children = <MAJNode>[];
  Map<String, dynamic>? data;
  MAJItemInterface child;
  String typeName;

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
          "MAJNode: The definition for: '$typeName' already exists",
        );
      }
    }

    // add the definitions
    definitions[typeName] = function;
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
    if (_nameNotValidCheck(name)) {
      throw FormatException(
        "MAJNode: The name of the node must only be alphanumerical, with no leading or trailing white space. Whitespace can only be singular between two characters. Underscore is also permitted (_). name: $name",
      );
    }

    // set the path
    path = "/$name";

    // perform a check if requested
    // if the map already contains the key throw error, unless
    if (safeAddToMap && MAJProvider.map.containsKey(path)) {
      throw FormatException(
          "MAJNode: Each root name must be unique: $path already exists");
    }

    // add to map
    MAJProvider.addToMap(
      path: path,
      node: this,
    );
  }

  /// builds a tree from a json array of objects
  /// the returned node is the root
  /// uses an approach similar to a breadth first traversal
  ///   https://en.wikipedia.org/wiki/Breadth-first_search
  ///   O(2n)
  factory MAJNode.fromJson(String json) {
    // get list from json
    List temp = List.from(jsonDecode(json));

    // confirm that there is at least one node in the tree
    if (temp.isEmpty) {
      throw const FormatException(
        "Node.fromJson: must include one or more nodes",
      );
    }

    // create the root
    MAJNode root = MAJNode(
      name: temp[0]["name"],
      typeName: temp[0]["typeName"],
      data: temp[0]["data"],
      child: definitions[temp[0]["typeName"]]!(),
    );

    // init the queue and add root to the queue
    List<MAJNode> queue = [];
    MAJNode currentParent = root;

    // iterate through all the nodes in the array
    for (int i = 1; i < temp.length; i++) {
      // build the current node as a object
      MAJNode current = MAJNode(
        name: temp[i]["name"],
        typeName: temp[i]["typeName"],
        data: temp[i]["data"],
        child: definitions[temp[i]["typeName"]]!(),
      );

      // add current to the queue
      queue.add(current);

      // shift off the queue until the correct parent is found
      // then add the current node to the current parent
      while (temp[i]["parent"] != currentParent.path) {
        currentParent = queue.removeAt(0);
      }
      currentParent.addChild(current);
    }

    return root;
  }

  /// returns true if the passed name is not a valid format
  /// returns false if is a valid name format
  bool _nameNotValidCheck(String name) {
    return name.isEmpty ||
        !RegExp(
          r"^[a-zA-Z0-9_]+( [a-zA-Z0-9_]+)*$",
        ).hasMatch(name);
  }

  /// add a node to the directory tree
  /// the node must be unique amongst the children
  /// returns the added child to allow chaining
  /// updates the paths of the child's children
  MAJNode addChild(MAJNode child) {
    // add the node if it doesn't already exist as a child
    if (children.contains(child)) {
      throw FormatException(
          "The node with name ${child.name} already exists as the child of $name");
    }

    // remove the child's previous entry in the MAJProvider.map
    MAJProvider.removeFromMap(path: child.path);

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

  /// remove a child from the tree
  /// returns the removed child to allow chaining
  /// children of the removed child should be garbage collected automatically
  /// if the removed child reference is discarded
  MAJNode removeChild(String name) {
    // get index of child to be removed
    int indexOfToBeRemoved = children.indexWhere(
      (element) => element.name == name,
    );

    // remove child and all it's children from MAJProvider.map
    children[children.indexWhere(
      (element) => element.name == name,
    )]
        .breadthFirst(
      nodeAction: (currentNode) {
        MAJProvider.removeFromMap(
          path: currentNode.path,
        );
        return false; // don't break
      },
    );

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
              "The node with name $newName already exists as the child of ${parent!.name}");
        }
      }
    }

    // confirm new name is a valid format, throw error if is not
    if (_nameNotValidCheck(newName)) {
      throw FormatException("The passed name is not a valid format: $newName");
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

  /// returns a formatted string of the tree using a
  /// breadth first traversal
  /// outputs each node's path
  String breadthFirstTraversal({
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
  /// ex: (root is a object previously created by you for this to work)
  /// root.inorderSearchBy(
  ///   (MAJNode node) {
  ///     return RegExp(r"root").hasMatch(node.name);
  ///   },
  /// );
  List<MAJNode> inorderSearchBy(bool Function(MAJNode node) isMatchFunction) {
    // create the list and add any nodes that match the
    List<MAJNode> temp = [];
    breadthFirst(
      nodeAction: (currentNode) {
        if (isMatchFunction(currentNode)) {
          temp.add(currentNode);
        }
        return false; // don't break
      },
    );

    return temp;
  }

  /// performs a search for a node with the passed path
  /// uses a breadth first traversal.
  /// returns the node on success and null on failure
  @Deprecated("function is O(n), use MAJProvider.map, which is O(1)")
  MAJNode? breadthFirstSearch(String path) {
    MAJNode? temp;
    breadthFirst(nodeAction: (currentNode) {
      if (currentNode.path == path) {
        temp = currentNode;
        return true;
      }
      return false;
    });

    // return null if nothing is found
    return temp;
  }

  /// uses a breadth first traversal to convert the tree to a json array
  /// of objects
  String breadthFirstToJson() {
    List tree = [];
    breadthFirst(
      nodeAction: (currentNode) {
        tree.add(currentNode);
        return false;
      },
    );

    return jsonEncode(tree);
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

  /// compares the current node to the passed object (other)
  /// other must be a Node of same type and have the same path to be equal
  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType && (other as MAJNode).path == path;

  /// hash is the hash of the path of the node
  /// this does not include any parent data
  @override
  int get hashCode => path.hashCode;

  /// called by JsonBuilder to represent the node using the widget
  /// specified as the child
  Widget build(BuildContext context) {
    return child.build(
      context: context,
      nodeReference: this,
    );
  }
}
