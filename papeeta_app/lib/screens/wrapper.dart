import 'package:flutter/material.dart';
import 'package:papeeta/screens/home/home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    //Return either home or authenticate
    return const Home();
  }
}
