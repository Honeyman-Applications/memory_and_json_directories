/*
  Bradley Honeyman
  July 14th, 2022

  This is an example of how to use memory_and_json_directories

 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memory_and_json_directories/memory_and_json_directories.dart';

/*
  The custom class used to build the CustomItemWidget
  I recommend not having any constructors for this class
  You should use the MAJNode.data property to pass any
  data you would need in a constructor
 */
class CustomItem implements MAJItemInterface {
  static const String typeName = "custom_item";

  @override
  String getTypeName() {
    return typeName;
  }

  @override
  Widget build({
    required BuildContext context,
    required MAJNode nodeReference,
  }) {
    return CustomItemWidget(
      nodeReference: nodeReference,
    );
  }
}

/*
  A custom widget used to display data
  reference the data from the node through the
  nodeReference that can be passed through the CustomItem build
 */
class CustomItemWidget extends StatelessWidget {
  final MAJNode nodeReference; // recommend always adding

  const CustomItemWidget({
    Key? key,
    required this.nodeReference, // recommend always adding
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // a back button to navigate back to the parent widget
        ElevatedButton(
          child: const Text("back"),
          onPressed: () {
            context.read<MAJProvider>().navigateToByNode(
                  nodeReference.parent!,
                );
          },
        ),
        TextFormField(
          initialValue: nodeReference.data!["name"], // get custom data
          onChanged: (value) {
            nodeReference.data!["name"] = value; // set custom data
          },
        ),
      ],
    );
  }
}

void main() {
  // add custom item's definition to MAJNode's static definitions
  // important this is done before any custom items are built
  MAJNode.addDefinition(
    typeName: CustomItem.typeName,
    function: () {
      return CustomItem();
    },
  );

  /*
  // unsafe way to add a definition
  MAJNode.definitions[CustomItem.typeName] = () {
    return CustomItem();
  };
   */

  // build an example tree
  MAJNode? root = MAJNode(
    name: "the rooter",
    typeName: MAJDirectory.typeName,
    child: MAJDirectory(),
  );

  MAJNode one = root.addChild(MAJNode(
    name: "One",
    typeName: MAJDirectory.typeName,
    child: MAJDirectory(),
  ));
  MAJNode two = root.addChild(MAJNode(
    name: "Two",
    typeName: MAJDirectory.typeName,
    child: MAJDirectory(),
  ));
  MAJNode three = root.addChild(MAJNode(
    name: "Three",
    typeName: MAJDirectory.typeName,
    child: MAJDirectory(),
  ));

  one.addChild(MAJNode(
    name: "one 1",
    typeName: MAJDirectory.typeName,
    child: MAJDirectory(),
  ));
  one.addChild(MAJNode(
    name: "one 2",
    typeName: MAJDirectory.typeName,
    child: MAJDirectory(),
  ));
  one.addChild(MAJNode(
    name: "one 3",
    typeName: MAJDirectory.typeName,
    child: MAJDirectory(),
  ));

  MAJNode deep = two.addChild(MAJNode(
    name: "deep",
    typeName: MAJDirectory.typeName,
    child: MAJDirectory(),
  ));
  deep.addChild(MAJNode(
    name: "deep 1",
    typeName: MAJDirectory.typeName,
    child: MAJDirectory(),
  ));
  deep.addChild(MAJNode(
    name: "deep 2",
    typeName: MAJDirectory.typeName,
    child: MAJDirectory(),
  ));

  three.addChild(MAJNode(
    name: "three 1",
    typeName: MAJDirectory.typeName,
    child: MAJDirectory(),
  ));

  MAJNode bruh = MAJNode(
    name: "bruh",
    typeName: MAJDirectory.typeName,
    child: MAJDirectory(),
  );
  bruh.addChild(MAJNode(
    name: "Honey",
    typeName: MAJDirectory.typeName,
    child: MAJDirectory(),
  ));
  three.addChild(bruh);

  // add a custom item to the root, and deep
  root.addChild(
    MAJNode(
      name: "custom",
      typeName: CustomItem.typeName,
      data: <String, dynamic>{
        "name": "Snarf",
      },
      child: CustomItem(),
    ),
  );

  // add another custom node deeper in the tree
  deep.addChild(
    MAJNode(
      name: "deep custom",
      typeName: CustomItem.typeName,
      data: {
        "name": "narf",
      },
      child: CustomItem(),
    ),
  );

  // print a breadth first traversal so the structure can be seen
  print(root.breadthFirstTraversal());

  // remove the current node and children from MAJProvider.map
  // so not to pollute the map when rebuilding from json
  root.remove();

  // convert to json as a proof then build from json
  MAJNode newer = MAJNode.fromJson(root.breadthFirstToJson());

  // demonstrate allowing the garbage collector to clean up
  // with no references here, or in the map the tree will be
  // garbage collected
  root = null;

  runApp(
    MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: MAJBuilder(
            root: newer,
          ),
        ),
      ),
    ),
  );
}
