/*
  Bradley Honeyman
  July 14th, 2022

  This is an example of how to use memory_and_json_directories

 */

import 'package:flutter/material.dart';
import 'package:memory_and_json_directories/memory_and_json_directories.dart';

void main() {
  String typeName = MAJDirectory().getTypeName();

  MAJNode root = MAJNode(
    name: "the rooter",
    typeName: typeName,
    child: MAJDirectory(),
  );

  MAJNode one = root.addChild(MAJNode(
    name: "One",
    typeName: typeName,
    child: MAJDirectory(),
  ));
  MAJNode two = root.addChild(MAJNode(
    name: "Two",
    typeName: typeName,
    child: MAJDirectory(),
  ));
  MAJNode three = root.addChild(MAJNode(
    name: "Three",
    typeName: typeName,
    child: MAJDirectory(),
  ));

  one.addChild(MAJNode(
    name: "one 1",
    typeName: typeName,
    child: MAJDirectory(),
  ));
  one.addChild(MAJNode(
    name: "one 2",
    typeName: typeName,
    child: MAJDirectory(),
  ));
  one.addChild(MAJNode(
    name: "one 3",
    typeName: typeName,
    child: MAJDirectory(),
  ));

  MAJNode deep = two.addChild(MAJNode(
    name: "deep",
    typeName: typeName,
    child: MAJDirectory(),
  ));
  deep.addChild(MAJNode(
    name: "deep 1",
    typeName: typeName,
    child: MAJDirectory(),
  ));
  deep.addChild(MAJNode(
    name: "deep 2",
    typeName: typeName,
    child: MAJDirectory(),
  ));

  three.addChild(MAJNode(
    name: "three 1",
    typeName: typeName,
    child: MAJDirectory(),
  ));

  MAJNode bruh = MAJNode(
    name: "bruh",
    typeName: typeName,
    child: MAJDirectory(),
  );
  bruh.addChild(MAJNode(
    name: "Honey",
    typeName: typeName,
    child: MAJDirectory(),
  ));

  three.addChild(bruh);

  MAJNode newer = MAJNode.fromJson(root.breadthFirstToJson());

  runApp(
    MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: MAJBuilder(
              root: newer,
            ),
          ),
        ),
      ),
    ),
  );
}
