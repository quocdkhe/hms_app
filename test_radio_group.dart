import 'package:flutter/material.dart';

void main() {
  RadioGroup<String>(
    groupValue: '',
    onChanged: (v) {},
    child: Column(
      children: [
        RadioListTile<String>(value: 'A', title: Text('A')),
        RadioListTile<String>(value: 'B', title: Text('B')),
      ],
    ),
  );
}
