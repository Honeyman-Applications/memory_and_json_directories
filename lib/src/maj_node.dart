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
import 'package:memory_and_json_directories/src/maj_item_interface.dart';
import 'package:flutter/material.dart';
import 'package:memory_and_json_directories/src/maj_directory.dart';

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
  ///   MAJNode.definitions["newTypeNameValue"] = ({required data}) {
  ///     return MAJDirectory(); // or a custom class that implements MAJItemInterface
  ///   }
  static Map<
      String,
      MAJItemInterface Function({
    required Map<String, dynamic>? data,
  })> definitions = {
    MAJDirectory().getTypeName(): ({
      required data,
    }) {
      return MAJDirectory();
    }
  };

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
  }) {
    // confirm name is valid format
    if (name.isEmpty ||
        !RegExp(r"^[a-zA-Z0-9_]+( [a-zA-Z0-9_]+)*$").hasMatch(name)) {
      throw FormatException(
        "Node: The name of the node must only be alphanumerical, with no leading or trailing white space. Whitespace can only be singular between two characters. Underscore is also permitted (_). name: $name",
      );
    }

    // set the default path
    path = "/$name";
  }

  /// builds a tree from a json array of objects
  /// the returned node is the root
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
      child: definitions[temp[0]["typeName"]]!(data: temp[0]["data"]),
    );

    // add any children to the root
    for (int i = 1; i < temp.length; i++) {
      root.breadthFirstSearch(temp[i]["parent"])!.addChild(
            MAJNode(
              name: temp[i]["name"],
              typeName: temp[i]["typeName"],
              data: temp[i]["data"],
              child: definitions[temp[i]["typeName"]]!(data: temp[i]["data"]),
            ),
          );
    }

    return root;
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

    // set child's parent, path, and add to children
    child.parent = this;
    child.path = "$path/${child.name}";
    children.add(child);

    // update path of child's children
    // don't run on child
    bool skip = true;
    child.breadthFirst(
      nodeAction: (currentNode) {
        if (!skip) {
          currentNode.path = child.path +
              currentNode.path.substring(
                currentNode.path.lastIndexOf("/"),
                currentNode.path.length,
              );
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
    return children.removeAt(
      children.indexWhere(
        (element) => element.name == name,
      ),
    );
  }

  /// updates the name of the current node, and
  /// performs a breadth first traversal, and updates the path of all children
  MAJNode rename(String newName) {
    if (parent != null) {
      for (int i = 0; i < parent!.children.length; i++) {
        if (parent!.children[i].name == newName) {
          throw FormatException(
              "The node with name $newName already exists as the child of ${parent!.name}");
        }
      }
    }

    // find the beginning and ending of the name to be replaced in the string
    // and set the name
    int start = path.lastIndexOf("/") + 1;
    int end = path.length; // noninclusive
    name = newName;

    // set the new path of current node and any children
    breadthFirst(nodeAction: (currentNode) {
      String newPath = currentNode.path.substring(0, start);
      newPath += newName;
      newPath += currentNode.path.substring(end, currentNode.path.length);
      currentNode.path = newPath;
      return false; // don't trigger break
    });

    // return the current node with the new name
    return this;
  }

  /// returns a formatted string of the tree using a
  /// breadth first traversal
  String breadthFirstTraversal({
    String betweenPeers = ", ",
    String betweenParentAndChildren = "\n",
  }) {
    String output = "";
    breadthFirst(nodeAction: (currentNode) {
      output += betweenPeers;
      return false;
    }, betweenRows: () {
      output += betweenParentAndChildren;
      return false;
    });

    return output;
  }

  /// performs a search for a node with the passed path
  /// uses a breadth first traversal.
  /// returns the node on success and null on failure
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
      data: data,
      nodeReference: this,
    );
  }
}