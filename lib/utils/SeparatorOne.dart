import 'package:flutter/material.dart';

class SeparatorOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10.0,
        ),
        Divider(),
        SizedBox(
          height: 10.0,
        ),
      ],
    );
  }
}
