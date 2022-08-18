/*
  Bradley Honeyman
  Aug 7, 2022

  This is a directory that can be used to store
  directories or data
  this is an example

 */

import 'package:flutter/material.dart';
import 'package:memory_and_json_directories/src/maj_item_interface.dart';
import 'package:memory_and_json_directories/src/maj_provider.dart';
import 'package:memory_and_json_directories/src/maj_node.dart';
import 'package:provider/provider.dart';

class MAJDirectory implements MAJItemInterface {
  static const String typeName = "maj_directory";

  @override
  String getTypeName() {
    return typeName;
  }

  @override
  Widget build({
    required BuildContext context,
    required MAJNode nodeReference,
  }) {
    return MAJDirectoryWidget(
      nodeReference: nodeReference,
    );
  }
}

class MAJDirectoryWidget extends StatefulWidget {
  final MAJNode nodeReference;

  const MAJDirectoryWidget({
    Key? key,
    required this.nodeReference,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MAJDirectoryWidgetState();
  }
}

class _MAJDirectoryWidgetState extends State<MAJDirectoryWidget> {
  // used to display the current directory's children
  Widget _displayChildren() {
    List<Widget> children = [];

    for (int i = 0; i < widget.nodeReference.children.length; i++) {
      String path = widget.nodeReference.children[i].path;
      children.add(Padding(
        padding: const EdgeInsets.all(5),
        child: ElevatedButton(
          child: Text(path),
          onPressed: () {
            context
                .read<MAJProvider>()
                .navigateToByNode(widget.nodeReference.children[i]);
          },
        ),
      ));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: ElevatedButton(
            child: const Text("Back"),
            onPressed: () {
              if (widget.nodeReference.parent != null) {
                context.read<MAJProvider>().navigateToByNode(
                      widget.nodeReference.parent!,
                    );
              }
            },
          ),
        ),
        Text(
          widget.nodeReference.path,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline3,
        ),
        _displayChildren(),
      ],
    );
  }
}
