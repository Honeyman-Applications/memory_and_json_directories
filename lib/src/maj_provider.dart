/*
  Bradley Honeyman
  August 8, 2022

  This is the provider for managing the states of directories and children

 */

import 'package:flutter/material.dart';
import 'package:memory_and_json_directories/memory_and_json_directories.dart';

class MAJProvider with ChangeNotifier {
  static const defaultMapKey = "default";

  /// a map with keys == the paths of all nodes
  /// values == references to all nodes
  //static final Map<String, MAJNode> map = {};
  static Map<String, Map<String, MAJNode>> maps = {
    defaultMapKey: {},
  };

  /// adds a key and node reference to the map
  /// overwrites existing entries unless check == true
  /// if a key already exists and check == true an error is thrown
  static void addToMap({
    required String path,
    required MAJNode node,
    bool check = false,
    String mapKey = MAJProvider.defaultMapKey,
  }) {
    // check for overwrite throw error if will happen and check true
    if (check) {
      for (int i = 0; i < maps[mapKey]!.keys.length; i++) {
        if (maps[mapKey]!.keys.elementAt(i) == path) {
          throw Exception(
            "MAJProvider: Cannot add '$path' to map, because it already exists",
          );
        }
      }
    }

    // add the node reference with path to the map
    maps[mapKey]![path] = node;
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
