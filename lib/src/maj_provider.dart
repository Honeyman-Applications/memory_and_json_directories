/*
  Bradley Honeyman
  August 8, 2022

  This is the provider for managing the states of directories and children

 */

import 'package:flutter/material.dart';
import 'package:memory_and_json_directories/memory_and_json_directories.dart';

class MAJProvider with ChangeNotifier {
  /// the default map key used in MAJProvider.maps
  static const defaultMapKey = "default";

  /// The outer map references a unique key for each tree, if there is only one
  /// tree the default map key is used. If there is to be more than one tree
  /// in memory at a time, ensure each tree has a key in the outer map.
  /// The inner maps contain the path of each node in the tree, and a memory
  /// reference to that node, so any node can be accessed O(1)
  static Map<String, Map<String, MAJNode>> maps = {
    defaultMapKey: {},
  };

  /// adds a key and node reference to the map
  /// overwrites existing entries unless check == true
  /// if a key already exists and check == true an error is thrown
  static void addToMap({
    required MAJNode node,
    bool check = false,
  }) {
    // check for overwrite throw error if will happen and check true
    if (check) {
      if (maps[node.mapKey]!.containsKey(node.path)) {
        throw Exception(
          "MAJProvider: Cannot add '$node.path' to map, because it already exists",
        );
      }
    }

    // add mapKey if doesn't already exist
    if (!maps.containsKey(node.mapKey)) {
      maps[node.mapKey] = {};
    }

    // add the node reference with path to the map
    maps[node.mapKey]![node.path] = node;
  }

  /// removes a value from the map if the key exists
  /// otherwise null is returned
  static MAJNode? removeFromMap({
    required String path,
    String mapKey = MAJProvider.defaultMapKey,
  }) {
    return maps[mapKey]!.remove(path);
  }

  /// the default map key used if by MAJBuilder if no key is specified
  final String mapKey;

  /// the node to be displayed currently
  MAJNode currentNode;

  MAJProvider({
    required this.currentNode,
    this.mapKey = defaultMapKey,
  });

  /// pass a valid path ex /root/node
  /// this will make the MAJBuilder change the currently displayed node to the
  /// node with the path passed
  /// ex:
  /// context.read<MAJProvider>().navigateTo("/root/node");
  void navigateTo({
    required String path,
  }) {
    currentNode = maps[mapKey]![path]!;
    notifyListeners();
  }

  /// allows navigation to a node by a reference to a node
  /// this will make the MAJBuilder change the currently displayed node
  /// to the passed node
  /// ex:
  /// context.read<MAJProvider>().navigateToByNode(myNode);
  void navigateToByNode({
    required MAJNode nodeTo,
  }) {
    currentNode = nodeTo;
    notifyListeners();
  }
}
