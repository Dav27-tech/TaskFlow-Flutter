import 'package:flutter/material.dart';

class Project {
  final String id;
  final String name;
  final Color dotColor;
  final List<String> memberIds;

  const Project({
    required this.id,
    required this.name,
    required this.dotColor,
    required this.memberIds,
  });
}
