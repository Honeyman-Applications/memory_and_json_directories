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

  MAJProvider({
    required this.currentPath,
    required this.currentNode,
  });

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

  void navigateToByNode(MAJNode nodeTo) {
    byPathElseByNode = false;
    currentNode = nodeTo;
    notifyListeners();
  }
}
