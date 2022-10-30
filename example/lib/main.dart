/*
  Bradley Honeyman
  July 14th, 2022

  This is an example of how to use memory_and_json_directories
  This example includes all the code for:
    Basic Example
    Custom Item Example
    Data and Shared Data Example

 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:memory_and_json_directories/memory_and_json_directories.dart';
import 'package:provider/provider.dart';

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
    function: () => CustomItem(),
  );

  // set shared data for custom Item in memory
  // will be loaded from json below
  MAJNode.setSharedData(
    typeName: CustomItem.typeName,
    data: {
      "data": "Shared Data value",
    },
  );

  // build a tree in memory
  MAJNode root = MAJNode(
    name: "root",
    child: MAJDirectory(),
    typeName: MAJDirectory.typeName,
  );
  root
      .addChild(
        MAJNode(
          name: "one",
          child: MAJDirectory(),
          typeName: MAJDirectory.typeName,
        ),
      )
      .addChild(
        MAJNode(
          name: "one one level down",
          child: MAJDirectory(),
          typeName: MAJDirectory.typeName,
        ),
      );
  root.addChild(
    MAJNode(
      name: "two",
      child: MAJDirectory(),
      typeName: MAJDirectory.typeName,
    ),
  );

  // add a custom item to the tree
  root.addChild(
    MAJNode(
      name: "Custom Item",
      child: CustomItem(),
      typeName: CustomItem.typeName,
    ),
  );

  // add a second child to show that data can be different between nodes of the
  // same type, and that shared data is shared
  root.addChild(
    MAJNode(
      name: "Custom Item 2",
      child: CustomItem(),
      typeName: CustomItem.typeName,
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

  // display the tree loaded from json
  runApp(
    MaterialApp(
      home: Scaffold(
        body: MAJBuilder(
          root: fromJson,
        ),
      ),
    ),
  );
}
