/*
  Bradley Honeyman
  July 14th, 2022

  This is an example of how to use memory_and_json_directories
  This example includes all the code for:
    Basic Example
    Custom Item Example
    Data and Shared Data Example
    Multiple Trees Example
    Building a Custom Directory Item

 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:memory_and_json_directories/memory_and_json_directories.dart';
import 'package:provider/provider.dart';

/// An example of how to create a custom directory, which will display
/// in a manner you desire
class CustomDirectory implements MAJItemInterface {
  /// not required, but recommended
  static const String typeName = "custom_directory";

  @override
  String getTypeName() {
    return typeName;
  }

  @override
  Widget majBuild({
    required BuildContext context,
    required MAJNode nodeReference,
  }) {
    // return custom directory widget
    return CustomDirectoryWidget(
      nodeReference: nodeReference,
      context: context,
    );
  }
}

/// widget that displays the custom directory
class CustomDirectoryWidget extends StatefulWidget {
  final MAJNode nodeReference;
  final BuildContext context;

  // get node reference, and context to pass to the state
  const CustomDirectoryWidget({
    super.key,
    required this.nodeReference,
    required this.context,
  });

  @override
  State<StatefulWidget> createState() {
    return CustomDirectoryWidgetState();
  }
}

/// state of the custom directory
class CustomDirectoryWidgetState extends State<CustomDirectoryWidget> {
  @override
  Widget build(BuildContext context) {
    /// builds the buttons that are displayed in the directory widget
    List<Widget> buildButtons() {
      List<Widget> temp = [];

      // add back button
      temp.add(
        // back button, navigates to parent, unless there is not parent node
        ElevatedButton(
          onPressed: () {
            if (widget.nodeReference.parent != null) {
              context.read<MAJProvider>().navigateToByNode(
                    nodeTo: widget.nodeReference.parent!,
                  );
            }
          },
          child: const Text("Back"),
        ),
      );

      // add children of the current directory
      for (int i = 0; i < widget.nodeReference.children.length; i++) {
        temp.add(
          // build the node when button pressed
          OutlinedButton(
            onPressed: () {
              context.read<MAJProvider>().navigateToByNode(
                    nodeTo: widget.nodeReference.children[i],
                  );
            },

            // display node's path
            child: Text(
              widget.nodeReference.children[i].path,
            ),
          ),
        );
      }

      return temp;
    }

    // return column of buttons that when pressed load nodes
    return Column(
      children: buildButtons(),
    );
  }
}

/// A basic custom item that can display whatever you wish
class CustomItem implements MAJItemInterface {
  /// not required, but recommended
  static const String typeName = "custom_item";

  @override
  String getTypeName() {
    return typeName;
  }

  @override
  Widget majBuild({
    required BuildContext context,
    required MAJNode nodeReference,
  }) {
    // set default data value if no data
    if (nodeReference.data == null || nodeReference.data!.keys.isEmpty) {
      nodeReference.data = nodeReference.data = <String, bool>{
        "pressed": false,
      };
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return Center(
          child: Column(
            children: [
              // back button, navigates to parent, unless there is not parent node
              ElevatedButton(
                onPressed: () {
                  if (nodeReference.parent != null) {
                    context.read<MAJProvider>().navigateToByNode(
                          nodeTo: nodeReference.parent!,
                        );
                  }
                },
                child: const Text("Back"),
              ),

              // custom widget to display
              const Text("Hello I am a custom item"),

              // add text that shows the shared data for CustomItem
              Text(
                nodeReference.getSharedData().toString(),
              ),

              // add button that shows the data for the instance of CustomItem
              OutlinedButton(
                // update data value for instance on pressed to opposite of what it was
                onPressed: () {
                  setState(() {
                    nodeReference.data!["pressed"] =
                        !nodeReference.data!["pressed"];
                  });
                },
                // display data for this instance
                child: Text(
                  nodeReference.data!["pressed"].toString(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void main() {
  // define the custom item, so it can be loaded from json
  MAJNode.addDefinition(
    typeName: CustomItem.typeName,
    item: () => CustomItem(),
  );

  // define the custom directory, so it can be loaded from json
  MAJNode.addDefinition(
    typeName: CustomDirectory.typeName,
    item: () => CustomDirectory(),
  );

  // set shared data for custom Item in memory
  // will be loaded from json below
  MAJNode.setSharedData(
    typeName: CustomItem.typeName,
    data: {
      "data": "Shared Data value",
    },
  );

  // set shared data for custom Item in memory
  // will be loaded from json below
  // map key for tree 2 set
  MAJNode.setSharedData(
    typeName: CustomItem.typeName,
    data: {
      "data": "Shared Data value from tree 2",
    },
    mapKey: "tree_2",
  );

  // build a tree in memory
  MAJNode root = MAJNode(
    name: "root",
    child: MAJDirectory(),
  );
  root
      .addChild(
        MAJNode(
          name: "one",
          child: MAJDirectory(),
        ),
      )
      .addChild(
        MAJNode(
          name: "one one level down",
          child: MAJDirectory(),
        ),
      );
  root.addChild(
    MAJNode(
      name: "two",
      child: MAJDirectory(),
    ),
  );

  // add a custom item to the tree
  root.addChild(
    MAJNode(
      name: "Custom Item",
      child: CustomItem(),
    ),
  );

  // add a second child to show that data can be different between nodes of the
  // same type, and that shared data is shared
  root.addChild(
    MAJNode(
      name: "Custom Item 2",
      child: CustomItem(),
    ),
  );

  // convert to json
  String treeAsJson = jsonEncode(
    root.breadthFirstToJson(),
  );

  // load from json string
  MAJNode fromJson = MAJNode.breadthFirstFromJson(
    jsonDecode(
      treeAsJson,
    ),
  );

  // create 2nd tree's root
  MAJNode root2 = MAJNode(
    name: "root 2",
    child: MAJDirectory(),
    mapKey: "tree_2", // because second tree, avoids naming collisions
  );
  root2
      .addChild(
        MAJNode(
          name: "one",
          child: MAJDirectory(),
          mapKey: "tree_2",
        ),
      )
      .addChild(
        MAJNode(
          name: "One down from one",
          child: CustomItem(),
          mapKey: "tree_2",
        ),
      );

  // add custom dirs
  root2.addChild(
    MAJNode(
      name: "Custom Dir 1",
      child: CustomDirectory(),
      mapKey: "tree_2",
    ),
  )
    // add to custom 1
    ..addChild(
      MAJNode(
        name: "Custom Dir 1",
        child: CustomDirectory(),
        mapKey: "tree_2",
      ),
    )
    // add to custom 1
    ..addChild(
      MAJNode(
        name: "Custom Dir 2",
        child: CustomDirectory(),
        mapKey: "tree_2",
      ),
      // add to custom 2
    ).addChild(
      MAJNode(
        name: "Custom Dir 3",
        child: CustomDirectory(),
        mapKey: "tree_2",
      ),
    );

  // convert tree to json
  String tree2FromJson = jsonEncode(
    root2.breadthFirstToJson(),
  );

  // build second tree from json
  MAJNode fromJson2 = MAJNode.breadthFirstFromJson(
    jsonDecode(tree2FromJson),
  );

  // display the tree loaded from json
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            // tree 1
            MAJBuilder(
              root: fromJson,
            ),

            // tree 2, see how it has a map key, this is so the name space
            // doesn't collide with the first tree. tree 1 uses the default map key
            MAJBuilder(
              root: fromJson2,
              mapKey: fromJson2.mapKey,
            ),
          ],
        ),
      ),
    ),
  );
}
