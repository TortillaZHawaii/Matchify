import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String? errorMessage;

  const ErrorPage({Key? key, this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Upsss... Something went wrong'),
          if (errorMessage != null) Text(errorMessage!),
        ],
      ),
    );
  }
}
