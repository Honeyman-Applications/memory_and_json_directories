/*
  Bradley Honeyman
  July 14th, 2022

  This is the builder for memory and json directories

 */

import 'package:flutter/material.dart';
import 'package:memory_and_json_directories/src/maj_node.dart';
import 'package:provider/provider.dart';
import 'package:memory_and_json_directories/src/maj_provider.dart';

/// This is the widget used to display your tree in memory
class MAJBuilder extends StatefulWidget {
  /// The root of the tree you wish to display
  /// this does not have to be a root node; however,
  /// setting this as the root is the convention
  final MAJNode root;

  /// the key you use to reference the map of nodes
  /// don't set if you only intend to have one tree
  /// set if you wish to have more than one tree in
  /// memory at once
  final String mapKey;

  MAJBuilder({
    Key? key,
    required this.root,
    this.mapKey = MAJProvider.defaultMapKey,
  }) : super(key: key) {
    // add map key to MAJNode.sharedData if doesn't already exist
    if (!MAJNode.sharedData.containsKey(mapKey)) {
      MAJNode.sharedData[mapKey] = {};
    }
  }

  @override
  State<MAJBuilder> createState() {
    return _MAJBuilderState();
  }
}

class _MAJBuilderState extends State<MAJBuilder> {
  late MAJNode _currentNode;

  @override
  void initState() {
    super.initState();

    // set the current node to the passed root reference
    _currentNode = widget.root;
  }

  @override
  Widget build(BuildContext context) {
    // provider for state management
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MAJProvider(
            currentNode: _currentNode,
            mapKey: widget.mapKey,
          ),
        ),
      ],

      // display node in builder so correct context is used and
      // provider state management works
      child: Builder(
        builder: (context) {
          // get current node, and build it
          _currentNode = context.watch<MAJProvider>().currentNode;
          return _currentNode.build(context);
        },
      ),
    );
  }
}
