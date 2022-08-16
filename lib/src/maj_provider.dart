/*
  Bradley Honeyman
  August 8, 2022

  This is the provider for managing the states of directories and children

 */

import 'package:flutter/material.dart';

class MAJProvider with ChangeNotifier {
  String currentPath;

  MAJProvider({
    required this.currentPath,
  });

  /// pass a valid path ex /root/node
  /// this will make the MAJBuilder change the currently displayed node to the
  /// node with the path passed
  /// ex:
  /// context.read<MAJProvider>().navigateTo("/root/node");
  void navigateTo(String path) {
    currentPath = path;
    notifyListeners();
  }
}
