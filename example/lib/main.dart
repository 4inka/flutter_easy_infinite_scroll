import 'package:easy_infinite_scroll/easy_infinite_scroll.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _pageCount = 1;
  bool _hasMoreData = true;

  Future<List<Widget>> _fetchData() async {
    if (_pageCount <= 3) {
      await Future.delayed(Duration(seconds: 3));
      setState(() => _pageCount++);
      if(_pageCount == 3)
        setState(() => _hasMoreData = false);
      return List.generate(15, (index) {
        return Container(
          width: double.infinity,
          height: 50,
          margin: EdgeInsets.all(5),
          color: Colors.pink
        );
      });
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Example'),
        ),
        body: EasyInfiniteScroll(
          fetchData: _fetchData(),
          hasMoreData: _hasMoreData
        )
      ),
    );
  }
}
