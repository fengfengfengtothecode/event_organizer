import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TransitionPage extends StatefulWidget {
  const TransitionPage({super.key});

  @override
  TransitionPageState createState() => TransitionPageState();
}

class TransitionPageState extends State<TransitionPage> {
  // bool _isLoading =false;

  @override
  void initState() {
    super.initState();
    // _simulateLoading();
  }

  // void _simulateLoading() {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   Future.delayed(Duration(seconds: 2), () {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return const Center(
        child:  CircularProgressIndicator()
    );
  }
}
