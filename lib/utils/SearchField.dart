import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {

  Function handler;
  SearchField({this.handler});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        hintText: 'Search',
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: (value){
        handler(value);
      },
    );
  }
}
