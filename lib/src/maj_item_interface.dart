/*
  Bradley Honeyman
  July 15th, 2022

  This interface is used to specify the functions that must be available
  in an object which wishes to be part of the memory and json Directories tree

 */

import 'package:flutter/material.dart';
import 'package:memory_and_json_directories/src/maj_node.dart';

/// The interface used to ensure children of MAJNode have the correct functions
/// it is recommended to add a static type name variable,but it is not required
/// ex: static String typeName = "my_custom_item";
abstract class MAJItemInterface {
  /// must return a string which will be a unique key in
  /// MAJNode.definitions map
  String getTypeName();

  /// return a widget which you wish to have displayed
  /// nodeReference contains any data you would need
  /// from a constructor
  Widget majBuild({
    required BuildContext context,
    required MAJNode nodeReference,
  });
}
