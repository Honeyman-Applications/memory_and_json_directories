/*
  Bradley Honeyman
  August 8, 2022

  This is the provider for managing the states of directories and children

 */

import 'package:flutter/material.dart';
import 'package:memory_and_json_directories/memory_and_json_directories.dart';

class MAJProvider with ChangeNotifier {
  String currentPath;
  MAJNode currentNode;
  bool byPathElseByNode = false;

  /// a map with keys == the paths of all nodes
  /// values == references to all nodes
  static final Map<String, MAJNode> map = {};

  MAJProvider({
    required this.currentPath,
    required this.currentNode,
  });

  /// adds a key and node reference to the map
  /// overwrites existing entries unless check == true
  /// if a key already exists and check == true an error is thrown
  static void addToMap({
    required String path,
    required MAJNode node,
    bool check = false,
  }) {
    // check for overwrite throw error if will happen and check true
    if (check) {
      for (int i = 0; i < map.keys.length; i++) {
        if (map.keys.elementAt(i) == path) {
          throw Exception(
            "MAJProvider: Cannot add '$path' to map, because it already exists",
          );
        }
      }
    }

    // add the node reference with path to the map
    map[path] = node;
  }

  /// removes a value from the map if the key exists
  /// otherwise null is returned
  static MAJNode? removeFromMap({
    required String path,
  }) {
    return map.remove(path);
  }

  /// pass a valid path ex /root/node
  /// this will make the MAJBuilder change the currently displayed node to the
  /// node with the path passed
  /// ex:
  /// context.read<MAJProvider>().navigateTo("/root/node");
  void navigateTo(String path) {
    byPathElseByNode = true;
    currentPath = path;
    notifyListeners();
  }

  /// allows navigation to a node by a reference to a node
  /// this will make the MAJBuilder change the currently displayed node
  /// to the passed node
  /// ex:
  /// context.read<MAJProvider>().navigateToByNode(myNode);
  void navigateToByNode(MAJNode nodeTo) {
    byPathElseByNode = false;
    currentNode = nodeTo;
    notifyListeners();
  }
}
