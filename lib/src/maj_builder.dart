/*
  Bradley Honeyman
  July 14th, 2022

  This is the builder for memory and json directories

 */

import 'package:flutter/material.dart';
import 'package:memory_and_json_directories/src/maj_node.dart';
import 'package:provider/provider.dart';
import 'package:memory_and_json_directories/src/maj_provider.dart';

class MAJBuilder extends StatefulWidget {
  final MAJNode root;

  const MAJBuilder({
    Key? key,
    required this.root,
  }) : super(key: key);

  @override
  State<MAJBuilder> createState() {
    return _MAJBuilderState();
  }
}

class _MAJBuilderState extends State<MAJBuilder> {
  late String _currentPath;
  late MAJNode _currentNode;

  @override
  void initState() {
    super.initState();

    // set the current path to the path of the root
    _currentPath = widget.root.path;
    _currentNode = widget.root;
  }

  @override
  Widget build(BuildContext context) {
    // provider for state management
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MAJProvider(
            currentPath: _currentPath,
            currentNode: widget.root,
          ),
        ),
      ],

      // display node in builder so correct context is used and
      // provider state management works
      child: Builder(
        builder: (context) {
          // get current path
          _currentPath = context.watch<MAJProvider>().currentPath;

          // get current node
          _currentNode = context.watch<MAJProvider>().currentNode;

          // use the appropriate method to build the node
          if (context.read<MAJProvider>().byPathElseByNode) {
            return widget.root.breadthFirstSearch(_currentPath)!.build(context);
          } else {
            return _currentNode.build(context);
          }
        },
      ),
    );
  }
}
