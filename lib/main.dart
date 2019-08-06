import 'package:flutter/material.dart';
import './pages/index_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      title: '百姓生活+',
      theme: ThemeData(
        primaryColor: Colors.pink[600]
      ),
      home: IndexPage(),
    );
  }
}