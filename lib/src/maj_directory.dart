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
  final String _typeName = "json_directory";

  @override
  String getTypeName() {
    return _typeName;
  }

  @override
  Widget build({
    required BuildContext context,
    required MAJNode nodeReference,
    Map<String, dynamic>? data,
  }) {
    return MAJDirectoryWidget(
      data: data,
      nodeReference: nodeReference,
    );
  }
}

class MAJDirectoryWidget extends StatefulWidget {
  final Map<String, dynamic>? data;
  final MAJNode nodeReference;

  const MAJDirectoryWidget({
    Key? key,
    this.data,
    required this.nodeReference,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MAJDirectoryWidgetState();
  }
}

class _MAJDirectoryWidgetState extends State<MAJDirectoryWidget> {
  Widget _displayChildren() {
    List<Widget> children = [];

    for (int i = 0; i < widget.nodeReference.children.length; i++) {
      String path = widget.nodeReference.children[i].path;
      children.add(
        ElevatedButton(
          child: Text(path),
          onPressed: () {
            context.read<MAJProvider>().navigateTo(path);
          },
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(widget.nodeReference.path),
            ElevatedButton(
              child: const Text("Back"),
              onPressed: () {
                if (widget.nodeReference.parent != null) {
                  context.read<MAJProvider>().navigateTo(
                        widget.nodeReference.parent!.path,
                      );
                }
              },
            ),
            _displayChildren(),
          ],
        ),
      ],
    );
  }
}
